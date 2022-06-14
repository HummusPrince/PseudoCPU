module tb;
    reg clk, rst;

    top #() i_top (
        .rst(rst),
        .clk(clk));

    always #5 clk = !clk;

    initial begin
        $readmemb("./src/bin/eq_zero_optimized.b", i_top.ctrl.imem);
        rst = 0;
        #10
        rst = 1;
        #5
        i_top.a = 4123481;
        i_top.b = 9402102;
        #5;
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
