//////////////////////////////////////////////////////////////////////////////////////-
// Simple DRAM controller for the DE1 board, assuming a 50MHz controller/memory clock
// Assuming 64Mbytes SDRam organised as 32Meg x16 bits with 8192 rows (13 bit row addr
// 1024 columns (10 bit column address) and 4 banks (2 bit bank address)
// CAS latency is 2 clock periods
//
// designed to work with 68000 cpu using 16 bit data bus and 32 bit address bus
// separate upper and lower data stobes for individual byte and 16 bit word access
//
// Copyright PJ Davies June 2020
//
// ── BURST READ EXTENSION ────────────────────────────────────────────────────
// Adds a burst-read port for the VGA framebuffer scanout (and later, blitter).
//
//   BurstReq_H     in   level-high request.  Hold high (with BurstAddress /
//                       BurstLength stable) until BurstDone_H pulses.
//   BurstAddress   in   byte address of first 16-bit word (bit 0 ignored).
//                       The ENTIRE burst must stay inside one SDRAM row:
//                       column(start) + BurstLength <= 1024.  Guaranteed by
//                       using a 1024-byte (512-word) line stride and a
//                       2KB-row-aligned framebuffer base.
//   BurstLength    in   number of 16-bit words (1..512).
//   BurstData      out  16-bit word, updated on negedge Clock (same proven
//                       sampling instant as the single-read path: data for a
//                       READ issued combinationally in cycle N is latched at
//                       the negedge of cycle N+3).
//   BurstValid_H   out  high for exactly one cycle per word; sample BurstData
//                       on the posedge at the end of that cycle.
//   BurstDone_H    out  1-cycle pulse when the burst (incl. precharge) is done.
//
// Burst sequence:  idling ──BankActivate──► burst_read (one ReadOnly command
// per clock, A10=0, incrementing column) ──► burst_drain (flush the 3-deep
// CAS pipeline) ──► burst_precharge (PrechargeSelectBank) ──► burst_finish
// (NOP + BurstDone_H) ──► idling.
//
// Arbitration priority in idling:  refresh  >  burst  >  CPU bus cycle.
// A refresh falling due mid-burst is deferred until the burst completes; to
// keep the 64ms/8192-row budget safe with a worst-case 320-word (~6.5us)
// deferral, RefreshTimerValue is shortened from 375 to 300 (6us nominal).
//
// The CPU single-access path (read_SDRAM / write_SDRAM / terminate_bus_cycle)
// is completely untouched.
//////////////////////////////////////////////////////////////////////////////////////-


