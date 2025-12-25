module timer (
    input  logic        clk,
    input  logic        reset_n,

    input  logic        WE_L,
    input  logic        AS_L,
    input  logic        data_reg_select,
    input  logic        control_reg_select,
    input  logic [31:0] data_in,
    output logic [31:0] data_out,
    output logic        irq_out
);

    logic [1:0]  control_reg;    // [0]=enable, [1]=irq enable
    logic [31:0] reload_value;   // load value
    logic [31:0] Timer;          // countdown

    // COMBINATIONAL enables (NOT flops)
    logic timer_enable;
    logic irq_enable;
    assign timer_enable = control_reg[0];
    assign irq_enable   = control_reg[1];

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            control_reg   <= 2'b00;
            reload_value  <= 32'h0;
            Timer         <= 32'h0;
            data_out      <= 32'h0;
            irq_out       <= 1'b0;

        end else begin

            // -------------------------
            // CPU writes
            // -------------------------
            if (AS_L == 0 && WE_L == 0) begin

                if (data_reg_select) begin
                    reload_value <= data_in;
                end

                if (control_reg_select) begin
                    control_reg <= data_in[1:0];

                    // CPU acknowledgement
                    irq_out <= 1'b0;

                    // Reload on control write (your intended behavior)
                    Timer <= reload_value;
                end
            end

            // -------------------------
            // CPU reads
            // -------------------------
            else if (AS_L == 0 && WE_L == 1) begin
                if (data_reg_select)
                    data_out <= Timer;
                else if (control_reg_select)
                    data_out <= {30'b0, control_reg};
            end

            // -------------------------
            // Timer logic (one-shot)
            // -------------------------
            else begin
                if (timer_enable && (irq_out == 1'b0)) begin
                    if (Timer != 0) begin
                        Timer <= Timer - 1;
                    end else begin
                        if (irq_enable)
                            irq_out <= 1'b1;
                        // Timer stays at 0 until CPU ACK (control write)
                    end
                end
            end
        end
    end
endmodule
