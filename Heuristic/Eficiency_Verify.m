% Returns the efficient patterns

function[Pattern, Pattern_tax, Pattern_qt] = Eficiency_Verify(Machine, Pattern, Pattern_tax, M, Pattern_qt)
% Pattern - Set of all paterns
% Pattern_tax - tax of patterns
% M - Number of machine types
% Pattern_qt - Number of pattens
% Machine is a structure, contains:
%       Machine(i).q - available of machine type i
%       Machine(i).v - tax of machine type i


ind_remove = [];

for i = 1:Pattern_qt
    for j = 1:M
        % verify eficiency when a machine is removed
        tax_machine = Machine(j).v*(Pattern(j,i)-1);
        % if equal remove that pattern
        if tax_machine >= Pattern_tax(i)
            ind_remove = [ind_remove, i];
            break;
        end
    end
end

Pattern(:,ind_remove) = [];
Pattern_tax(ind_remove) = [];
Pattern_qt = Pattern_qt - length(ind_remove);
            