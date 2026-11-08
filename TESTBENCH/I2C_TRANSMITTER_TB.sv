`timescale 1ns/1ps

module I2C_TRANSMITTER_TB;

    reg CLK;
    reg RST_N;

    reg LOAD;
    reg [7:0] DATA_IN;

    reg SCL;
    reg SCL_TICK;

    reg SDA_IN;

    wire SDA_OUT;
    wire SDA_OE;

    wire BUSY;
    wire DONE;
    wire MASTER_ACK;

    tri1 SDA;

    assign SDA = SDA_OE ? SDA_OUT : 1'bz;


    I2C_TRANSMITTER DUT (
        .CLK(CLK),
        .RST_N(RST_N),

        .LOAD(LOAD),
        .DATA_IN(DATA_IN),

        .SCL(SCL),
        .SCL_TICK(SCL_TICK),

        .SDA_IN(SDA_IN),

        .SDA_OUT(SDA_OUT),
        .SDA_OE(SDA_OE),

        .BUSY(BUSY),
        .DONE(DONE),
        .MASTER_ACK(MASTER_ACK)
    );


    always #5 CLK = ~CLK;


    initial begin

        CLK = 0;
        RST_N = 0;

        LOAD = 0;
        DATA_IN = 8'hA5;

        SCL = 0;
        SCL_TICK = 0;

        SDA_IN = 0;


        // Reset
        repeat (10) @(negedge CLK);
        RST_N = 1;


        // Load Data
        repeat (10) @(negedge CLK);

        LOAD = 1;

        @(negedge CLK);
        LOAD = 0;


        // Generate SCL transitions
        repeat (8) begin

            repeat (500) @(negedge CLK);

            SCL = 1;
            SCL_TICK = 1;

            @(negedge CLK);

            SCL_TICK = 0;

            repeat (500) @(negedge CLK);

            SCL = 0;
            SCL_TICK = 1;

            @(negedge CLK);

            SCL_TICK = 0;

        end


        // Master ACK
        SDA_IN = 0;

        repeat (500) @(negedge CLK);

        SCL = 1;
        SCL_TICK = 1;

        @(negedge CLK);

        SCL_TICK = 0;

        repeat (10) @(negedge CLK);


        #1000;

        $finish;

    end

endmodule