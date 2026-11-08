module I2C_RECEIVER_TB;
    reg CLK;
    reg RST_N;
    reg ENABLE;
    reg ACK_ENABLE;
    reg SCL;
    reg SCL_TICK;
    reg SDA_IN;
    wire [7:0] DATA_OUT;
    wire DATA_VALID;
    wire SDA_OUT;
    wire SDA_OE;
    wire BUSY;
    
    I2C_RECEIVER DUT(
        .CLK(CLK),
        .RST_N(RST_N),
        .ENABLE(ENABLE),
        .ACK_ENABLE(ACK_ENABLE),
        .SCL(SCL),
        .SCL_TICK(SCL_TICK),
        .SDA_IN(SDA_IN),
        .DATA_OUT(DATA_OUT),
        .DATA_VALID(DATA_VALID),
        .SDA_OUT(SDA_OUT),
        .SDA_OE(SDA_OE),
        .BUSY(BUSY)
    );
    
    always #5 CLK = ~CLK;
    
    task SEND_BIT(input BIT_VALUE);
    begin
        SCL = 0;
        SDA_IN = BIT_VALUE;
        SCL_TICK = 1;
        #10;
        SCL = 1;
        #10;
        SCL_TICK = 0;
        #10;
    end
    endtask
    
    task SEND_BYTE(input [7:0] BYTE_VALUE);
    integer I;
    begin
        for(I = 7; I >= 0; I = I - 1)
            SEND_BIT(BYTE_VALUE[I]);
    end
    endtask
    
    task ACK_CLOCK;
    begin
        SCL = 0;
        SCL_TICK = 1;
        #10;
        SCL = 1;
        #10;
        SCL_TICK = 0;
        #10;
        SCL = 0;
    end
    endtask
    
    initial begin
        CLK = 0;
        RST_N = 0;
        ENABLE = 0;
        ACK_ENABLE = 1;
        SCL = 0;
        SCL_TICK = 0;
        SDA_IN = 1;
        #100;
        RST_N = 1;
        #50;
        ENABLE = 1;
        // First byte with ACK
        SEND_BYTE(8'b10101010);
        ACK_CLOCK();
        #50;
        ENABLE = 0;
        #50;
        // Second byte with NACK
        ACK_ENABLE = 0;
        ENABLE = 1;
        SEND_BYTE(8'b11001100);
        ACK_CLOCK();
        #50;
        ENABLE = 0;
        #100;
    end
endmodule