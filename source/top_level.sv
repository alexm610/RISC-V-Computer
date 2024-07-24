module top_level    (input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
                    output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
                    output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
                    output logic [9:0] LEDR);

    cpu PROCESSOR   (.clk(CLOCK_50),
                    .rst_n(KEY[3])
                    );

    memory DATA_MEMORY          (.clock(clk),
                                .address(),
                                .data(),
                                .wren(),
                                .q(data_memory_out));

    memory INSTRUCTION_MEMORY   (.clock(clk),
                                .address(pc_out),
                                .data(), // Leave this unconnected, as we won't be writing to this memory
                                .wren(), // Do not write to instruction memory 
                                .q());

endmodule: top_level