// Single-byte, 7-bit addressed I2C master. READ=0 writes DATA_IN; READ=1
// receives one byte and terminates with NACK. SDA_OE means pull SDA low.
module I2C_MASTER(output reg SCL_ENABLE, output reg SDA_OUT, output reg SDA_OE,
                  output reg BUSY, output reg DONE, output reg ACK_ERROR,
                  input wire [6:0] SLAVE_ADDR, input wire [7:0] DATA_IN,
                  input wire READ, input wire START, input wire SCL,
                  input wire SCL_TICK, input wire SDA_IN, input wire CLK,
                  input wire RST_N, output reg [7:0] DATA_OUT,
                  output reg DATA_VALID);
    localparam IDLE=0, START_COND=1, ADDR=2, ADDR_ACK=3,
               WRITE_DATA=4, WRITE_ACK=5, READ_DATA=6,
               READ_ACK=7, STOP=8, FINISH=9;
    reg [3:0] state;
    reg [7:0] shift;
    reg [2:0] bit_count;
    reg read_latched, phase;
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            state<=IDLE; shift<=0; bit_count<=0; read_latched<=0; phase<=0;
            SCL_ENABLE<=0; SDA_OUT<=0; SDA_OE<=0; BUSY<=0; DONE<=0;
            ACK_ERROR<=0; DATA_OUT<=0; DATA_VALID<=0;
        end else begin
            DONE<=0; DATA_VALID<=0;
            case (state)
              IDLE: begin
                SCL_ENABLE<=0; SDA_OE<=0; BUSY<=0; phase<=0;
                if (START) begin
                    shift<={SLAVE_ADDR,READ}; read_latched<=READ; bit_count<=0;
                    ACK_ERROR<=0; SCL_ENABLE<=1; BUSY<=1; state<=START_COND;
                end
              end
              START_COND: if (SCL && SCL_TICK) begin
                    SDA_OE<=1; phase<=0; state<=ADDR;
              end
              ADDR: if (SCL_TICK) begin
                    if (!SCL) begin SDA_OE<=~shift[7]; SDA_OUT<=0; end
                    else begin
                        shift<={shift[6:0],1'b0};
                        if (bit_count==7) begin bit_count<=0; SDA_OE<=0; state<=ADDR_ACK; end
                        else bit_count<=bit_count+1'b1;
                    end
              end
              ADDR_ACK: if (SCL_TICK) begin
                    if (!SCL) SDA_OE<=0;
                    else begin
                        if (SDA_IN) ACK_ERROR<=1;
                        if (read_latched) begin bit_count<=0; shift<=0; state<=READ_DATA; end
                        else begin shift<=DATA_IN; bit_count<=0; state<=WRITE_DATA; end
                    end
              end
              WRITE_DATA: if (SCL_TICK) begin
                    if (!SCL) SDA_OE<=~shift[7];
                    else begin
                        shift<={shift[6:0],1'b0};
                        if (bit_count==7) begin bit_count<=0; SDA_OE<=0; state<=WRITE_ACK; end
                        else bit_count<=bit_count+1'b1;
                    end
              end
              WRITE_ACK: if (SCL_TICK) begin
                    if (!SCL) SDA_OE<=0;
                    else begin if (SDA_IN) ACK_ERROR<=1; phase<=0; state<=STOP; end
              end
              READ_DATA: if (SCL_TICK && SCL) begin
                    shift<={shift[6:0],SDA_IN};
                    if (bit_count==7) begin DATA_OUT<={shift[6:0],SDA_IN}; DATA_VALID<=1; bit_count<=0; state<=READ_ACK; end
                    else bit_count<=bit_count+1'b1;
              end
              READ_ACK: if (SCL_TICK) begin
                    if (!SCL) SDA_OE<=0; // NACK the final byte
                    else begin phase<=0; state<=STOP; end
              end
              STOP: if (SCL_TICK) begin
                    if (!SCL) begin SDA_OE<=1; SDA_OUT<=0; phase<=1; end
                    else if (phase) begin SDA_OE<=0; SCL_ENABLE<=0; state<=FINISH; end
              end
              FINISH: begin BUSY<=0; DONE<=1; SDA_OE<=0; SCL_ENABLE<=0; state<=IDLE; end
              default: begin state<=IDLE; SCL_ENABLE<=0; SDA_OE<=0; end
            endcase
        end
    end
endmodule
