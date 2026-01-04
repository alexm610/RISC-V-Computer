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
    logic [31:0] reload_value;
    logic [31:0] Timer;

    wire bus_wr = (AS_L == 1'b0) && (WE_L == 1'b0);
    wire bus_rd = (AS_L == 1'b0) && (WE_L == 1'b1);

    wire timer_enable = control_reg[0];
    wire irq_enable   = control_reg[1];

    // COMBINATIONAL readback (safer for simple MMIO)
    always_comb begin
        if (control_reg_select)      data_out = {30'b0, control_reg};
        else if (data_reg_select)    data_out = Timer;
        else                         data_out = 32'h0;
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            control_reg  <= 2'b00;
            reload_value <= 32'h0;
            Timer        <= 32'h0;
            irq_out      <= 1'b0;
        end else begin
            // -------------------------
            // CPU writes
            // -------------------------
            if (bus_wr) begin
                if (data_reg_select) begin
                    reload_value <= data_in;
                end

                if (control_reg_select) begin
                    control_reg <= data_in[1:0];

                    // ACK any pending IRQ on control write
                    irq_out <= 1'b0;

                    // reload whenever control is written
                    Timer <= reload_value;
                end
            end

            // -------------------------
            // Timer logic (one-shot)
            // -------------------------
            if (!bus_wr && !bus_rd) begin
                if (timer_enable && (irq_out == 1'b0)) begin
                    if (Timer != 32'd0) begin
                        Timer <= Timer - 32'd1;
                    end else begin
                        if (irq_enable) irq_out <= 1'b1;
                    end
                end
            end
        end
    end

endmodule
