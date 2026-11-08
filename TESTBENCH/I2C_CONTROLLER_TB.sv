`timescale 1ns/1ps

module I2C_CONTROLLER_TB;

    reg CLK;
    reg RST_N;

    reg [6:0] SLAVE_ADDR;
    reg [7:0] DATA_IN;

    reg SCL;

    reg MASTER_SDA;
    reg MASTER_OE;

    tri SDA;

    wire SDA_OUT;
    wire SDA_OE;

    wire [7:0] DATA_OUT;
    wire DATA_VALID;

    wire BUSY;
    wire MASTER_ACK;

    assign SDA = MASTER_OE ? 1'b0 : 1'bz;
    assign SDA = SDA_OE ? 1'b0 : 1'bz;


    I2C_CONTROLLER DUT (

        .CLK(CLK),
        .RST_N(RST_N),

        .SLAVE_ADDR(SLAVE_ADDR),
        .DATA_IN(DATA_IN),

        .SCL(SCL),
        .SDA_IN(SDA),

        .SDA_OUT(SDA_OUT),
        .SDA_OE(SDA_OE),

        .DATA_OUT(DATA_OUT),
        .DATA_VALID(DATA_VALID),

        .BUSY(BUSY),
        .MASTER_ACK(MASTER_ACK)

    );


    always #5 CLK = ~CLK;


    // START CONDITION
    task I2C_START;
        begin

            SCL = 1;
            MASTER_OE = 0;

            #100;

            MASTER_OE = 1;

            #100;

            SCL = 0;

        end
    endtask


    // SEND ONE BIT
    task SEND_BIT(input reg VALUE);
        begin

            SCL = 0;

            MASTER_OE = !VALUE;

            #100;

            SCL = 1;

            #100;

            SCL = 0;

        end
    endtask


    // RECEIVE ONE BIT
    task RECEIVE_BIT;
        begin

            SCL = 0;
            MASTER_OE = 0;

            #100;

            SCL = 1;

            #100;

            SCL = 0;

        end
    endtask


    // STOP CONDITION
    task I2C_STOP;
        begin

            SCL = 0;

            MASTER_OE = 1;

            #100;

            SCL = 1;

            #100;

            MASTER_OE = 0;

            #100;

        end
    endtask


    integer I;

    reg [7:0] ADDRESS_WRITE;
    reg [7:0] ADDRESS_READ;
    reg [7:0] WRITE_DATA;


    initial begin

        CLK = 0;
        RST_N = 0;

        SLAVE_ADDR = 7'b1001000;

        DATA_IN = 8'h3C;

        SCL = 1;

        MASTER_OE = 0;

        ADDRESS_WRITE = 8'b10010000;
        ADDRESS_READ  = 8'b10010001;

        WRITE_DATA = 8'hA5;


        // RESET
        repeat (10) @(negedge CLK);

        RST_N = 1;

        repeat (10) @(negedge CLK);


        // --------------------------------
        // TRANSACTION 1: WRITE
        // --------------------------------

        I2C_START();

        // Address
        for (I = 7; I >= 0; I = I - 1)
            SEND_BIT(ADDRESS_WRITE[I]);

        // Address ACK
        RECEIVE_BIT();

        // Data
        for (I = 7; I >= 0; I = I - 1)
            SEND_BIT(WRITE_DATA[I]);

        // Data ACK
        RECEIVE_BIT();

        // STOP
        I2C_STOP();


        repeat (20) @(negedge CLK);


        // --------------------------------
        // TRANSACTION 2: READ
        // --------------------------------

        I2C_START();

        // Address
        for (I = 7; I >= 0; I = I - 1)
            SEND_BIT(ADDRESS_READ[I]);

        // Address ACK
        RECEIVE_BIT();

        // Receive 8 data bits
        for (I = 7; I >= 0; I = I - 1)
            RECEIVE_BIT();

        // Master ACK
        SCL = 0;
        MASTER_OE = 1;

        #100;

        SCL = 1;

        #100;

        SCL = 0;
        MASTER_OE = 0;

        // STOP
        I2C_STOP();


        #1000;

    end

endmodule