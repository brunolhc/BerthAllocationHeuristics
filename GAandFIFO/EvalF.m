function [ mooring_time, service_time, Machine_Aloc, z, f_best ] = EvalF(Ship, Ship_qt, Machine, Machine_qt, Berth_qt, Machine_Berth, Aloc, c)

mooring_time = zeros(Ship_qt, 1);
service_time = zeros(Ship_qt,1);
Machine_Aloc = zeros(Ship_qt,Machine_qt);

time =0; berth = 1;
for s = 1:Ship_qt+Berth_qt-1
    if Aloc(s) == 0
        berth = berth+1;
        time = 0;
    else
        mooring_time(Aloc(s)) = max(time, Ship(Aloc(s)).a);
        tax = 9999999;
        for k = 1:Machine_qt
            aux = Machine_Berth(berth,k)*Machine(k).v;
            if tax > aux
                tax = aux;
            end
        end
        service_time(Aloc(s)) = Ship(Aloc(s)).q/tax;
        time = mooring_time(Aloc(s)) + service_time(Aloc(s));
        Machine_Aloc(Aloc(s),:) = Machine_Berth(berth,:);
    end
end

z = c(1)*sum(mooring_time(:)-[Ship(:).a]')+c(2)*sum(service_time(:));
f_best = 1/(z+1);

end