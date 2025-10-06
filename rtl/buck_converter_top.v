module buck_converter_top #(
    parameter CLK_FREQ = 100_000_000,
    parameter PWM_FREQ = 100_000,
    parameter V_REF = 12'd2048,
    parameter KP = 16'd100,
    parameter KI = 16'd10,
    parameter KD = 16'd5
)(
    input wire clk,
    input wire rst_n,
    input wire [11:0] adc_data,
    input wire adc_valid,
    output wire pwm_out,
    output wire [11:0] voltage_monitor,
    output wire [9:0] duty_cycle_monitor
);

    wire [11:0] voltage_fb;
    wire adc_ready;
    wire [9:0] duty_cycle;
    wire pid_valid;

    adc_interface adc_if (
        .clk(clk),
        .rst_n(rst_n),
        .adc_data(adc_data),
        .adc_valid(adc_valid),
        .voltage_fb(voltage_fb),
        .data_ready(adc_ready)
    );

    pid_controller #(
        .DATA_WIDTH(12),
        .KP(KP),
        .KI(KI),
        .KD(KD),
        .SETPOINT(V_REF)
    ) pid_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .feedback(voltage_fb),
        .fb_valid(adc_ready),
        .control_out(duty_cycle),
        .out_valid(pid_valid)
    );

    pwm_generator #(
        .CLK_FREQ(CLK_FREQ),
        .PWM_FREQ(PWM_FREQ),
        .PWM_RESOLUTION(10)
    ) pwm_gen (
        .clk(clk),
        .rst_n(rst_n),
        .duty_cycle(duty_cycle),
        .pwm_out(pwm_out)
    );

    assign voltage_monitor = voltage_fb;
    assign duty_cycle_monitor = duty_cycle;

endmodule
