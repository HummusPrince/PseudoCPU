`timescale 1us/100ns

module tb;
    reg clk, rst, en;

    top #() i_top (
        .rst(rst),
        .clk(clk),
        .en(en));

    always #5 clk = !clk;

    initial begin
        $readmemb("./src/bin/eq_zero_optimized.b", i_top.ctrl.imem);
        clk = 1;
        rst = 1;
        en = 0;
        #10
        rst = 0;
        #10
        i_top.a = 4123481;
        i_top.b = 9402102;
        #10 en = 1;
        #10000;
        //while(top.control.addr != 9) #10;
        #100;
        $finish;
    end

    initial begin
        $dumpfile("./sim.vcd");
        $dumpvars;
    end
endmodule
