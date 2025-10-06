clear; clc; close all;

Vin = 12;
Vout = 5;
L = 100e-6;
C = 220e-6;
R = 10;
fs = 100e3;

s = tf('s');
Gp = (Vin/(L*C)) / (s^2 + s/(R*C) + 1/(L*C));

wc = 2*pi*fs/10;
PM = 60;

[C_pid, info] = pidtune(Gp, 'PID', wc);

fprintf('PID Controller Parameters:\n');
fprintf('Kp = %.4f\n', C_pid.Kp);
fprintf('Ki = %.4f\n', C_pid.Ki);
fprintf('Kd = %.4f\n', C_pid.Kd);

T = feedback(C_pid*Gp, 1);

figure('Position', [100 100 1200 800]);

subplot(2,2,1);
step(T, 0.01);
title('Closed Loop Step Response');
xlabel('Time (s)');
ylabel('Output Voltage (V)');
grid on;

subplot(2,2,2);
bode(Gp);
title('Open Loop Plant Bode Plot');
grid on;

subplot(2,2,3);
margin(C_pid*Gp);
title('Loop Gain with PID Controller');
grid on;

subplot(2,2,4);
rlocus(Gp);
title('Root Locus of Plant');
grid on;

stepinfo(T)

Kp_range = logspace(-2, 2, 50);
Ki_range = logspace(0, 3, 50);

settling_time = zeros(length(Kp_range), length(Ki_range));
overshoot = zeros(length(Kp_range), length(Ki_range));

for i = 1:length(Kp_range)
    for j = 1:length(Ki_range)
        C_temp = pid(Kp_range(i), Ki_range(j), 0);
        T_temp = feedback(C_temp*Gp, 1);
        
        if isstable(T_temp)
            info_temp = stepinfo(T_temp);
            settling_time(i,j) = info_temp.SettlingTime;
            overshoot(i,j) = info_temp.Overshoot;
        else
            settling_time(i,j) = NaN;
            overshoot(i,j) = NaN;
        end
    end
end

figure;
subplot(1,2,1);
surf(Ki_range, Kp_range, settling_time);
set(gca, 'XScale', 'log', 'YScale', 'log');
xlabel('Ki');
ylabel('Kp');
zlabel('Settling Time (s)');
title('Settling Time vs Kp and Ki');
colorbar;

subplot(1,2,2);
surf(Ki_range, Kp_range, overshoot);
set(gca, 'XScale', 'log', 'YScale', 'log');
xlabel('Ki');
ylabel('Kp');
zlabel('Overshoot (%)');
title('Overshoot vs Kp and Ki');
colorbar;
