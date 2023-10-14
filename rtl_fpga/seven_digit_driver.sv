module seven_digit_driver
(
    input [3:0] number,
    output reg [6:0] seven_digit_data
);

    always@(number)
    case(number)
        4'h0 : seven_digit_data = ~7'b0111111;
        4'h1 : seven_digit_data = ~7'b0000110;
        4'h2 : seven_digit_data = ~7'b1011011;
        4'h3 : seven_digit_data = ~7'b1001111;
        4'h4 : seven_digit_data = ~7'b1100110;
        4'h5 : seven_digit_data = ~7'b1101101;
        4'h6 : seven_digit_data = ~7'b1111101;
        4'h7 : seven_digit_data = ~7'b0000111;
        4'h8 : seven_digit_data = ~7'b1111111;
        4'h9 : seven_digit_data = ~7'b1101111;
        4'ha : seven_digit_data = ~7'b1110111;
        4'hb : seven_digit_data = ~7'b1111100;
        4'hc : seven_digit_data = ~7'b0111001;
        4'hd : seven_digit_data = ~7'b1011110;
        4'he : seven_digit_data = ~7'b1111001;
        4'hf : seven_digit_data = ~7'b1110001;
    endcase

endmodule
