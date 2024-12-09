module interconnect_fabric  (input logic clk, input logic rst_n, 
                            // Slave (CPU-facing)
                            output logic [NUM_SLAVES-1:0] slave_ready,
                            input logic [9:0] slave_address,
                            input logic slave_read, input logic slave_write,
                            input logic slave_writedata, output logic [31:0] slave_readdata,
                            // Master (Peripheral-facing)
                            input logic [NUM_SLAVES-1:0] master_ready,
                            output logic [NUM_SLAVES-1:0] master_enable,
                            output logic [31:0] master_address,
                            output logic [NUM_SLAVES-1:0] master_read, output logic master_write,
                            output logic [31:0] master_writedata, input logic [31:0] master_readdata [NUM_SLAVES]);
    parameter NUM_SLAVES = 1;
    logic [NUM_SLAVES-1:0] slave_module;

    // let RAM be in range:     0x00 - 0x7f
    // let SW be in range:      0x80 - 0x8f
    // let LEDR be in range:    0x90 - 0x9f

    always @(*) begin   
        if ((slave_address >= 32'h0) && (slave_address <= 32'h7f)) begin
            slave_module = 32'd1;   // RAM selected 
        end else if ((slave_address >= 32'h80) && (slave_address <= 32'h8f)) begin
            slave_module = 32'd2;   // SW selected 
        end else if ((slave_address >= 32'h90) && (slave_address <= 32'h9f)) begin
            slave_module = 32'd4;   // LEDR selected 
        end else begin 
            slave_module = 32'd0;   // this shouldn't happen; nothing selected
        end  
    end

    always @(*) begin
        case (slave_module)
            32'd1: begin
                master_address = slave_address;
                slave_readdata = 
            end
        endcase 
    end

endmodule interconnect_fabric