module pid_controller #(
    parameter DATA_WIDTH = 12,
    parameter KP = 16'd100,
    parameter KI = 16'd10,
    parameter KD = 16'd5,
    parameter SETPOINT = 12'd2048
)(
    input wire clk,
    input wire rst_n,
    input wire [DATA_WIDTH-1:0] feedback,
    input wire fb_valid,
    output reg [9:0] control_out,
    output reg out_valid
);

    reg signed [DATA_WIDTH:0] error;
    reg signed [DATA_WIDTH:0] prev_error;
    reg signed [31:0] integral;
    reg signed [DATA_WIDTH:0] derivative;
    reg signed [31:0] p_term, i_term, d_term;
    reg signed [31:0] pid_sum;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            error <= 0;
            prev_error <= 0;
            integral <= 0;
            derivative <= 0;
            control_out <= 10'd512;
            out_valid <= 1'b0;
        end else if (fb_valid) begin
            error <= SETPOINT - feedback;
            prev_error <= error;
            
            if (integral + error > 32'sd100000)
                integral <= 32'sd100000;
            else if (integral + error < -32'sd100000)
                integral <= -32'sd100000;
            else
                integral <= integral + error;
            
            derivative <= error - prev_error;
            
            p_term <= (KP * error) >>> 8;
            i_term <= (KI * integral) >>> 16;
            d_term <= (KD * derivative) >>> 8;
            
            pid_sum <= p_term + i_term + d_term + 32'd512;
            
            if (pid_sum > 32'd1023)
                control_out <= 10'd1023;
            else if (pid_sum < 32'd0)
                control_out <= 10'd0;
            else
                control_out <= pid_sum[9:0];
            
            out_valid <= 1'b1;
        end else begin
            out_valid <= 1'b0;
        end
    end

endmodule
