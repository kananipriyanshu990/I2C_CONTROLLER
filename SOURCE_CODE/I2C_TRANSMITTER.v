// States         
// 0 - IDLE       
// 1 - TRANSMIT   
// 2 - MASTER_ACK 
// 3 - COMPLETE   

module I2C_TRANSMITTER (input wire CLK,
                        input wire RST_N,
                        input wire LOAD,
                        input wire [7:0] DATA_IN,
                        input wire SCL,
                        input wire SCL_TICK,
                        input wire SDA_IN,
                        output reg SDA_OUT,
                        output reg SDA_OE,
                        output reg BUSY,
                        output reg DONE,
                        output reg MASTER_ACK);

    reg [1:0] STATE;
    reg [7:0] SHIFT_REG;
    reg [3:0] BIT_COUNT;

    always @(posedge CLK) begin
        if (!RST_N) begin
            STATE <= 0;
            SHIFT_REG <= 0;
            BIT_COUNT <= 0;
            SDA_OUT <= 0;
            SDA_OE <= 0;
            BUSY <= 0;
            DONE <= 0;
            MASTER_ACK <= 0;
        end

        else begin
            DONE <= 0;
            case (STATE)

                0: begin
                    SDA_OE <= 0;
                    BUSY <= 0;
                    if (LOAD) begin
                        SHIFT_REG <= DATA_IN;
                        BIT_COUNT <= 0;
                        BUSY <= 1;
                        STATE <= 1;
                    end
                end

                1: begin
                    if (SCL_TICK) begin
                        if (SCL == 1'b0) begin
                            SDA_OUT <= SHIFT_REG[7];
                            SDA_OE <= 1;
                            SHIFT_REG <= {SHIFT_REG[6:0], 1'b0};
                        end
                        else begin
                            if (BIT_COUNT == 7) begin
                                SDA_OE <= 0;
                                STATE <= 2;
                            end
                            BIT_COUNT <= BIT_COUNT + 1;
                        end
                    end
                end

                2: begin
                    SDA_OE <= 0;
                    if (SCL_TICK && SCL == 1'b0) begin
                        MASTER_ACK <= ~SDA_IN;
                        STATE <= 3;
                    end
                end

                3: begin
                    BUSY <= 0;
                    DONE <= 1;
                    STATE <= 0;
                end

                default: begin
                    STATE <= 0;
                end
            endcase
        end
    end
endmodule