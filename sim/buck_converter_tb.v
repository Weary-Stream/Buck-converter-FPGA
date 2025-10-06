`timescale 1ns/1ps

module buck_converter_tb;

    reg clk;
    reg rst_n;
    reg [11:0] adc_data;
    reg adc_valid;
    wire pwm_out;
    wire [11:0] voltage_monitor;
    wire [9:0] duty_cycle_monitor;

    buck_converter_top #(
        .CLK_FREQ(100_000_000),
        .PWM_FREQ(100_000),
        .V_REF(12'd2048),
        .KP(16'd100),
        .KI(16'd10),
        .KD(16'd5)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .adc_data(adc_data),
        .adc_valid(adc_valid),
        .pwm_out(pwm_out),
        .voltage_monitor(voltage_monitor),
        .duty_cycle_monitor(duty_cycle_monitor)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("buck_converter.vcd");
        $dumpvars(0, buck_converter_tb);
        
        rst_n = 0;
        adc_data = 12'd0;
        adc_valid = 0;
        
        #100 rst_n = 1;
        
        repeat(1000) begin
            #100;
            adc_data = 12'd1800;
            adc_valid = 1;
            #10 adc_valid = 0;
        end
        
        repeat(1000) begin
            #100;
            adc_data = 12'd2048;
            adc_valid = 1;
            #10 adc_valid = 0;
        end
        
        repeat(1000) begin
            #100;
            adc_data = 12'd2200;
            adc_valid = 1;
            #10 adc_valid = 0;
        end
        
        #10000;
        $finish;
    end

endmodule
