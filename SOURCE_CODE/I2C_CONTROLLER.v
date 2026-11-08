// FSM STATES        
// 0 - IDLE          
// 1 - ADDRESS       
// 2 - ADDRESS_ACK   
// 3 - RECEIVE_DATA  
// 4 - DATA_ACK      
// 5 - TRANSMIT_DATA 
// 6 - MASTER_ACK    
// 7 - WAIT_STOP     

module I2C_CONTROLLER (input wire CLK,
                       input wire RST_N,
                       input wire [6:0] SLAVE_ADDR,
                       input wire [7:0] DATA_IN,
                       input wire SCL,
                       input wire SDA_IN,
                       output reg SDA_OUT,
                       output reg SDA_OE,
                       output reg [7:0] DATA_OUT,
                       output reg DATA_VALID,
                       output reg BUSY,
                       output reg MASTER_ACK);

    reg [2:0] STATE;
    reg [7:0] SHIFT_REG;
    reg [3:0] BIT_COUNT;
    reg SCL_D;
    reg SDA_D;
    reg ADDRESS_MATCH;
    reg RW;
    reg ACK_ACTIVE;
    wire SCL_RISE;
    wire SCL_FALL;
    wire START_COND;
    wire STOP_COND;

    assign SCL_RISE = SCL && !SCL_D;
    assign SCL_FALL = !SCL && SCL_D;
    assign START_COND = SCL && SDA_D && !SDA_IN;
    assign STOP_COND  = SCL && !SDA_D && SDA_IN;

    always @(posedge CLK) begin
        if (!RST_N) begin
            STATE <= 0;
            SHIFT_REG <= 0;
            BIT_COUNT <= 0;
            SCL_D <= 0;
            SDA_D <= 1;
            ADDRESS_MATCH <= 0;
            RW <= 0;
            ACK_ACTIVE <= 0;
            SDA_OUT <= 0;
            SDA_OE <= 0;
            DATA_OUT <= 0;
            DATA_VALID <= 0;
            BUSY <= 0;
            MASTER_ACK <= 0;
        end
        else begin
            SCL_D <= SCL;
            SDA_D <= SDA_IN;
            DATA_VALID <= 0;
            if (START_COND) begin
                STATE <= 1;
                SHIFT_REG <= 0;
                BIT_COUNT <= 0;
                SDA_OE <= 0;
                ACK_ACTIVE <= 0;
                BUSY <= 1;
            end
            else if (STOP_COND) begin
                STATE <= 0;
                SDA_OE <= 0;
                ACK_ACTIVE <= 0;
                BUSY <= 0;
            end
            else begin
                case (STATE)
                    0: begin
                        SDA_OE <= 0;
                        BUSY <= 0;
                    end

                    1: begin
                        if (SCL_RISE) begin
                            SHIFT_REG <= {SHIFT_REG[6:0], SDA_IN};
                            if (BIT_COUNT == 7) begin
                                BIT_COUNT <= 0;
                                ADDRESS_MATCH <= (SHIFT_REG[6:0] == SLAVE_ADDR);
                                RW <= SDA_IN;
                                STATE <= 2;
                            end
                            else begin
                                BIT_COUNT <= BIT_COUNT + 1;
                            end
                        end
                    end

                    2: begin
                        if (SCL_FALL && !ACK_ACTIVE) begin
                            if (ADDRESS_MATCH) begin
                                SDA_OE <= 1;
                            end
                            ACK_ACTIVE <= 1;
                        end
                        else if (SCL_RISE && ACK_ACTIVE) begin
                            SDA_OE <= 0;
                            ACK_ACTIVE <= 0;
                            SHIFT_REG <= DATA_IN;
                            BIT_COUNT <= 0;
                            if (ADDRESS_MATCH) begin
                                if (RW)
                                    STATE <= 5;
                                else
                                    STATE <= 3;
                            end
                            else begin
                                STATE <= 7;
                            end
                        end
                    end

                    3: begin
                        if (SCL_RISE) begin
                            SHIFT_REG <= {SHIFT_REG[6:0], SDA_IN};
                            if (BIT_COUNT == 7) begin
                                DATA_OUT <= {SHIFT_REG[6:0], SDA_IN};
                                DATA_VALID <= 1;
                                BIT_COUNT <= 0;
                                STATE <= 4;
                            end

                            else begin
                                BIT_COUNT <= BIT_COUNT + 1;
                            end
                        end
                    end

                    4: begin
                        if (SCL_FALL && !ACK_ACTIVE) begin
                            SDA_OE <= 1;
                            ACK_ACTIVE <= 1;
                        end
                        else if (SCL_RISE && ACK_ACTIVE) begin
                            SDA_OE <= 0;
                            ACK_ACTIVE <= 0;
                            STATE <= 3;
                        end
                    end
                    
                    5: begin
                        if (SCL_FALL) begin
                            SDA_OUT <= 0;
                            SDA_OE <= ~SHIFT_REG[7];
                        end
                        if (SCL_RISE) begin
                            SHIFT_REG <= {SHIFT_REG[6:0], 1'b0};
                            if (BIT_COUNT == 7) begin
                                BIT_COUNT <= 0;
                                STATE <= 6;
                            end
                            else begin
                                BIT_COUNT <= BIT_COUNT + 1;
                            end
                        end
                    end

                    6: begin
                        if (SCL_FALL) begin
                            SDA_OE <= 0;
                        end

                        if (SCL_RISE) begin
                            MASTER_ACK <= ~SDA_IN;
                            STATE <= 7;
                        end
                    end

                    7: begin
                        SDA_OE <= 0;
                    end

                    default: begin
                        STATE <= 0;
                    end
                endcase
            end
        end
    end
endmodule