function[Berth_qt] = ValidaDados(Machine, Machine_qt, Berth_qt, min_machine)
% ValidaDados - Validates the quantity of machines and berths
%   Berth_qt - The new number of berths
%   Machine_qt - Number of machine types
%   Berth_qt - Number of berths
%   min_machine - minimum working machines at same time on a ship
%   Machine is a structure, contains:
%       Machine(i).q - available of machine type i
%       Machine(i).v - tax of machine type i

for m = 1:Machine_qt
    aux = Machine(m).q/Berth_qt;
    if aux < min_machine(m)
        Berth_qt = Berth_qt - 1;
    end
end