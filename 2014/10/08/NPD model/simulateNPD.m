mu     = 2.0;
k      = 0.5;
lambda = 0.05;
phi    = 0.1;
params = [mu; k; lambda; phi];

x0 = [0.1; 0.1; 0.1];

T = 100;
truth = nan(3, T);
truth(:, 1) = x0;

for t = 1:T
    y = predictNPD(x0, params);
    truth(:, t+1) = y;
end


plot(truth(1, :), 'b')
hold on
plot(truth(2, :), 'g')
plot(truth(3, :), 'r')