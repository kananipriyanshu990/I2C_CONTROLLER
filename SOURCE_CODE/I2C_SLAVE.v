// State Encoding
// 0 - IDLE
// 1 - ADDRESS
// 2 - ADDRESS_ACK
// 3 - DATA
// 4 - DATA_ACK
    
module I2C_SLAVE (input wire CLK,
                  input wire RST_N,
                  input wire [6:0] SLAVE_ADDR,
                  input wire SCL,
                  input wire SDA_IN,
                  output reg SDA_OUT,
                  output reg SDA_OE,
                  output reg [7:0] DATA_OUT,
                  output reg DATA_VALID);

    reg [2:0] STATE;
    reg [7:0] SHIFT_REG;
    reg [3:0] BIT_COUNT;
    reg SCL_D;
    reg SDA_D;
    reg ACK_PHASE;
    reg ACK_ALLOWED;
    wire SCL_RISE;
    wire SCL_FALL;
    wire START_COND;
    wire STOP_COND;

    assign SCL_RISE  = SCL && !SCL_D;
    assign SCL_FALL  = !SCL && SCL_D;
    assign START_COND = SCL && SDA_D && !SDA_IN;
    assign STOP_COND  = SCL && !SDA_D && SDA_IN;

    always @(posedge CLK) begin
        if (!RST_N) begin
            STATE <= 0;
            SHIFT_REG  <= 0;
            BIT_COUNT  <= 0;
            SCL_D <= 0;
            SDA_D <= 1;
            ACK_PHASE <= 0;
            ACK_ALLOWED <= 0;
            SDA_OUT <= 0;
            SDA_OE <= 0;
            DATA_OUT <= 0;
            DATA_VALID <= 0;
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
                ACK_PHASE <= 0;
            end

            else if (STOP_COND) begin
                STATE <= 0;
                SDA_OE <= 0;
                ACK_PHASE <= 0;
            end

            else begin
                case (STATE)
                    0: begin
                        SDA_OE <= 0;
                    end
                    
                    1: begin
                          if (SCL_RISE) begin
                              SHIFT_REG <= {SHIFT_REG[6:0], SDA_IN};
                              if (BIT_COUNT == 7) begin
                                  BIT_COUNT <= 0;
                                  ACK_ALLOWED <=
                                      (SHIFT_REG[6:0] == SLAVE_ADDR) &&
                                      (SDA_IN == 0);
                                  STATE <= 2;
                              end

                              else begin
                                  BIT_COUNT <= BIT_COUNT + 1;
                              end
                          end
                      end
                      
                    2: begin
                        if (SCL_FALL && !ACK_PHASE) begin
                            if (ACK_ALLOWED) begin
                                SDA_OUT <= 0;
                                SDA_OE  <= 1;
                            end
                            ACK_PHASE <= 1;
                        end

                        else if (SCL_RISE && ACK_PHASE) begin
                            SDA_OE <= 0;
                            ACK_PHASE <= 0;
                            SHIFT_REG <= 0;
                            if (ACK_ALLOWED)
                                STATE <= 3;
                            else
                                STATE <= 0;
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
                        if (SCL_FALL && !ACK_PHASE) begin
                            SDA_OUT <= 0;
                            SDA_OE <= 1;
                            ACK_PHASE <= 1;
                        end
                        else if (SCL_RISE && ACK_PHASE) begin
                            SDA_OE <= 0;
                            ACK_PHASE <= 0;
                            SHIFT_REG <= 0;
                            STATE <= 3;
                        end
                    end

                    default: begin
                        STATE <= 0;
                    end
                endcase
            end
        end
    end
endmodule