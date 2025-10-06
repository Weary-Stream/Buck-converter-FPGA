clear; clc; close all;

Vin = 12;
Vout = 5;
L = 100e-6;
C = 220e-6;
R = 10;
ESR = 0.05;

s = tf('s');

Gvd = (Vin*(1 + ESR*C*s)) / (L*C*s^2 + (L/R + ESR*C)*s + 1);

Gvg = (1 + ESR*C*s) / (L*C*s^2 + (L/R + ESR*C)*s + 1);

w = logspace(1, 6, 1000);

figure('Position', [100 100 1200 600]);

subplot(1,2,1);
bode(Gvd, w);
title('Control-to-Output Transfer Function');
grid on;

subplot(1,2,2);
bode(Gvg, w);
title('Line-to-Output Transfer Function');
grid on;

fc_LC = 1/(2*pi*sqrt(L*C));
fz_ESR = 1/(2*pi*ESR*C);
fp_ESR = 1/(2*pi*R*C);

fprintf('System Characteristic Frequencies:\n');
fprintf('LC Corner Frequency: %.2f Hz\n', fc_LC);
fprintf('ESR Zero Frequency: %.2f kHz\n', fz_ESR/1e3);
fprintf('Output Pole Frequency: %.2f Hz\n', fp_ESR);

Kp = 0.05;
Ki = 50;
Kd = 0.0001;

C_pid = pid(Kp, Ki, Kd);
L_ol = C_pid * Gvd;

figure;
margin(L_ol);
title('Open Loop Gain with PID Compensation');
grid on;

[Gm, Pm, Wcg, Wcp] = margin(L_ol);

fprintf('\nStability Margins:\n');
fprintf('Gain Margin: %.2f dB\n', 20*log10(Gm));
fprintf('Phase Margin: %.2f degrees\n', Pm);
fprintf('Crossover Frequency: %.2f kHz\n', Wcp/2/pi/1e3);
