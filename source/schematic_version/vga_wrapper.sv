module vga_wrapper (
	input logic Clock,
	input logic Reset_n,
	input logic [2:0] Colour,
	input logic [7:0] Fill_x,
	input logic [6:0] Fill_y,
	input logic Fill_plot,
	output logic [9:0] VGA_R,
	output logic [9:0] VGA_G,
	output logic [9:0] VGA_B,
	output logic VGA_HS,
	output logic VGA_VS,
	output logic VGA_BLANK,
	output logic VGA_SYNC,
	output logic VGA_CLK
);

	
	vga_adapter #(.RESOLUTION("160x120")) VGA_0 (
        .clock(Clock),
        .resetn(Reset_n),
        .colour(Colour), // from controller
        .x(Fill_x), // from controller I need to make 
        .y(Fill_y), // from controller 
        .plot(Fill_plot),  // from controller 
        .*
    );
endmodule: vga_wrapper
	
	
	