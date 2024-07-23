module cpu (input clk, input rst_n, output hex1);

    datapath HW (.clk(clk),
                .rst_n(rst_n),
                .rb_wren(),
                .alu_control(),
                )

    register #(32) PC           (.clk(clk),
                                .reset(rst_n),
                                .in(pc_in),
                                .enable(pc_en),
                                .out(pc_out));

endmodule: cpu