module pwm_generator #(
    parameter CLK_FREQ = 100_000_000,
    parameter PWM_FREQ = 100_000,
    parameter PWM_RESOLUTION = 10
)(
    input wire clk,
    input wire rst_n,
    input wire [PWM_RESOLUTION-1:0] duty_cycle,
    output reg pwm_out
);

    localparam COUNTER_MAX = CLK_FREQ / PWM_FREQ;
    
    reg [$clog2(COUNTER_MAX)-1:0] counter;
    reg [PWM_RESOLUTION-1:0] duty_reg;
    reg [PWM_RESOLUTION-1:0] compare_val;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            duty_reg <= 0;
            compare_val <= 0;
            pwm_out <= 1'b0;
        end else begin
            if (counter < COUNTER_MAX - 1) begin
                counter <= counter + 1;
            end else begin
                counter <= 0;
                duty_reg <= duty_cycle;
            end
            
            compare_val <= (duty_reg * COUNTER_MAX) >> PWM_RESOLUTION;
            pwm_out <= (counter < compare_val) ? 1'b1 : 1'b0;
        end
    end

endmodule
