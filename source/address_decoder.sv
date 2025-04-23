module address_decoder (
        input logic [31:0] Address, 
	
		output logic ROM_Select_H,
        output logic RAM_Select_H,
        output logic IO_Select_H,
		output logic Graphics_Select_H
);

	always @(*) begin
		ROM_Select_H		<= 0;
		RAM_Select_H		<= 0;
		IO_Select_H			<= 0;
		Graphics_Select_H	<= 0;

		if ((Address >= 32'h00000000) && (Address <= 10'h00000FFF)) begin
			ROM_Select_H		<= 1;
		end

		if ((Address >= 32'h04000000) && (Address <= 32'h0400FFFF)) begin
			IO_Select_H			<= 1;
		end

		if ((Address >= 32'h04010000) && (Address <= 32'h0401000F)) begin
			Graphics_Select_H	<= 1;
		end

		if ((Address >= 32'h08000000) && (Address <= 32'h0BFFFFFF)) begin
			RAM_Select_H 		<= 1;
		end
	end
endmodule: address_decoder
