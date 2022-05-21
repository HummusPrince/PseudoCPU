module switch
    #(parameter P_WIDTH=32) (
        input   [P_WIDTH-1:0] ain, bin,
        output  [P_WIDTH-1:0] aout, bout,
        input sel)

    always @(sel, ain, bin) begin
        case(sel)
            1'b0: begin
                aout = ain;
                bout = bin;
            end

            1'b1: begin
                aout = bin;
                bout = ain;
            end

            default: begin
                aout = {P_WIDTH{1'bx}};
                bout = {P_WIDTH{1'bx}};
            end
        endcase
    end
endmodule
