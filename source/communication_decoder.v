module communication_decoder (
    input logic [31:0] Address,
    input logic IOSelect,
    input logic AS_L,
    output logic ACIA1_Port_Enable,
    output logic ACIA1_Baud_Enable
);
    always @(*) begin
        ACIA1_Port_Enable   <= 0;
        ACIA1_Baud_Enable   <= 0;

        if (IOSelect == 1) begin
            if ((Address[15] == 1) && (AS_L == 0)) begin
                if ((Address[3:0] == 4'h0) || (Address[3:0] == 4'h4)) begin
                    ACIA1_Port_Enable   <= 1;
                end

                if (Address[3:0] == 4'h8) begin
                    ACIA1_Baud_Enable   <= 1;
                end
            end
        end
    end
endmodule
