module vga_control  (input logic clk, input logic rst_n, input logic start, input logic VGA_Select,
                    input logic [31:0] data_in,
                    output logic ready, output logic vga_plot,
                    output logic [2:0] vga_colour, 
                    output logic [6:0] vga_y, 
                    output logic [7:0] vga_x);  
    
    // y-position:  data_in[30:24]
    // x-position:  data_in[23:16]
    // colour:      data_in[7:0]
    
    assign vga_plot     = ((VGA_Select == 1) && (start == 0)) ? ((data_in[23:16] >= 8'd0 && data_in[23:16] < 8'd160 && data_in[30:24] >= 7'd0 && data_in[30:24] < 7'd120) ? 1 : 0) : 0;
    //assign vga_plot     = (data_in[23:16] >= 8'd0 && data_in[23:16] < 8'd160 && data_in[30:24] >= 7'd0 && data_in[30:24] < 7'd120) ? 1 : 1'b0;
    assign vga_x        = data_in[23:16];
    assign vga_y        = data_in[30:24];
    assign vga_colour   = data_in[7:0];
endmodule: vga_control