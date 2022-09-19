`timescale 1us/100ns

module tb;
    
    localparam LP_FIN_ADDR = 9;
    localparam LP_N_TESTS = 15;
    localparam LP_WIDTH = 32;

    reg clk, rst, en;
    reg [LP_WIDTH - 1 : 0] a [LP_N_TESTS - 1 : 0];
    reg [LP_WIDTH - 1 : 0] b [LP_N_TESTS - 1 : 0];
    reg [LP_WIDTH - 1 : 0] g [LP_N_TESTS - 1 : 0];
    integer testnum;

    top #() i_top (
        .rst(rst),
        .clk(clk),
        .en(en));

    task compute_gcd(input [32 - 1 : 0] a, b, g);
        begin
        $display("a = %d (0x%x)", a, a);
        $display("b = %d (0x%x)", b, b);
        rst = 1;
        en = 0;
        #10
        rst = 0;
        #10
        i_top.a = a;
        i_top.b = b;
        #10 en = 1;
        while(i_top.ctrl.addr != LP_FIN_ADDR) #10;
        #100;
        if(i_top.a != g) begin
            $display("Test fail!!!!!!!!!!!!!!!!!!!");
            $display("Got %d when expected %d\n", i_top.a, g);
        end
        else begin
            $display("Test passed\n");
        end
        end
    endtask

    always #5 clk = !clk;

    initial begin
        $readmemb("./src/bin/eq_zero_optimized.b", i_top.ctrl.imem);
        //$readmemb("./PcpuAssembler/euclid.b", i_top.ctrl.imem);
        $readmemb("./sim/vectors/a.b", a);
        $readmemb("./sim/vectors/b.b", b);
        $readmemb("./sim/vectors/g.b", g);
        clk = 1;
        for(testnum = 0; testnum < LP_N_TESTS; testnum = testnum + 1) begin
            $display("Running test %0d...", testnum);
            compute_gcd(a[testnum],b[testnum],g[testnum]);
        end
        $finish;
    end

    initial begin
        $dumpfile("./sim.vcd");
        $dumpvars;
    end
endmodule
