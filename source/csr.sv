module csr (
    input logic             clock,
    input logic             reset_L,
    input logic             WE_L,
    input logic     [11:0]  address,
    input logic     [31:0]  write_data,
    output logic    [31:0]  read_data,

    input logic             irq_software,
    input logic             irq_timer,
    input logic             irq_external,

    output logic            mstatus_MIE,
    output logic            mstatus_MPIE,
    output logic    [1:0]   mstatus_MPP,

    output logic            mie_MSIE,
    output logic            mie_MTIE,
    output logic            mie_MEIE,

    output logic            mip_MSIP,
    output logic            mip_MTIP,
    output logic            mip_MEIP,

    output logic    [1:0]   mtvec_MODE,
    output logic    [29:0]  mtvec_BASE,

    output logic    [31:0]  mepc_REG,
    output logic    [31:0]  mcause_REG
);

    logic [31:0] mstatus, mie, mtvec, mepc, mcause, mip;

    assign mstatus_MIE      = mstatus[3];
    assign mstatus_MPIE     = mstatus[7];
    assign mstatus_MPP      = mstatus[12:11];
    assign mie_MSIE         = mie[3];
    assign mie_MTIE         = mie[7];
    assign mie_MEIE         = mie[11];
    assign mip_MSIP         = mip[3];
    assign mip_MTIP         = mip[7];
    assign mip_MEIP         = mip[11];
    assign mtvec_MODE       = mtvec[1:0];
    assign mtvec_BASE       = mtvec[31:2];
    assign mepc_REG         = mepc;
    assign mcause_REG       = mcause;


    assign mip              = {20'b0, irq_external, 3'b0, irq_timer, 3'b0, irq_software, 3'b0};

    always @(*) begin
        case (address) 
            12'h300: read_data <= mstatus;
            12'h304: read_data <= mie;
            12'h305: read_data <= mtvec;
            12'h341: read_data <= mepc;
            12'h342: read_data <= mcause;
            12'h344: read_data <= mip;
            default: read_data <= 32'h0;
        endcase
    end

    always @(posedge clock or negedge reset_L) begin
        if (reset_L == 0) begin
            mstatus <= 32'h0;
            mie     <= 32'h0;
            mtvec   <= 32'h0;
            mepc    <= 32'h0;
            mcause  <= 32'h0;
            //mip     <= 32'h0;
        end else if (WE_L == 0) begin
            case (address) 
                12'h300: mstatus    <= write_data;
                12'h304: mie        <= write_data;
                12'h305: mtvec      <= write_data;
                12'h341: mepc       <= write_data;
                12'h342: mcause     <= write_data;
                //12'h344: mip        <= write_data;
            endcase
        end
    end
endmodule: csr