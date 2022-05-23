function[t] = Calculate_Time(Ship, Port_P_tax, Berth_qt, Port_qt, Ship_qt, M)
% Berth_qt - Number of berths
% Ship is a structure, contains:
%       Ship(i).a - arrival time of ship i
%       Ship(i).b - max time of ship i
%       Ship(i).q - cargo of ship i

t = zeros(Ship_qt, Berth_qt, Port_qt);

for p = 1: Port_qt
    for j = 1:Berth_qt
        for i = 1:Ship_qt
            if Port_P_tax(j,p) == 0
                t(i,j,p) = M;
            else
                t(i,j,p) = Ship(i).q/Port_P_tax(j,p);
            end
        end
    end
end