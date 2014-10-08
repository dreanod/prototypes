function [ Y ] = predictNPD(X0, params)
%PREDICTNPD Summary of this function goes here
%   Detailed explanation goes here
    fun = @(t,y) npd(y, params);
    
    [~, Y] = ode45(fun, [0, 1], X0);
    Y = Y(end,:)';
end

function [dY] = npd(X, params)
    
    mu     = params(1);
    k      = params(2);
    lambda = params(3);
    phi    = params(4);
    
    N = X(1);
    P = X(2);
    D = X(3);
    
    dP = N/(k + N) * mu * P - lambda * P^2;
    dN = phi * D - N / (k + N) * mu * P;
    dD = - phi * D + lambda * P^2;
    
    dY = [dP; dN; dD];
end