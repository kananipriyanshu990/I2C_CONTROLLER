`timescale 1ns/1ps

module I2C_MASTER_TB;

    reg CLK;
    reg RST_N;

    reg START;
    reg [6:0] SLAVE_ADDR;
    reg [7:0] DATA_IN;

    reg SDA_IN;

    wire SCL;
    wire SCL_TICK;

    wire SCL_ENABLE;
    wire SDA_OUT;
    wire SDA_OE;

    wire BUSY;
    wire DONE;
    wire ACK_ERROR;

    wire SDA;

    assign SDA = SDA_OE ? SDA_OUT : 1'bz;


    // Clock Generator
    I2C_CLOCK_GENERATOR CLOCK_GEN (
        .CLK(CLK),
        .RST_N(RST_N),
        .ENABLE(SCL_ENABLE),
        .SCL(SCL),
        .SCL_TICK(SCL_TICK)
    );


    // Master Controller
    I2C_MASTER DUT (
        .CLK(CLK),
        .RST_N(RST_N),

        .START(START),
        .SLAVE_ADDR(SLAVE_ADDR),
        .DATA_IN(DATA_IN),

        .SCL(SCL),
        .SCL_TICK(SCL_TICK),
        .SDA_IN(SDA_IN),

        .SCL_ENABLE(SCL_ENABLE),
        .SDA_OUT(SDA_OUT),
        .SDA_OE(SDA_OE),

        .BUSY(BUSY),
        .DONE(DONE),
        .ACK_ERROR(ACK_ERROR)
    );


    // 100 MHz System Clock
    always #5 CLK = ~CLK;


    initial begin

        CLK = 0;
        RST_N = 0;

        START = 0;

        SLAVE_ADDR = 7'b1001000;
        DATA_IN = 8'b10100101;

        SDA_IN = 1'b1;


        // Reset
        repeat (10) @(negedge CLK);

        RST_N = 1;


        // Start Transaction
        repeat (10) @(negedge CLK);

        START = 1;

        @(negedge CLK);

        START = 0;


        // Simulation duration
        #150000;

    end

endmodule