module M68kDramController_Verilog (
			input Clock,								// used to drive the state machine- stat changes occur on positive edge
			input Reset_L,     						// active low reset 
			input unsigned [31:0] Address,		// address bus from 68000
			input unsigned [15:0] DataIn,			// data bus in from 68000
			input UDS_L,								// active low signal driven by 68000 when 68000 transferring data over data bit 15-8
			input LDS_L, 								// active low signal driven by 68000 when 68000 transferring data over data bit 7-0
			input DramSelect_L,     				// active low signal indicating dram is being addressed by 68000
			input WE_L,  								// active low write signal, otherwise assumed to be read
			input AS_L,									// Address Strobe

			// ── Burst read port (framebuffer scanout) ──────────────────────
			input BurstReq_H,							// level-high burst request; hold until BurstDone_H
			input unsigned [31:0] BurstAddress,	// byte address of first 16-bit word of the burst
			input unsigned [9:0] BurstLength,	// number of 16-bit words to read (1..512, one row max)
			output reg unsigned [15:0] BurstData,	// burst read data (latched on negedge Clock)
			output BurstValid_H,						// 1 cycle high per word; sample BurstData on the ending posedge
			output reg BurstDone_H,					// 1 cycle pulse when burst fully complete
			
			output reg unsigned[15:0] DataOut, 				// data bus out to 68000
			output reg SDram_CKE_H,								// active high clock enable for dram chip
			output reg SDram_CS_L,								// active low chip select for dram chip
			output reg SDram_RAS_L,								// active low RAS select for dram chip
			output reg SDram_CAS_L,								// active low CAS select for dram chip		
			output reg SDram_WE_L,								// active low Write enable for dram chip
			output reg unsigned [12:0] SDram_Addr,			// 13 bit address bus dram chip	
			output reg unsigned [1:0] SDram_BA,				// 2 bit bank address
			inout  wire [15:0] SDram_DQ,			// 16 bit bi-directional data lines to dram chip
			
			output reg Dtack_L,									// Dtack back to CPU at end of bus cycle
			output reg ResetOut_L,								// reset out to the CPU
	
			// Use only if you want to simulate dram controller state (e.g. for debugging)
			output reg [4:0] DramState
		); 	
		reg [15:0] SDram_DQ_reg;
		// WIRES and REGs
		
		reg  	[4:0] Command;										// 5 bit signal containing Dram_CKE_H, SDram_CS_L, SDram_RAS_L, SDram_CAS_L, SDram_WE_L

		reg	TimerLoad_H ;										// logic 1 to load Timer on next clock
		reg   TimerDone_H ;										// set to logic 1 when timer reaches 0
		reg 	unsigned	[15:0] Timer;							// 16 bit timer value
		reg 	unsigned	[15:0] TimerValue;					// 16 bit timer preload value

		reg	RefreshTimerLoad_H;								// logic 1 to load refresh timer on next clock
		reg   RefreshTimerDone_H ;								// set to 1 when refresh timer reaches 0
		reg 	unsigned	[15:0] RefreshTimer;					// 16 bit refresh timer value
		reg 	unsigned	[15:0] RefreshTimerValue;			// 16 bit refresh timer preload value

		reg   unsigned [4:0] CurrentState;					// holds the current state of the dram controller
		reg   unsigned [4:0] NextState;						// holds the next state of the dram controller
		
		reg  	unsigned [1:0] BankAddress;
		reg  	unsigned [12:0] DramAddress;
		
		reg	DramDataLatch_H;									// used to indicate that data from SDRAM should be latched and held for 68000 after the CAS latency period
		reg  	unsigned [15:0]SDramWriteData;
		
		reg  FPGAWritingtoSDram_H;								// When '1' enables FPGA data out lines leading to SDRAM to allow writing, otherwise they are set to Tri-State "Z"
		reg  CPU_Dtack_L;											// Dtack back to CPU
		reg  CPUReset_L;	

		reg [4:0] RO_command_buffer;
		reg [4:0] RRH_command_buffer;
		reg A10_buffer;
		reg RO_enable;
		reg RO_done;
		reg RRH_enable;
		reg RRH_done;
		wire RO_done_wire;
		wire RRH_done_wire;
		wire [4:0] RO_command_wire;
		wire [4:0] RRH_command_wire;
		wire A10_wire;
		reg counter_write;
		reg counter_increment;
		reg unsigned [15:0] counter_value;
		reg counter_done;
		wire counter_done_wire;

		// ── Burst datapath registers ────────────────────────────────────────
		reg unsigned [9:0]  BurstCol;			// current column being issued
		reg unsigned [1:0]  BurstBankReg;	// bank for this burst (latched at grant)
		reg unsigned [9:0]  BurstRemain;		// words left to issue
		reg [2:0]           BurstPipe;		// CAS-latency tracking: bit set per in-flight READ
		reg                 BurstLoad_H;		// comb: latch BurstAddress/BurstLength at grant
		reg                 BurstStep_H;		// comb: one READ issued this cycle

		// A word whose READ command was generated combinationally in cycle N is
		// latched from SDram_DQ at the negedge of cycle N+3 (BurstPipe[2]) - the
		// identical sampling instant the proven single-read path uses
		// (TimerValue=2 in read_SDRAM, last DramDataLatch_H negedge before Dtack).
		assign BurstValid_H = BurstPipe[2];

		// 5 bit Commands to the SDRam

		parameter PoweringUp = 5'b00000 ;					// take CKE & CS low during power up phase, address and bank address = dont'care
		parameter DeviceDeselect  = 5'b11111;				// address and bank address = dont'care
		parameter NOP = 5'b10111;								// address and bank address = dont'care
		parameter BurstStop = 5'b10110;						// address and bank address = dont'care
		parameter ReadOnly = 5'b10101; 						// A10 should be logic 0, BA0, BA1 should be set to a value, other addreses = value
		parameter ReadAutoPrecharge = 5'b10101; 			// A10 should be logic 1, BA0, BA1 should be set to a value, other addreses = value
		parameter WriteOnly = 5'b10100; 						// A10 should be logic 0, BA0, BA1 should be set to a value, other addreses = value
		parameter WriteAutoPrecharge = 5'b10100 ;			// A10 should be logic 1, BA0, BA1 should be set to a value, other addreses = value
		parameter AutoRefresh = 5'b10001;
	
		parameter BankActivate = 5'b10011;					// BA0, BA1 should be set to a value, address A11-0 should be value
		parameter PrechargeSelectBank = 5'b10010;			// A10 should be logic 0, BA0, BA1 should be set to a value, other addreses = don't care
		
		parameter PrechargeAllBanks = 5'b10010;			// A10 should be logic 1, BA0, BA1 are dont'care, other addreses = don't care
		parameter ModeRegisterSet = 5'b10000;				// A10=0, BA1=0, BA0=0, Address = don't care
		parameter ExtModeRegisterSet = 5'b10000;			// A10=0, BA1=1, BA0=0, Address = value
		
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-
// Define some states for our dram controller add to these as required - only 5 will be defined at the moment - add your own as required
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-
	
		parameter InitialisingState 		= 5'h00;				// power on initialising state
		parameter WaitingForPowerUpState	= 5'h01	;		// waiting for power up state to complete
		parameter IssueFirstNOP 			= 5'h02;						// issuing 1st NOP after power up
		parameter PrechargingAllBanks 		= 5'h03;
		parameter Idle 						= 5'h04;		
		parameter issue_second_NOP			= 5'h05;	
		parameter issue_NOP					= 5'h06;
		parameter issue_refresh				= 5'h07;
		parameter wait_refresh				= 5'h08;
		parameter refresh_request_loop  	= 5'h09;
		parameter wait_refresh_request		= 5'h0A;
		parameter program_mode_reg			= 5'h0B;
		parameter stall_idle				= 5'h0C;
		parameter start_RRH					= 5'h0D;
		parameter idling					= 5'h0E;
		parameter write_SDRAM				= 5'h0F;
		parameter write_SDRAM_wait			= 5'h10;
		parameter terminate_bus_cycle		= 5'h11;
		parameter read_SDRAM				= 5'h12;
		parameter read_SDRAM_wait			= 5'h13;

		// ── Burst read states ───────────────────────────────────────────────
		parameter burst_read				= 5'h14;		// issue one ReadOnly command per clock
		parameter burst_drain				= 5'h15;		// NOPs while CAS pipeline flushes
		parameter burst_precharge			= 5'h16;		// PrechargeSelectBank (A10=0)
		parameter burst_finish				= 5'h17;		// tRP spacing + BurstDone_H pulse
		
		
		// TODO - Add your own states as per your own design
		assign SDram_DQ = FPGAWritingtoSDram_H ? SDram_DQ_reg : 16'bz;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// General Timer for timing and counting things: Loadable and counts down on each clock then produced a TimerDone signal and stops counting
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	always@(posedge Clock)
		if(TimerLoad_H == 1) 				// if we get the signal from another process to load the timer
			Timer <= TimerValue ;			// Preload timer
		else if(Timer != 16'd0) 			// otherwise, provided timer has not already counted down to 0, on the next rising edge of the clock		
			Timer <= Timer - 16'd1 ;		// subtract 1 from the timer value

	always@(Timer) begin
		TimerDone_H <= 0 ;					// default is not done
	
		if(Timer == 16'd0) 					// if timer has counted down to 0
			TimerDone_H <= 1 ;				// output '1' to indicate time has elapsed
	end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Refresh Timer: Loadable and counts down on each clock then produces a RefreshTimerDone signal and stops counting
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	always@(posedge Clock)
		if(RefreshTimerLoad_H == 1) 						// if we get the signal from another process to load the timer
			RefreshTimer  <= RefreshTimerValue ;		// Preload timer
		else if(RefreshTimer != 16'd0) 					// otherwise, provided timer has not already counted down to 0, on the next rising edge of the clock		
			RefreshTimer <= RefreshTimer - 16'd1 ;		// subtract 1 from the timer value

	always@(RefreshTimer) begin
		RefreshTimerDone_H <= 0 ;							// default is not done

		if(RefreshTimer == 16'd0) 								// if timer has counted down to 0
			RefreshTimerDone_H <= 1 ;						// output '1' to indicate time has elapsed
	end
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-
// concurrent process state registers
// this process RECORDS the current state of the system.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   always@(posedge Clock, negedge Reset_L)
	begin
		if(Reset_L == 0) begin					// asynchronous reset
			CurrentState <= InitialisingState ;
			BurstPipe	 <= 3'b000;				// no reads in flight
		end
			
		else 	begin									// state can change only on low-to-high transition of clock
			CurrentState <= NextState;		

			// these are the raw signals that come from the dram controller to the dram memory chip. 
			// This process expects the signals in the form of a 5 bit bus within the signal Command. The various Dram commands are defined above just beneath the architecture)

			SDram_CKE_H <= Command[4];			// produce the Dram clock enable
			SDram_CS_L  <= Command[3];			// produce the Dram Chip select
			SDram_RAS_L <= Command[2];			// produce the dram RAS
			SDram_CAS_L <= Command[1];			// produce the dram CAS
			SDram_WE_L  <= Command[0];			// produce the dram Write enable
			
			SDram_Addr  <= DramAddress;		// output the row/column address to the dram
			SDram_BA   	<= BankAddress;		// output the bank address to the dram

			// signals back to the 68000

			Dtack_L 		<= CPU_Dtack_L ;			// output the Dtack back to the 68000
			ResetOut_L 	<= CPUReset_L ;			// output the Reset out back to the 68000
			
			RO_command_buffer 	<= RO_command_wire;
			RRH_command_buffer 	<= RRH_command_wire;
			RO_done 			<= RO_done_wire;
			RRH_done 			<= RRH_done_wire;
			A10_buffer 			<= A10_wire;

			counter_done		<= counter_done_wire;

			// ── Burst datapath ──────────────────────────────────────────────
			// BurstPipe is a 3-deep shift register tracking in-flight READ
			// commands.  A '1' enters when a READ is issued (BurstStep_H) and
			// reaches bit [2] exactly when that word must be latched/consumed.
			BurstPipe <= {BurstPipe[1:0], BurstStep_H};

			if (BurstLoad_H) begin				// latch burst parameters at grant
				BurstCol     <= BurstAddress[10:1];
				BurstBankReg <= BurstAddress[25:24];
				BurstRemain  <= BurstLength;
			end else if (BurstStep_H) begin	// one READ issued this cycle
				BurstCol     <= BurstCol + 10'd1;
				BurstRemain  <= BurstRemain - 10'd1;
			end

			// The signal FPGAWritingtoSDram_H can be driven by you when you need to turn on or tri-state the data bus out signals to the dram chip data lines DQ0-15
			// when you are reading from the dram you have to ensure they are tristated (so the dram chip can drive them)
			// when you are writing, you have to drive them to the value of SDramWriteData so that you 'present' your data to the dram chips
			// of course during a write, the dram WE signal will need to be driven low and it will respond by tri-stating its outputs lines so you can drive data in to it
			// remember the Dram chip has bi-directional data lines, when you read from it, it turns them on, when you write to it, it turns them off (tri-states them)

			SDram_DQ_reg <= SDramWriteData;
			DramState <= CurrentState ;					// output current state - useful for debugging so you can see you state machine changing states etc
		end
	end	
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-
// Concurrent process to Latch Data from Sdram after Cas Latency during read
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-

// this process will latch whatever data is coming out of the dram data lines on the FALLING edge of the clock you have to drive DramDataLatch_H to logic 1
// remember there is a programmable CAS latency for the Zentel dram chip on the DE1 board it's 2 or 3 clock cycles which has to be programmed by you during the initialisation
// phase of the dram controller following a reset/power on
//
// During a read, after you have presented CAS command to the dram chip you will have to wait 2 clock cyles and then latch the data out here and present it back
// to the 68000 until the end of the 68000 bus cycle

	always@(negedge Clock)
	begin
		if(DramDataLatch_H == 1)      			// asserted during the read operation
			DataOut <= SDram_DQ ;					// store 16 bits of data regardless of width - don't worry about tri state since that will be handled by buffers outside dram controller
	end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-
// Burst read data latch: same negedge sampling as the single-read path above,
// but gated by the CAS pipeline tracker so each in-flight word is captured on
// exactly the right falling edge during back-to-back streaming.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-

	always@(negedge Clock)
	begin
		if(BurstPipe[2] == 1)
			BurstData <= SDram_DQ ;
	end
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////-
// next state and output logic
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	always @(*) begin
	
	// In Verilog/VHDL - you will recall - that combinational logic (i.e. logic with no storage) is created as long as you
	// provide a specific value for a signal in each and every possible path through a process
	// 
	// You can do this of course, but it gets tedious to specify a value for each signal inside every process state and every if-else test within those states
	// so the common way to do this is to define default values for all your signals and then override them with new values as and when you need to.
	// By doing this here, right at the start of a process, we ensure the compiler does not infer any storage for the signal, i.e. it creates
	// pure combinational logic (which is what we want)
	//
	// Let's start with default values for every signal and override as necessary, 
	//
	
		Command 	<= NOP ;												// assume no operation command for Dram chip
		NextState <= InitialisingState ;							// assume next state will always be idle state unless overridden the value used here is not important, we cimple have to assign something to prevent storage on the signal so anything will do
		
		TimerValue <= 16'h0000;										// no timer value 
		RefreshTimerValue <= 16'h0000 ;							// no refresh timer value
		TimerLoad_H <= 0;												// don't load Timer
		RefreshTimerLoad_H <= 0 ;									// don't load refresh timer
		DramAddress <= 13'h0000 ;									// no particular dram address
		BankAddress <= 2'b00 ;										// no particular dram bank address
		DramDataLatch_H <= 0;										// don't latch data yet
		CPU_Dtack_L <= 1 ;											// don't acknowledge back to 68000
		SDramWriteData <= 16'h0000 ;								// nothing to write in particular
		CPUReset_L <= 0 ;												// default is reset to CPU (for the moment, though this will change when design is complete so that reset-out goes high at the end of the dram initialisation phase to allow CPU to resume)
		FPGAWritingtoSDram_H <= 0 ;								// default is to tri-state the FPGA data lines leading to bi-directional SDRam data lines, i.e. assume a read operation

		RO_enable			<= 1'b0;
		RRH_enable			<= 1'b0;
		counter_write		<= 1'b0;
		counter_increment	<= 1'b0;
		counter_value		<= 16'd0;

		BurstLoad_H			<= 1'b0;									// don't latch burst parameters
		BurstStep_H			<= 1'b0;									// no READ issued this cycle
		BurstDone_H			<= 1'b0;									// burst not complete



		// put your current state/next state decision making logic here - here are a few states to get you started
		// during the initialising state, the drams have to power up and we cannot access them for a specified period of time (100 us)
		// we are going to load the timer above with a value equiv to 100us and then wait for timer to time out
	
		if(CurrentState == InitialisingState ) begin
			TimerValue <= 16'h1388;									// chose a value equivalent to 100us at 50Mhz clock - you might want to shorten it to somthing small for simulation purposes
			TimerLoad_H <= 1 ;										// on next edge of clock, timer will be loaded and start to time out
			Command <= PoweringUp ;									// clock enable and chip select to the Zentel Dram chip must be held low (disabled) during a power up phase
			NextState <= WaitingForPowerUpState ;				// once we have loaded the timer, go to a new state where we wait for the 100us to elapse
		end
		
		else if(CurrentState == WaitingForPowerUpState) begin
			Command <= PoweringUp ;									// no DRam clock enable or CS while witing for 100us timer
			
			if(TimerDone_H == 1) 									// if timer has timed out i.e. 100us have elapsed
				NextState <= IssueFirstNOP ;						// take CKE and CS to active and issue a 1st NOP command
			else
				NextState <= WaitingForPowerUpState ;			// otherwise stay here until power up time delay finished
		end
		
		else if(CurrentState == IssueFirstNOP) begin	 		// issue a valid NOP
			Command <= NOP ;											// send a valid NOP command to the dram chip
			DramAddress[10] 	<= 1'b1;						// Set A10 high before Precharge command
			NextState <= PrechargingAllBanks;
		end	

		else if (CurrentState == PrechargingAllBanks) begin
			Command 	<= PrechargeAllBanks;
			
			NextState	<= issue_second_NOP;

			// write to counter module early
			counter_value	<= 16'd10;
			counter_write	<= 1'b1;
		end 

		else if (CurrentState == issue_second_NOP) begin
			Command 	<= NOP; 			// issue second NOP, before issuing the following sequence of four commands 10 times: REFRESH - NOP - NOP - NOP
			
			RO_enable	<= 1'b1;
			
			
			//refresh_counter	<= 16'd10;

			NextState 	<= issue_refresh;
		end		

		else if (CurrentState == issue_refresh) begin
			Command		<= RO_command_buffer;
			RO_enable	<= 1'b1;

			counter_increment	<= 1'b1;
			
			if (counter_done == 1'b1) begin
				NextState	<= program_mode_reg;
				//counter_value	<= 16'd3;
				//counter_write	<= 1'b1;
			end else begin
				NextState	<= wait_refresh;
			end 
		end 

		else if (CurrentState == wait_refresh) begin
			Command 	<= RO_command_buffer;

			if (RO_done) begin
				NextState <= issue_refresh;
			end else begin
				NextState <= wait_refresh;
			end
		end

		else if (CurrentState == program_mode_reg) begin
			Command 	<= ModeRegisterSet;
			DramAddress <= 13'h0220;


			TimerValue	<= 16'd3;
			TimerLoad_H	<= 1;
			//counter_value	<= 16'd3;
			//counter_write	<= 1'b1;

			NextState	<= issue_NOP;
		end

		else if (CurrentState == issue_NOP) begin
			Command 	<= NOP;
			/*
			if (TimerDone_H) begin
				RefreshTimerValue	<= 16'd5;
				RefreshTimerLoad_H	<= 1;
				NextState	<= Idle;
			end else begin
				NextState 	<= issue_NOP;
			end*/
			//counter_increment	<= 1;
			if (TimerDone_H == 1) begin
				//RefreshTimerValue	<= 16'd375;
				//RefreshTimerLoad_H	<= 1;
				NextState			<= stall_idle;
			end else begin
				NextState			<= issue_NOP;
			end
		end 

		else if (CurrentState == stall_idle) begin
			Command		<= NOP;

			//DramAddress	<= 13	'hEEE;
			CPUReset_L	<= 1;
			RefreshTimerValue	<= 16'd300;					// was 375 (7.5us). Shortened to 6us so a refresh
			RefreshTimerLoad_H	<= 1;						// deferred behind a full 320-word burst (~6.5us)
															// still keeps the average interval inside the
															// 64ms/8192-row budget (7.8125us) with margin.
			//counter_value	<= 16'd20;
			//counter_write	<= 1'b1;

			NextState			<= idling;
		end 

		else if (CurrentState == idling) begin
			Command 			<= NOP;
			CPUReset_L			<= 1;
			if (RefreshTimerDone_H  == 1) begin
				NextState		<= start_RRH;
			end else if (BurstReq_H == 1) begin								// Framebuffer burst request: higher priority than CPU
				DramAddress		<= BurstAddress[23:11];						// Issue row address to SDRAM
				BankAddress		<= BurstAddress[25:24];						// Issue bank address to SDRAM
				Command			<= BankActivate;							// Open the row (ACT -> first READ spacing = 1 clock, same as CPU path)
				BurstLoad_H		<= 1;										// Latch column / bank / length into burst datapath
				NextState		<= burst_read;
			end else if ((DramSelect_L == 0) && (AS_L == 0)) begin				// CPU is accessing DRAM
				DramAddress		<= Address[23:11];								// Issue row address to SDRAM
				BankAddress		<= Address[25:24];								// Issue bank address to SDRAM
				Command			<= BankActivate; 								// Issue bank-activate command to SDRAM
				if (WE_L == 1) begin											// CPU is attempting to read from SDRAM
					NextState	<= read_SDRAM;							 	
				end else begin													// CPU is attempting to write to SDRAM 
					NextState	<= write_SDRAM;
				end 
			end else begin
				NextState		<= idling;
			end
		end

		else if (CurrentState == read_SDRAM) begin
			CPUReset_L					<= 1;									// Keep CPU reset inactive
			DramAddress[10] 			<= 1;									// Set A10 to 1 so precharge-all-banks operation is issued after the read operation
			DramAddress[9:0]			<= Address[10:1];						// Issue column address to SDRAM
			BankAddress					<= Address[25:24];						// Issue bank address to SDRAM
			Command 					<= ReadAutoPrecharge;					// Issue a read-auto-precharge command to SDRAM
			TimerLoad_H					<= 1;									// Load the timer with following value to commence CAS latency period
			TimerValue					<= 16'd2;								// Load timer to cause a latency of two clock periods
			NextState					<= read_SDRAM_wait;						// Transition to state wherein we wait for CAS latency 
		end 

		else if (CurrentState == read_SDRAM_wait) begin
			CPUReset_L					<= 1; 									// Keep CPU reset inactive
			Command						<= NOP;									// Issue NOP command to SDRAM
			DramDataLatch_H				<= 1;									// Latch data from SDRAM to data-out bus towards 68000
			if (TimerDone_H == 1) begin
				CPU_Dtack_L					<= 0;									// Issue DTAck back to 68000 once we are waiting for CAS latency
				NextState				<= terminate_bus_cycle;					// CAS latency complete, transition to bus cycle termination state
			end else begin
				CPU_Dtack_L 			<= 1;
				NextState				<= read_SDRAM_wait;						// CAS latency uncomplete, remain in current state
			end
		end

		else if (CurrentState == write_SDRAM) begin
			CPUReset_L					<= 1;									// Keep CPU reset inactive
			if ((UDS_L == 0) || (LDS_L == 0)) begin 						
				DramAddress[10]			<= 1;									// A10 on SDRAM address bus must be set to 1 for the precharge-all-banks operation
				DramAddress[9:0]		<= Address[10:1];						// Issue column address to SDRAM
				BankAddress				<= Address[25:24];						// retain bank address 
				CPU_Dtack_L				<= 0;									// Issue DTAck signal back to DTAck generator of 68000
				Command					<= WriteAutoPrecharge; 					// Issue write-auto-precharge command to SDRAM
				SDramWriteData			<= DataIn;								// Copy 68000 data-out bus to SDRAM data bus
				FPGAWritingtoSDram_H	<= 1;									// Activate bi-directional data lines so we can drive data into SDRAM memory
				NextState				<= write_SDRAM_wait;					// Transition to stalling state, as required by memory-write operations
			end else begin														// We must remain in this state until either/both UDS_L or LDS_L go low
				NextState				<= write_SDRAM;
			end
		end 

		else if (CurrentState == write_SDRAM_wait) begin
			CPUReset_L					<= 1;									// Keep CPU reset inactive
			CPU_Dtack_L					<= 0;									// Retain active DTAck signal to 68000
			Command 					<= NOP;									// Issue a NOP command to SDRAM
			SDramWriteData				<= DataIn;								// Retain 68000 data on SDRAM data bus
			FPGAWritingtoSDram_H		<= 1;									// Keep bi-directional data line active to continue writing to SDRAM
			NextState					<= terminate_bus_cycle;					// Transition to bus cycle termination state
		end 

		else if (CurrentState == terminate_bus_cycle) begin
			CPUReset_L					<= 1;									// Keep CPU reset inactive
			Command 					<= NOP;									// Issue NOP command to SDRAM
			if ((UDS_L == 0) || (LDS_L == 0)) begin								// If either UDS_L or LDS_L is still 0, then the 68000 is not done with the current bus cycle
				CPU_Dtack_L				<= 0;									// Continue issuing DTAck signal to 68000
				NextState				<= terminate_bus_cycle;					// Stay in this state until the current bus cycle is complete
			end else begin
				NextState				<= idling;
			end
		end 

		else if (CurrentState == wait_refresh_request) begin
			Command 			<= RRH_command_buffer;
			DramAddress[10] 	<= A10_buffer;
			CPUReset_L	<= 1;
			if (RRH_done) begin
				NextState			<= stall_idle;
			end else begin
				NextState	<= wait_refresh_request;
			end	
		end 

		else if (CurrentState == start_RRH) begin
			RRH_enable		<= 1;
			CPUReset_L	<= 1;
			NextState		<= wait_refresh_request;
		end

		// ── Burst read states ────────────────────────────────────────────────

		else if (CurrentState == burst_read) begin
			CPUReset_L					<= 1;									// Keep CPU reset inactive
			Command						<= ReadOnly;							// READ with NO auto-precharge (row stays open)
			DramAddress[10]				<= 0;									// A10 = 0: no auto-precharge
			DramAddress[9:0]			<= BurstCol;							// current column (increments every clock)
			BankAddress					<= BurstBankReg;						// bank latched at grant
			BurstStep_H					<= 1;									// advance column / decrement remaining / feed pipe
			if (BurstRemain <= 10'd1)											// last READ being issued this cycle
				NextState				<= burst_drain;
			else
				NextState				<= burst_read;
		end

		else if (CurrentState == burst_drain) begin
			CPUReset_L					<= 1;									// Keep CPU reset inactive
			Command						<= NOP;									// let the in-flight reads complete
			if (BurstPipe == 3'b000)											// all issued words latched and consumed
				NextState				<= burst_precharge;
			else
				NextState				<= burst_drain;
		end

		else if (CurrentState == burst_precharge) begin
			CPUReset_L					<= 1;									// Keep CPU reset inactive
			Command						<= PrechargeSelectBank;					// close the row (A10 = 0, selected bank only)
			DramAddress[10]				<= 0;
			BankAddress					<= BurstBankReg;
			NextState					<= burst_finish;
		end

		else if (CurrentState == burst_finish) begin
			CPUReset_L					<= 1;									// Keep CPU reset inactive
			Command						<= NOP;									// one NOP gives tRP spacing before next ACT
			BurstDone_H					<= 1;									// tell requester the burst is complete
			NextState					<= idling;
		end

		else begin
			CPUReset_L					<= 1;
			Command 					<= NOP;
			NextState					<= idling;
		end
	end	

	refresh_operator 		RO_0 	(.clk(Clock), .rst_n(Reset_L), .enable(RO_enable), .command(RO_command_wire), .done(RO_done_wire));
	refresh_request_handler RRH_0 	(.clk(Clock), .rst_n(Reset_L), .enable(RRH_enable), .command(RRH_command_wire), .done(RRH_done_wire), .A10(A10_wire));
	counter 				C_0		(.clk(Clock), .wr_en(counter_write), .increment(counter_increment), .value(counter_value), .done(counter_done_wire));
endmodule

module counter (input clk, input wr_en, input increment, input [15:0] value, output reg done);
	reg unsigned [15:0] counter;
	
	always @(posedge clk) begin
		if (wr_en == 1) begin
			counter 	<= value;
		end else if (counter != 16'd0) begin
			if (increment == 1'b1) begin
				counter 	<= counter - 16'd1;
			end else begin
				counter 	<= counter;
			end
		end  else begin
			counter 		<= counter;
		end
	end
	
	always @(counter) begin
		done 		<= 1'b0;
		if (counter == 16'd0) begin
			done 	<= 1'b1;
		end
	end
endmodule 

module refresh_request_handler (input clk, input enable, input rst_n, output reg [4:0] command, output reg done, output reg A10);
	// 5 bit Commands to the SDRam
	parameter NOP = 5'b10111;								// address and bank address = dont'care
	parameter AutoRefresh = 5'b10001;
	parameter PrechargeAllBanks = 5'b10010;			// A10 should be logic 1, BA0, BA1 are dont'care, other addreses = don't care

	// States
	parameter IDLE		= 5'h00;
	parameter REFRESH	= 5'h01;
	parameter ISSUE_NOP = 5'h02;
	parameter PRECHARGE = 5'h03;
	parameter LOOP_NOP 	= 5'h04;

	reg [3:0] counter;
	reg [4:0] buffer;
	reg buffer_A10;
	reg enable_NOP;
	reg unsigned [4:0] state;
	reg unsigned [4:0] next_state;
	reg	TimerLoad_H ;										// logic 1 to load Timer on next clock
	reg TimerDone_H ;										// set to logic 1 when timer reaches 0
	reg unsigned [15:0] Timer;							// 16 bit timer value
	reg unsigned [15:0] TimerValue;					// 16 bit timer preload value

	always @(posedge clk)
		if(TimerLoad_H == 1) 				// if we get the signal from another process to load the timer
			Timer <= TimerValue ;			// Preload timer
		else if(Timer != 16'd0) 			// otherwise, provided timer has not already counted down to 0, on the next rising edge of the clock		
			Timer <= Timer - 16'd1 ;		// subtract 1 from the timer value

	always @(Timer) begin
		TimerDone_H <= 0 ;					// default is not done
	
		if(Timer == 16'd0) 					// if timer has counted down to 0
			TimerDone_H <= 1 ;				// output '1' to indicate time has elapsed
	end

	always@(posedge clk, negedge rst_n)
	begin
		if(rst_n == 0) 							// asynchronous reset
			state <= IDLE;
		else begin									// state can change only on low-to-high transition of clock
			state 		<= next_state;		
			command 	<= buffer;
			A10			<= buffer_A10;
		end
	end	

	always @(*) begin	
		buffer 		<= NOP;
		buffer_A10	<= 1'b0;
		next_state	<= IDLE;
		TimerValue	<= 16'd0;
		TimerLoad_H	<= 0;
		done 		<= 1'b0;
	
		if(state == IDLE) begin
			if (enable) begin
				next_state	<= PRECHARGE;
				buffer_A10	<= 1'b1;
				done 		<= 1'b0;
			end else begin
				next_state	<= IDLE;
				done 		<= 1'b1;
			end
		end
	
		else if (state == PRECHARGE) begin
			buffer	<= PrechargeAllBanks;
			next_state	<= ISSUE_NOP;
		end
		
		else if (state == ISSUE_NOP) begin
			buffer	<= NOP;

			next_state	<= REFRESH;
		end

		else if (state == REFRESH) begin
			buffer 	<= AutoRefresh;

			TimerValue	<= 16'd3;
			TimerLoad_H	<= 1;

			next_state	<= LOOP_NOP;
		end

		else if (state == LOOP_NOP) begin
			buffer 	<= NOP;

			if (TimerDone_H) begin
				next_state 	<= IDLE;
				done 		<= 1;
			end else begin
				next_state 	<= LOOP_NOP;
			end
		end
	end
endmodule 


module refresh_operator (input clk, input enable, input rst_n, output reg [4:0] command, output reg done);
	// 5 bit Commands to the SDRam
	parameter NOP = 5'b10111;								// address and bank address = dont'care
	parameter AutoRefresh = 5'b10001;

	// States
	parameter IDLE		= 5'h00;
	parameter REFRESH	= 5'h01;
	parameter ISSUE_NOP = 5'h02;

	reg [3:0] counter;
	reg [4:0] buffer;
	reg enable_NOP;
	reg unsigned [4:0] state;
	reg unsigned [4:0] next_state;
	reg	TimerLoad_H ;										// logic 1 to load Timer on next clock
	reg TimerDone_H ;										// set to logic 1 when timer reaches 0
	reg unsigned [15:0] Timer;							// 16 bit timer value
	reg unsigned [15:0] TimerValue;					// 16 bit timer preload value


	always @(posedge clk)
		if(TimerLoad_H == 1) 				// if we get the signal from another process to load the timer
			Timer <= TimerValue ;			// Preload timer
		else if(Timer != 16'd0) 			// otherwise, provided timer has not already counted down to 0, on the next rising edge of the clock		
			Timer <= Timer - 16'd1 ;		// subtract 1 from the timer value

	always @(Timer) begin
		TimerDone_H <= 0 ;					// default is not done
	
		if(Timer == 16'd0) 					// if timer has counted down to 0
			TimerDone_H <= 1 ;				// output '1' to indicate time has elapsed
	end

	always@(posedge clk, negedge rst_n)
	begin
		if(rst_n == 0) 							// asynchronous reset
			state <= IDLE;
		else begin									// state can change only on low-to-high transition of clock
			state 		<= next_state;		
			command 	<= buffer;
		end
	end	

	always @(*) begin	
		buffer 		<= NOP;
		next_state	<= IDLE;
		TimerValue	<= 16'd0;
		TimerLoad_H	<= 0;
		done 		<= 1'b0;
	
		if(state == IDLE) begin
			if (enable) begin
				next_state	<= REFRESH;
				done 		<= 1'b0;
			end else begin
				next_state	<= IDLE;
				done 		<= 1'b1;
			end
		end
	
		else if (state == REFRESH) begin
			buffer	<= AutoRefresh;
			TimerValue	<= 16'd3;
			TimerLoad_H	<= 1'b1;
			next_state	<= ISSUE_NOP;
		end
		
		else if (state == ISSUE_NOP) begin
			buffer	<= NOP;

			if (TimerDone_H) begin
				next_state 	<= IDLE;
				done 		<= 1'b1;
			end else begin
				next_state 	<= ISSUE_NOP;
			end
		end
	end
endmodule
