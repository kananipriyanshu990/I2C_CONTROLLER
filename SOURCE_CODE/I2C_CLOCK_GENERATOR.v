// 100 MHz system clock to 100 kHz Standard-mode SCL (500 clocks per half-period).
// SCL is released high when disabled; SCL_TICK pulses at each half-period boundary.
module I2C_CLOCK_GENERATOR(output reg SCL, output reg SCL_TICK,
                           input wire ENABLE, input wire CLK, input wire RST_N);
    reg [8:0] COUNTER;
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin COUNTER<=0; SCL<=1'b1; SCL_TICK<=0; end
        else if (!ENABLE) begin COUNTER<=0; SCL<=1'b1; SCL_TICK<=0; end
        else begin
            SCL_TICK<=0;
            if (COUNTER==9'd499) begin COUNTER<=0; SCL<=~SCL; SCL_TICK<=1; end
            else COUNTER<=COUNTER+1'b1;
        end
    end
endmodule
