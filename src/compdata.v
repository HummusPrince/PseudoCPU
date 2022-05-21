module shift
    #(parameter P_WIDTH=32) (
        input   [P_WIDTH-1:0] a,b,
        output  [P_WIDTH-1:0] dres,
        input [2-1:0] sel)

    always @(sel, a, b) begin
        case(sel)
            2'b00: dres = (a >> 1);
            2'b01: dres = (a - b);
            default: dres = {P_WIDTH{1'bx}};
        endcase
    end
endmodule
