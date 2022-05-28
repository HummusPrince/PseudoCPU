module control
    #(parameter P_LOG_MEMSIZE = 4,
    parameter P_NUM_D_CTRLBITS = 5,
    parameter P_NUM_C_CTRLBITS = 2) (
        input cres,
        input rst,
        output [P_NUM_D_CTRLBITS-1:0] dp_ctrl)
    
    //Local parameters
    localparam LP_WORDWIDTH = P_LOG_MEMSIZE+P_NUM_D_CTRLBITS+P_NUM_C_CTRLBITS;
    localparam LP_MEMSIZE = 1<<P_LOG_MEMSIZE;
    localparam LP_D_IDX = LP_WORDWIDTH-1;
    localparam LP_C_IDX = P_NUM_C_CTRLBITS+P_LOG_MEMSIZE-1;
    localparam LP_A_IDX = P_LOG_MEMSIZE-1;
    localparam LP_JC_IDX = LP_C_IDX; 
    localparam LP_JU_IDX = LP_C_IDX-1; 

    //Registers
    reg [LP_WORDWIDTH-1:0] imem [0:LP_MEMSIZE-1];   //Uninitialized!!!
    reg [P_LOG_MEMSIZE-1:0] addr;

    wire [P_LOG_MEMSIZE-1:0] j_addr = imem[addr][LP_A_IDX -:P_LOG_MEMSIZE];
    wire ju = imem[addr][LP_JU_IDX];
    wire jc = imem[addr][LP_JC_IDX];

    assign dp_ctrl = imem[addr][LP_D_IDX-:P_NUM_D_CTRLBITS];

    //addr logic
    always @(posedge clk, posedge rst) begin
        if(rst) addr <= 0;
        else begin
            addr <= ((cres&jc)|ju) ? j_addr : addr+1;
        end
    end
endmodule
