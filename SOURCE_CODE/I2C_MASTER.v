// FSM States
// 0 - IDLE
// 1 - START_BIT
// 2 - ADDRESS
// 3 - ACK_ADDRESS
// 4 - DATA_TRANSFER
// 5 - ACK_DATA
// 6 - STOP_BIT
// 7 - COMPLETE

module I2C_MASTER(output reg SCL_ENABLE,
                  output reg SDA_OUT,
                  output reg SDA_OE,
                  output reg BUSY,
                  output reg DONE,
                  output reg ACK_ERROR,
                  input wire [6:0] SLAVE_ADDR,
                  input wire [7:0] DATA_IN,
                  input wire START,
                  input wire SCL,
                  input wire SCL_TICK,
                  input wire SDA_IN,
                  input wire CLK,
                  input wire RST_N);
    
    reg [3:0] STATE;
    reg [7:0] SHIFT_REG; 
    reg [3:0] BIT_COUNT;
    reg START_DONE;
    reg ACK_RECEIVED;
    
    always @(posedge CLK)begin
        if(!RST_N) begin
            STATE <= 0;
            SHIFT_REG <= 0;
            BIT_COUNT <= 0;
            START_DONE <= 0;
            ACK_RECEIVED <= 0;
            SCL_ENABLE <= 0;
            SDA_OUT <= 0;
            SDA_OE <= 0;
            BUSY <= 0;
            DONE <= 0;
            ACK_ERROR <= 0;
        end
        else begin
            case (STATE)
                0: begin
                        SCL_ENABLE <= 0;
                        SDA_OE <= 0;
                        BUSY <= 0;
                        
                        if(START) begin
                            SHIFT_REG <= {SLAVE_ADDR, 1'b0};
                            BIT_COUNT <= 7;
                            SCL_ENABLE <= 1;
                            BUSY <= 1;
                            START_DONE <= 0;
                            ACK_ERROR <= 0;
                            STATE <= 1;
                        end
                   end
                1: begin
                      SCL_ENABLE <= 1;
                      if (SCL == 1'b1) begin

                          SDA_OUT    <= 0;
                          SDA_OE     <= 1;

                          START_DONE <= 1;

                          STATE      <= 2;
                      end
                   end 
                   
                2: begin
                        if (SCL_TICK) begin
                            if (SCL == 1'b1) begin
                                SDA_OUT <= SHIFT_REG[7];
                                SDA_OE  <= 1;
                                SHIFT_REG <= {SHIFT_REG[6:0], 1'b0};
                            end
                            else begin
                                if (BIT_COUNT == 0) begin
                                    SDA_OE <= 0;
                                    STATE <= 3;
                                end
                                else begin
                                    BIT_COUNT <= BIT_COUNT - 1;
                                end
                            end
                        end
                   end
                   
                3:  begin
                         SDA_OE <= 0;
                         if (SCL_TICK && SCL == 1'b0) begin
                             ACK_RECEIVED <= ~SDA_IN;
                             if (SDA_IN == 1'b1)
                                 ACK_ERROR <= 1;
                             SHIFT_REG <= DATA_IN;
                             BIT_COUNT <= 7;
                             STATE <= 4;
                         end      
                    end
                    
                4:  begin
                        if (SCL_TICK) begin
                            if (SCL == 1'b1) begin
                                SDA_OUT <= SHIFT_REG[7];
                                SDA_OE  <= 1;
                                SHIFT_REG <= {SHIFT_REG[6:0], 1'b0};
                            end
                            else begin
                                if (BIT_COUNT == 0) begin
                                    SDA_OE <= 0;
                                    STATE <= 5;
                                end
                                else begin
                                    BIT_COUNT <= BIT_COUNT - 1;
                                end
                            end
                        end
                    end
                    
                5:  begin
                        SDA_OE <= 0;
                        if (SCL_TICK && SCL == 1'b0) begin
                            if (SDA_IN == 1'b1)begin
                                ACK_ERROR <= 1;
                            end
                            STATE <= 6;
                        end
                    end
                6: begin
                       if (SCL == 1'b0) begin
                           SDA_OUT <= 0;
                           SDA_OE  <= 1;
                       end
                       else begin
                           SDA_OE <= 0;
                           SCL_ENABLE <= 0;
                           STATE <= 7;
                       end
                   end
                7: begin
                       BUSY <= 0;
                       DONE <= 1;
                       SCL_ENABLE <= 0;
                       SDA_OE <= 0;
                       STATE <= 0;
                   end

                default: begin
                             STATE <= 0;
                         end
            endcase
        end
    end 
endmodule