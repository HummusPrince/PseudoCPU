module compctl
    #(parameter P_WIDTH=32) (
        input   [P_WIDTH-1:0] a,
        input   [P_WIDTH-1:0] b,
        input   [2-1:0] op,
        output reg cres
    );

    always @(a or b or op) begin
        case(op)
            2'b00: cres = (a == b);
            2'b01: cres = (a >= b);
            2'b10: cres = a[0];
            default: cres = 1'bx;
        endcase
    end

endmodule
