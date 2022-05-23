function [ f_x ] = Fitness_BAP(T, t, a, b)
%   Evaluate fitness function
% T(N) or (N+B-1 )- Mooring time (B - berths qt, N - ships qt)
% t(N) or (N+B-1 ) - Service time (B - berths qt, N - ships qt)
% a - Coef of T
% b - Coef of t

y = a*sum(T) + b*sum(t); % Bap objective function

f_x = 1/(1 + log(y)); % Fitness function

end