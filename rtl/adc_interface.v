module adc_interface (
    input wire clk,
    input wire rst_n,
    input wire [11:0] adc_data,
    input wire adc_valid,
    output reg [11:0] voltage_fb,
    output reg data_ready
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            voltage_fb <= 12'd0;
            data_ready <= 1'b0;
        end else begin
            if (adc_valid) begin
                voltage_fb <= adc_data;
                data_ready <= 1'b1;
            end else begin
                data_ready <= 1'b0;
            end
        end
    end

endmodule
