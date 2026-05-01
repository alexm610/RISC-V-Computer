module SPI_BUS_Decoder (
	input unsigned [31:0] Address,
	input SPI_Select_H,
	input AS_L,
	output reg SPI_Enable_H);
	
	always @(*) begin
		SPI_Enable_H	<= 0;
		
		if ((AS_L == 0) && (SPI_Select_H == 1) && (Address >= 32'h00408020) && (Address <= 32'h00408033)) begin
			SPI_Enable_H <= 1;
		end
	end
endmodule

//0000 0000 0100 0000 1000 0000 0010 0000
//0000 0000 0100 0000 1000 0000 0010 1111