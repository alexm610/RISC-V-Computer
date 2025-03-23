module address_decoder (
        input logic [9:0] Address, 
 
        output logic RAM_Select_H,
        output logic IO_Select_H,
		output logic Graphics_Select_H
);

	always @(*) begin
		RAM_Select_H		<= 0;
		IO_Select_H			<= 0;
		Graphics_Select_H	<= 0;

		if ((Address >= 10'h000) && (Address <= 10'h3FF)) begin
			RAM_Select_H		<= 1;
		end

		if ((Address >= 10'h400) && (Address <= 10'h40F)) begin
			IO_Select_H			<= 1;
		end

		if ((Address >= 10'h410) && (Address <= 10'h41F)) begin
			Graphics_Select_H	<= 1;
		end
	end
endmodule: address_decoder
