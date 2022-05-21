module comp
    #(parameter P_WIDTH=32) (
        input   [P_WIDTH-1:0] a,
        input   [P_WIDTH-1:0] b,
        input   [2-1:0] sel,
        output  cres
    )

    always @(a or b or sel) begin
        case(sel)
            2'b00: cres = (a == b);
            2'b01: cres = (a >= b);
            2'b10: cres = a[0];
            default: cres = 1'bx;
        endcase
    end

endmodule
