module tb;
    reg clk, rst

    top #() top (
        .rst(rst),
        .clk(clk));

    always #5 clk = !clk;

    initial begin
        $readmemb("../src/bin/eq_zero_optimized.bin", top.control.imem);
        rst = 0;
        #10
        rst = 1;
        #5
        top.a = 4123481;
        top.b = 9402102;
        #5;
        #10000;
        //while(top.control.addr != 9) #10;
        #100;
        $finish;
    end
endmodule
