function [ mooring_time, service_time, Aloc, Machine_Aloc, machineB, f_best ] = ...
    FIFO(Ship, Ship_qt, Machine, Machine_qt, Berth_qt, min_machine, max_machine, c, file_name) % Ship, N, B, Machine_qt, Pattern, Machine,service_time,Pattern_qt
%   Create the initial pop of a GA, trying to find good solutions
% N - Quantity of ships
% B - Quantity of berths
% t_est(N,B) - Estimated handling time
% size_pop - Size of population
% Ship is a structure, conteins at least:
%       Ship(i).a - Arrival time of ship i
%       Ship(i).b - Max time of ship i

addpath('C:\Program Files\IBM\ILOG\CPLEX_Studio126\cplex\matlab\x64_win64');

% Reads date from an excel file
% [Ship, Ship_qt, Machine, Machine_qt, Berth_qt, max_machine, ...
%     min_machine, ~, c] = LeExcel(path, name);

%Validates the number of machines and berths
[Berth_qt] = ValidaDados(Machine, Machine_qt, Berth_qt, min_machine);


%tic
Machine_Aloc = zeros(Ship_qt,Machine_qt);

%mean tax
tax = 9999999*ones(Berth_qt,1);
machineB = zeros(Berth_qt,Machine_qt);
for i = 1:Machine_qt
    %aux = Machine(i).q*Machine(i).v/Berth_qt;
    machine = Machine(i).q;
    berth = Berth_qt;
    while berth > 0
        if(ceil(machine/berth) > max_machine(i))
            machineB(berth,i) = max_machine(i);
            machine = machine - max_machine(i);
        else
            if(ceil(machine/berth) < min_machine(i))
                machineB(berth,i) = min_machine(i);
                machine = machine - min_machine(i);
            else
                machineB(berth,i) = ceil(machine/berth);
                machine = machine - ceil(machine/berth);
            end
        end
        berth = berth-1;
    end
end

for i = 1:Berth_qt
    for j = 1:Machine_qt
        if tax(i) > machineB(i,j)*Machine(j).v
            tax(i) = machineB(i,j)*Machine(j).v;
        end
    end
end


% Ordened Ships
[~,shipOrd] = sort([Ship.a]);
%%%%%%%%%%%%%%%%%%%%%%%%% Main Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Aloc = zeros(Ship_qt,Berth_qt); % Matricial form of a solution

Berth_time = zeros(Berth_qt); % Berth time
mooring_time = zeros(Ship_qt,1);
service_time = zeros(Ship_qt,1);

for s = 1:Ship_qt
    %Selected the first avaliable berth
    [~,berth_aux] = min(Berth_time);
    berth = berth_aux(1);
    mooring_time(shipOrd(s)) = max(Berth_time(berth),Ship(shipOrd(s)).a);
    service_time(shipOrd(s)) = Ship(shipOrd(s)).q/tax(berth);
    Machine_Aloc(shipOrd(s),:) = machineB(berth,:);
    
    Berth_time(berth) = mooring_time(shipOrd(s)) + service_time(shipOrd(s));
    
    ind = find(Aloc(:,berth) == 0, 1, 'first');
    Aloc(ind,berth) = shipOrd(s);
end

f_best = 0;
for i = 1:Ship_qt
    f_best = f_best + c(1)*(mooring_time(i)-Ship(i).a) + c(2)*service_time(i);
end

%opt_time = toc;

file_name = strcat(file_name,'_fifo','.xlsb');

fprintf('f_FIFO: %f \n',f_best);

writeexcel(file_name, Berth_qt, f_best, -1, Aloc, mooring_time, service_time);


%clear all
end