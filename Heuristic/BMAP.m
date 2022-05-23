function [ mooring_time, service_aloc, Pattern_selected, Aloc, f_aloc ] = BMAP(name) % Ship, N, B, Machine_qt, Pattern, Machine,service_time,Pattern_qt
%   Create the initial pop of a GA, trying to find good solutions
% N - Quantity of ships
% B - Quantity of berths
% t_est(N,B) - Estimated handling time
% size_pop - Size of population
% Ship is a structure, conteins at least:
%       Ship(i).a - Arrival time of ship i
%       Ship(i).b - Max time of ship i

 cd C:\Users\Lenovo\Dropbox\Unicamp\Doutorado\MatLab\PatternCreateBerths-PBAP
 [Pattern, ~,service_time] = Port_Pattern('C:\Users\Lenovo\Dropbox\Unicamp\Doutorado\MatLab\Heuristica\Testes\',name,'xlsb');
 cd C:\Users\Lenovo\Dropbox\Unicamp\Doutorado\MatLab\Heuristica

arq = strcat('C:\Users\Lenovo\Dropbox\Unicamp\Doutorado\MatLab\Heuristica\Testes\',name);
arq = strcat(arq,'.xlsb');

%[Pattern, ~, service_time] = selectedPortPattern(arq);

service_time = round(100*service_time)/100;



[Machine_qt, Berth_qt, Pattern_qt] = size(Pattern);


Ship_qt = xlsread(arq,'Data','A2');

Ship(:).q = zeros(1,Ship_qt);
Ship(:).a = zeros(1,Ship_qt);
for i = 1:Ship_qt
    Ship(i).q = xlsread(arq,'Data',strcat('G', num2str(i+3)));
end

%[Ship(:).a] = zeros(1,Ship_qt);
for i = 1:Ship_qt
    Ship(i).a = xlsread(arq,'Data',strcat('E', num2str(i+3)));
end

Machine(i).q = zeros(1,Machine_qt);
for i = 1:Machine_qt
    Machine(i).q = xlsread(arq,'Data',strcat('K', num2str(i+4)));
end

c(1)=4;
c(2) = 1;

tol_wait = 0;
for i = 1:Ship_qt
    for j = 1:Berth_qt
        for k = 1:Pattern_qt
            tol_wait = tol_wait + service_time(i,j,k);
        end
    end
end
tol_wait = 0.1*tol_wait;
tol_wait = 0;

%%%%%%%%%%%%%%%%%%%%%%%%% Main Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic

Pattern_selected = zeros(1,Ship_qt);

T = zeros(Berth_qt,1); % Berth time
T_next = zeros(Berth_qt,1); % Next berth time
Aloc = zeros(Ship_qt,Berth_qt); % Matricial form of a solution
count = 1;
T_aux = 0; % Last Berth time
ind_us = 1:Ship_qt; % Ind of unsigned ships

machine_un = [Machine(:).q];
machine_una = [Machine(:).q];
M_a = zeros(Machine_qt,Berth_qt);
mooring_time = zeros(1,Ship_qt);
service_aloc = zeros(1,Ship_qt);

while count <= Ship_qt % While there are ships unsigned
    count
    % Find waiting ships
    ind_w = zeros(1,length(ind_us)); % ind of wating ships
    k = 1;
    for i = 1:length(ind_us)
        if Ship(ind_us(i)).a <= T_aux + tol_wait
            ind_w(k) = ind_us(i);
            k = k+1;
        end
    end
    
    % Remove nulls(Berths) ???
    ind_w(ind_w == 0) = [];
    
    % If there aren't ships waiting, find next arrival time
    if length(ind_w) <= 0;
        T_aux = min([Ship(ind_us).a]);
        ind_w = size(length(ind_us),1);
        k=1;
        for i = 1:length(ind_us)
            if Ship(ind_us(i)).a <= T_aux
                ind_w(k) = ind_us(i);
                k=k+1;
            end
        end
        
        % Remove nulls (Berths)
        ind_w(ind_w==0) = [];
    end
    
    % Find free berths
    ind_b = find(T <= T_aux); % Find free berths
    
    % If there are ships waiting, assign to a free berth (select min
    % cargo ship)
    %         s = ind_w(randi(length(ind_w)));
    %         b = ind_b(randi(length(ind_b)));
    [~,ind_w_sorted] = sort([Ship(ind_w).q]);
    [~,ind_b_sorted] = sort(T(ind_b));
    
    pos = zeros(1,Berth_qt);
    for i = 1:Berth_qt
        pos(i) = find(Aloc(:,i)==0, 1, 'first');
    end
    
    lim = min(length(ind_b_sorted), length(ind_w_sorted));
    for i = 1:lim
        Aloc(pos(ind_b(ind_b_sorted(i))),ind_b(ind_b_sorted(i))) = ...
            ind_w(ind_w_sorted(i));
    end
    
    Time = zeros(1,Pattern_qt);
    %%%%%%%%%%%%%%%%% find the best port pattern %%%%%%%%%%%%%%%%%%%%%%
    mooring_aux = zeros(lim,Pattern_qt);
    service_aux = zeros(lim,Pattern_qt);
    for p = 1:Pattern_qt
        machine_un = machine_una;
        ship = ind_w(ind_w_sorted(1:lim));
        berth = ind_b(ind_b_sorted(1:lim));
        M = M_a;

        for j = 1:lim
            %%%%%%%%%%%%%%%%%%%%%% Back time check %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   Verify if the ship can mooring early then estimated, this will
            % happen when machine used af this ship is less equal of the unused
            % plus early berths machines (of the anterior positions).
            stop_bt = 0;
            T_mo = max(T(berth(j)),Ship(ship(j)).a);
            %ship_interval(P(index)) = T_aux;
            while stop_bt == 0
                index_ma = find(T <= T_mo); % Find early berth times
                % Accumulate the early berths machines
                for m = 1:length(index_ma)
                    for k = 1:Machine_qt
                        machine_un(k) = machine_un(k) + M(k,index_ma(m));
                        M(k,index_ma(m)) = 0;
                    end
                end
                
                % Verify if there are enough machines
                check = 1;
                for i = 1:Machine_qt
                    if Pattern(i,berth(j),p) > machine_un(i)
                        check = 0;
                        break;
                    end
                end
                
                if check
                    mooring_aux(ship(j),p) = max(T_mo,Ship(ship(j)).a);
                    service_aux(ship(j),p) = service_time(ship(j),berth(j),p);
                    T_next(berth(j)) = mooring_aux(ship(j),p) + service_time(ship(j),berth(j),p);
                    for k = 1:Machine_qt
                        machine_un(k) = machine_un(k) - Pattern(k,berth(j),p);
                    end
                    stop_bt = 1;
                    % If there aren't enough machines advance time
                else
                    index_next = find(T > T_mo, 1);
                    T_mo = T(index_next);
                end
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%% Back time check end %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        t_sum = 0;
        T_sum = 0;
        for i = 1:lim
            t_sum = t_sum + service_time(ship(i),berth(i),p);
            T_sum = T_sum + mooring_time(ship(i));
        end
        Time(p) = c(1)*T_sum + c(2)*t_sum;
    end
    [~,p] = min(Time);
    for i = 1:lim
        Pattern_selected(ship(i)) = p;
        mooring_time(ship(i)) = mooring_aux(ship(i),p);
        service_aloc(ship(i)) = service_aux(ship(i),p);
        T_next(berth(i)) = mooring_aux(ship(i),p) + service_time(ship(i),berth(i),p);
    end
    
    % Find the new machine unused
    machine_una = [Machine(:).q];
    M_a = Pattern(:,:,p);
    for k = 1:Machine_qt
        for b = 1:Berth_qt
            machine_una(k) = machine_una(k) - Pattern(k,b,p);
        end
    end
    
    % Remove the assigned ships
    ind_us = setdiff(ind_us,ind_w(ind_w_sorted(1:lim)));
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     for i = 1:lim
%         T(berth(i)) = mooring_time(ship(i)) + service_time(ship(i),berth(i),p);
%     end
    
T = T_next;
    T_aux = max(T);
    count = count+lim;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%% Main Loop end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f_aloc = 0;
for i = 1:Ship_qt
    f_aloc = f_aloc + c(1)*(mooring_time(i)-Ship(i).a) + c(2)*service_aloc(i);
end

opt_time = toc;

write_excel(arq, Ship_qt, Berth_qt, f_aloc, opt_time, Aloc, mooring_time, service_aloc, Pattern_selected)