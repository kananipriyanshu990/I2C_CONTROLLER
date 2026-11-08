module I2C_TOP(input wire CLK, 
               input wire RST_N, 
               input wire START, 
               input wire READ,
               input wire [6:0] SLAVE_ADDR, 
               input wire [7:0] DATA_IN,
               inout wire SDA,
               output wire SCL, 
               output wire [7:0] DATA_OUT, 
               output wire DATA_VALID,
               output wire MASTER_BUSY, 
               output wire SLAVE_BUSY,
               output wire DONE, 
               output wire ACK_ERROR, 
               output wire MASTER_ACK);
               
    wire SCL_TICK, SCL_ENABLE;
    wire M_SDA_OUT, M_SDA_OE, S_SDA_OUT, S_SDA_OE;
    wire [7:0] MASTER_DATA, SLAVE_DATA;
    wire MASTER_VALID, SLAVE_VALID;
    wire SDA_IN = SDA;

    assign SDA = M_SDA_OE ? M_SDA_OUT : 1'bz;
    assign SDA = S_SDA_OE ? S_SDA_OUT : 1'bz;
    assign DATA_OUT = MASTER_VALID ? MASTER_DATA : SLAVE_DATA;
    assign DATA_VALID = MASTER_VALID | SLAVE_VALID;

    I2C_CLOCK_GENERATOR CLOCK(.SCL(SCL), 
                                .SCL_TICK(SCL_TICK),
                                .ENABLE(SCL_ENABLE), 
                                .CLK(CLK), 
                                .RST_N(RST_N));
        
    I2C_MASTER MASTER(.SCL_ENABLE(SCL_ENABLE), 
                        .SDA_OUT(M_SDA_OUT),
                        .SDA_OE(M_SDA_OE), 
                        .BUSY(MASTER_BUSY),
                        .DONE(DONE),
                        .ACK_ERROR(ACK_ERROR), 
                        .SLAVE_ADDR(SLAVE_ADDR), 
                        .DATA_IN(DATA_IN),
                        .READ(READ), 
                        .START(START), 
                        .SCL(SCL), 
                        .SCL_TICK(SCL_TICK), 
                        .SDA_IN(SDA_IN),
                        .CLK(CLK), 
                        .RST_N(RST_N), 
                        .DATA_OUT(MASTER_DATA), 
                        .DATA_VALID(MASTER_VALID));
        
    I2C_CONTROLLER SLAVE(.CLK(CLK), 
                           .RST_N(RST_N),
                           .SLAVE_ADDR(SLAVE_ADDR), 
                           .DATA_IN(DATA_IN), 
                           .SCL(SCL),
                           .SDA_IN(SDA_IN), 
                           .SDA_OUT(S_SDA_OUT), 
                           .SDA_OE(S_SDA_OE),
                           .DATA_OUT(SLAVE_DATA), 
                           .DATA_VALID(SLAVE_VALID),
                           .BUSY(SLAVE_BUSY), 
                           .MASTER_ACK(MASTER_ACK));
                           
endmodule
