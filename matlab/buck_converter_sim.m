clear; clc; close all;

Vin = 12;
Vout = 5;
L = 100e-6;
C = 220e-6;
R = 10;
fs = 100e3;
Ts = 1/fs;

D = Vout/Vin;

t_sim = 0.02;
t = 0:Ts:t_sim;
N = length(t);

iL = zeros(1, N);
vC = zeros(1, N);
vout = zeros(1, N);
duty = zeros(1, N);

iL(1) = Vout/R;
vC(1) = Vout;

Kp = 0.05;
Ki = 50;
Kd = 0.0001;

Vref = 5;
error_int = 0;
error_prev = 0;

for i = 2:N
    error = Vref - vC(i-1);
    error_int = error_int + error*Ts;
    error_der = (error - error_prev)/Ts;
    
    duty(i) = D + Kp*error + Ki*error_int + Kd*error_der;
    duty(i) = max(0.1, min(0.9, duty(i)));
    
    error_prev = error;
    
    if mod(i, 2) == 0
        vL = Vin - vC(i-1);
    else
        vL = -vC(i-1);
    end
    
    diL = (vL/L)*Ts;
    iL(i) = iL(i-1) + diL;
    
    iC = iL(i) - vC(i-1)/R;
    dvC = (iC/C)*Ts;
    vC(i) = vC(i-1) + dvC;
    
    vout(i) = vC(i);
end

figure('Position', [100 100 1200 800]);

subplot(3,1,1);
plot(t*1000, vout, 'b', 'LineWidth', 1.5);
hold on;
plot(t*1000, Vref*ones(size(t)), 'r--', 'LineWidth', 1.5);
ylabel('Voltage (V)');
xlabel('Time (ms)');
title('Output Voltage');
legend('Vout', 'Vref');
grid on;

subplot(3,1,2);
plot(t*1000, iL, 'g', 'LineWidth', 1.5);
ylabel('Current (A)');
xlabel('Time (ms)');
title('Inductor Current');
grid on;

subplot(3,1,3);
plot(t*1000, duty*100, 'm', 'LineWidth', 1.5);
ylabel('Duty Cycle (%)');
xlabel('Time (ms)');
title('PWM Duty Cycle');
grid on;

figure;
s = tf('s');
Gvd = (Vin/(L*C)) / (s^2 + s/(R*C) + 1/(L*C));
bode(Gvd);
title('Buck Converter Transfer Function (Control to Output)');
grid on;

fprintf('Steady State Results:\n');
fprintf('Output Voltage: %.3f V\n', vout(end));
fprintf('Inductor Current: %.3f A\n', iL(end));
fprintf('Final Duty Cycle: %.3f %%\n', duty(end)*100);
fprintf('Voltage Ripple: %.3f mV\n', (max(vout)-min(vout))*1000);
