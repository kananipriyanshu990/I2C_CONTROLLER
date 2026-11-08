`timescale 1ns/1ps
module I2C_CLOCK_GENERATOR_TB;

    reg CLK;
    reg RST_N;
    reg ENABLE;
    
    wire SCL;
    wire SCL_TICK;
    
    integer HIGH_COUNT;
    integer LOW_COUNT;
    integer TICK_COUNT;
    
    I2C_CLOCK_GENERATOR I2C_CLK_GEN (.CLK(CLK),
                                     .RST(RST_N),
                                     .ENABLE(ENABLE),
                                     .SCL(SCL),
                                     .SCL_TICK(SCL_TICK));
    
    always #5 CLK = ~CLK;
    
    initial begin
        CLK = 0;
        RST_N = 0;
        ENABLE = 0;

        TICK_COUNT = 0;
        
        repeat (5) @(posedge CLK);
        
        RST_N = 1;
        
        repeat (100) @(posedge CLK);
        
        ENABLE = 1;
        
        repeat (500) @(posedge CLK);
        #1;
        
        repeat (20000) begin
            @(posedge CLK);
            #1;
            
            if(SCL_TICK)
                TICK_COUNT = TICK_COUNT + 1;
        end
        
        ENABLE = 0;
    end
endmodule