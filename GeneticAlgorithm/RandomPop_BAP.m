function [ pop ] = RandomPop_BAP( N, B, size_pop )
%   Create the ramdom initial pop of a GA BAP 
% N - Quantity of ships
% B - Quantity of berths
% size_pop - Size of population
% Ship is a structure, conteins at least:
%       Ship(i).a - Arrival time of ship i
%       Ship(i).b - Max time of ship i

pop = zeros(N+B-1,size_pop); %Population
s = [1:N, zeros(1,B-1)];

for p = 1:size_pop
    pop(:,p) = s(randperm(length(s)));
end
        
    
end