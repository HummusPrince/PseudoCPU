module top
    #(parameter P_WIDTH=32,
    parameter P_LOG_MEMSIZE = 4,
    parameter P_NUM_D_CTRLBITS = 5,
    parameter P_NUM_C_CTRLBITS = 2) (
        input rst,
        input clk,
        input en);
    
    reg [P_WIDTH-1:0] a, b;

    wire [P_WIDTH-1:0] a_sw, b_sw, d_res;
    wire wa, wb, sw, c_res;
    wire [2-1:0] op;

    switch #(.P_WIDTH(P_WIDTH))
        i_switch (
            .ain(a),
            .bin(b),
            .aout(a_sw),
            .bout(b_sw),
            .sel(sw));

    compdata #(.P_WIDTH(P_WIDTH))
        d_path (
            .a(a_sw),
            .b(b_sw),
            .dres(d_res),
            .op(op));

    compctl #(.P_WIDTH(P_WIDTH))
        c_path (
            .a(a_sw),
            .b(b_sw),
            .cres(c_res),
            .op(op));


    control #(.P_LOG_MEMSIZE(P_LOG_MEMSIZE),
            .P_NUM_D_CTRLBITS(P_NUM_D_CTRLBITS),
            .P_NUM_C_CTRLBITS(P_NUM_C_CTRLBITS))
        ctrl (
            .cres(c_res),
            .rst(rst),
            .clk(clk),
            .en(en),
            .dp_ctrl({op, sw, wb, wa}));

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            a <= 0;
            b <= 0;
        end
        else begin
            if(en) begin
                if (wa) a <= d_res;
                if (wb) b <= d_res;
            end
        end
    end
endmodule
