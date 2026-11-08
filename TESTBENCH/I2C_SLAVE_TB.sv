`timescale 1ns/1ps

module I2C_SLAVE_TB;

    reg CLK;
    reg RST_N;

    reg [6:0] SLAVE_ADDR;

    reg SCL;

    reg MASTER_SDA_OUT;
    reg MASTER_SDA_OE;

    tri SDA;
    wire SDA_OUT;
    wire SDA_OE;

    wire [7:0] DATA_OUT;
    wire DATA_VALID;

    assign SDA = MASTER_SDA_OE ? MASTER_SDA_OUT : 1'bz;
    assign SDA = SDA_OE ? SDA_OUT : 1'bz;


    I2C_SLAVE DUT (
        .CLK(CLK),
        .RST_N(RST_N),

        .SLAVE_ADDR(SLAVE_ADDR),

        .SCL(SCL),
        .SDA_IN(SDA),

        .SDA_OUT(SDA_OUT),
        .SDA_OE(SDA_OE),

        .DATA_OUT(DATA_OUT),
        .DATA_VALID(DATA_VALID)
    );


    // 100 MHz System Clock
    always #5 CLK = ~CLK;


    // Send One Data Bit
    task SEND_BIT(input reg BIT_VALUE);
        begin

            SCL = 0;
            MASTER_SDA_OE = 1;
            MASTER_SDA_OUT = BIT_VALUE;

            #100;

            SCL = 1;
            #100;

            SCL = 0;
            #100;

        end
    endtask


    // Generate ACK Clock
    task ACK_CLOCK;
        begin

            MASTER_SDA_OE = 0;

            #100;

            SCL = 1;
            #100;

            SCL = 0;
            #100;

        end
    endtask


    integer I;

    reg [7:0] ADDRESS_BYTE;
    reg [7:0] TRANSMIT_DATA;


    initial begin

        CLK = 0;
        RST_N = 0;

        SCL = 1;

        SLAVE_ADDR = 7'b1001000;

        MASTER_SDA_OUT = 1;
        MASTER_SDA_OE = 0;

        ADDRESS_BYTE = 8'b10010000;
        TRANSMIT_DATA = 8'b10100101;


        // Reset
        repeat (10) @(negedge CLK);

        RST_N = 1;

        repeat (10) @(negedge CLK);


        // START CONDITION
        SCL = 1;
        MASTER_SDA_OE = 1;
        MASTER_SDA_OUT = 1;

        #100;

        MASTER_SDA_OUT = 0;

        #100;


        // ADDRESS + WRITE BIT
        for (I = 7; I >= 0; I = I - 1)
            SEND_BIT(ADDRESS_BYTE[I]);


        // ADDRESS ACK
        ACK_CLOCK();


        // DATA TRANSMISSION
        for (I = 7; I >= 0; I = I - 1)
            SEND_BIT(TRANSMIT_DATA[I]);


        // DATA ACK
        ACK_CLOCK();


        // STOP CONDITION
        MASTER_SDA_OE = 1;
        MASTER_SDA_OUT = 0;

        #100;

        SCL = 1;

        #100;

        MASTER_SDA_OUT = 1;

        #100;

        MASTER_SDA_OE = 0;


        #1000;

    end

endmodule