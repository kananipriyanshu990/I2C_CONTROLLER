module I2C_RECEIVER(input CLK,
                           input RST_N,
                           input ENABLE,
                           input ACK_ENABLE,
                           input SCL,
                           input SCL_TICK,
                           input SDA_IN,
                           output reg [7:0] DATA_OUT,
                           output reg DATA_VALID,
                           output reg SDA_OUT,
                           output reg SDA_OE,
                           output reg BUSY);

    reg [7:0] SHIFT_REG;
    reg [3:0] BIT_COUNT;
    reg ACK_PHASE;
    
    always @(posedge CLK or negedge RST_N)
    begin
        if(!RST_N)
        begin
            SHIFT_REG <= 8'b0;
            DATA_OUT <= 8'b0;
            BIT_COUNT <= 4'b0;
            ACK_PHASE <= 1'b0;
            DATA_VALID <= 1'b0;
            SDA_OUT <= 1'b0;
            SDA_OE <= 1'b0;
            BUSY <= 1'b0;
        end
        else
        begin
            DATA_VALID <= 1'b0;
    
            if(!ENABLE)
            begin
                SHIFT_REG <= 8'b0;
                BIT_COUNT <= 4'b0;
                ACK_PHASE <= 1'b0;
                SDA_OE <= 1'b0;
                BUSY <= 1'b0;
            end
            else
            begin
                BUSY <= 1'b1;
                if(SCL_TICK && !SCL && ACK_PHASE)
                begin
                    SDA_OE <= ACK_ENABLE;
                end
                if(SCL_TICK && SCL)
                begin
                    if(!ACK_PHASE)
                    begin
                        SHIFT_REG <= {SHIFT_REG[6:0], SDA_IN};
                        BIT_COUNT <= BIT_COUNT + 1'b1;
    
                        if(BIT_COUNT == 4'd7)
                        begin
                            DATA_OUT <= {SHIFT_REG[6:0], SDA_IN};
                            ACK_PHASE <= 1'b1;
                        end
                    end
                    else
                    begin
                        SDA_OE <= 1'b0;
                        ACK_PHASE <= 1'b0;
                        BIT_COUNT <= 4'b0;
                        DATA_VALID <= 1'b1;
                        BUSY <= 1'b0;
                    end
                end
            end
        end
    end
endmodule