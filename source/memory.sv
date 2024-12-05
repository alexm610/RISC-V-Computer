module memory   (input logic clock, input logic reset_n, input logic write,
                input logic [9:0] address,
                input logic [31:0] writedata,
                output logic [7:0] readbyte,
                output logic [31:0] readword);

    logic [7:0] word_address, byte0, byte1, byte2, byte3;
    logic [31:0] word;
    logic [7:0] memory [0:1023];

    assign word_address = address[9:2];
    assign word         = memory[word_address];
    assign byte0        = memory[address + 32'h0];
    assign byte1        = memory[address + 32'h1];
    assign byte2        = memory[address + 32'h2];
    assign byte3        = memory[address + 32'h3];

    always @(posedge clock) begin
        if (!reset_n) begin
            readword <= 32'h0;
            readbyte <= 8'h0;
        end else begin
            if (write) begin
                memory[address + 32'h0] <= writedata[7:0];
                memory[address + 32'h1] <= writedata[15:8];
                memory[address + 32'h2] <= writedata[23:16];
                memory[address + 32'h3] <= writedata[31:24];
            end

            readword <= {byte3, byte2, byte1, byte0};
            
            case (address[1:0])
                2'b00: readbyte <= byte0;
                2'b01: readbyte <= byte1;
                2'b10: readbyte <= byte2;
                2'b11: readbyte <= byte3;
            endcase
        end
    end
endmodule: memory