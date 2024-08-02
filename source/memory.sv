module memory   (input logic clock, input logic reset_n, input logic write,
                input logic [9:0] address,
                input logic [31:0] writedata,
                output logic [7:0] readbyte,
                output logic [31:0] readword);

    logic [7:0] word_address;
    logic [31:0] word;
    logic [31:0] memory [0:1023];

    assign word_address = address[9:2];
    assign word         = memory[word_address];

    always @(posedge clock) begin
        if (!reset_n) begin
            readword <= 32'h0;
            readbyte <= 8'h0;
        end else begin
            if (write) begin
                memory[word_address] <= writedata;
            end

            readword <= word;
            
            case (address[1:0])
                2'b00: readbyte <= word[7:0];
                2'b01: readbyte <= word[15:8];
                2'b10: readbyte <= word[23:16];
                2'b11: readbyte <= word[31:24];
            endcase
        end
    end

endmodule: memory