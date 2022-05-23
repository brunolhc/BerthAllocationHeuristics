% Calculate the tax of a berth pattern

function[tax] = Pattern_tax(Machine, Pattern, M)
% tax - tax of the patterns
% Pattern - Set of all paterns
% Pattern_qt - Number of pattens
% Machine is a structure, contains:
%       Machine(i).q - available of machine type i
%       Machine(i).v - tax of machine type i

tax = 100000;

% the tax is given by the slowest process
for i = 1:M
    if Machine(i).v * Pattern(i) < tax
        tax = Machine(i).v*Pattern(i);
    end
end