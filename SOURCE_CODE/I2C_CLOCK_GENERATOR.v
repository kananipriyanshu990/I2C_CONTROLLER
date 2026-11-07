module I2C_CLOCK_GENERATOR(output reg SCL,
                           output reg SCL_TICK,
                           input wire ENABLE,
                           input wire CLK,
                           input wire RST_N);
    
    reg [8:0] COUNTER;
    always @(posedge CLK)begin
        if (!RST_N) begin
            COUNTER <= 0;
            SCL <= 0;
            SCL_TICK <= 0;
        end
        else if (!ENABLE)begin
            COUNTER <= 0;
            SCL <= 0;
            SCL_TICK <= 0;
        end
        else begin
            SCL_TICK <= 0;
            if (COUNTER == 499)begin
                COUNTER <= 0;
                SCL <= ~SCL;
                SCL_TICK <= 1;
            end
            else begin
                COUNTER <= COUNTER + 1;
            end
        end
    end
endmodule