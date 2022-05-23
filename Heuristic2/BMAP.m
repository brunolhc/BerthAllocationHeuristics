function [ mooring_time, service_time, Pattern_selected, Aloc, f_aloc ] = BMAP(path, name, fl) % Ship, N, B, Machine_qt, Pattern, Machine,service_time,Pattern_qt
%   Create the initial pop of a GA, trying to find good solutions
% N - Quantity of ships
% B - Quantity of berths
% t_est(N,B) - Estimated handling time
% size_pop - Size of population
% Ship is a structure, conteins at least:
%       Ship(i).a - Arrival time of ship i
%       Ship(i).b - Max time of ship i

fprintf('Test: %s \n',name);

addpath('C:\Program Files\IBM\ILOG\CPLEX_Studio126\cplex\matlab\x64_win64');

% Reads date from an excel file
fprintf('excel read: begins');
[Ship, Ship_qt, Machine, Machine_qt, Berth_qt, max_machine, ...
    min_machine, ~, c] = LeExcel(path, name);
fprintf('excel read: ends');

%Validates the number of machines and berths
[Berth_qt] = ValidaDados(Machine, Machine_qt, Berth_qt, min_machine);


tic

f_best = 999999999;

%tolerance wait
%cg = max([Ship(:).q]);
cg = mean([Ship(:).q]);
tax = 10000000;
for i = 1:Machine_qt
    aux = Machine(i).q*Machine(i).v/Berth_qt;
    if tax > aux
        tax = aux;
    end
end
st = cg/tax;

for fator = 0:0.05:1.0
    fprintf('fator: %f \n',fator);
    
    % Arrumar
    tol_wait = fator*st;%soma/total;    
    
    %%%%%%%%%%%%%%%%%%%%%%%%% Main Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Aloc = zeros(Ship_qt,Berth_qt); % Matricial form of a solution
    count = 0;
    T_aux = 0; % Last Berth time
    ind_us = 1:Ship_qt; % Ind of unsigned ships
    trys_orig = 8;
    
    Berth_time = zeros(Berth_qt,trys_orig); % Berth time
    Machine_berth = zeros(Machine_qt,Berth_qt,trys_orig);
    mooring_time = zeros(Ship_qt,trys_orig);
    service_time = zeros(Ship_qt,trys_orig);
    m_Ships = zeros(Machine_qt,Ship_qt,trys_orig);
    
    while count < Ship_qt % While there are ships unsigned
        
        fprintf('\t Count: %d | Remain: %d \n',count,(Ship_qt-count));
        
        %trys_orig = 8;
        [ship, lim, Aloc] = PreOpt(Ship, Berth_qt, ind_us, T_aux, Aloc, tol_wait, Berth_time(:,1)); %tol_wait
        
        f = zeros(1,trys_orig); p = 1;A_add = []; b_add = [];% a = []; b_aux = [];
        %%%%%%%%%%%%%%%%% find the machine alocation %%%%%%%%%%%%%%%%%%%%%%
        while p < trys_orig
            
            fprintf('\t \t Try: %d',p);
    
            [mooring_time(:,p), service_time(:,p), m_Ships(:,:,p), f_B, Berth_time(:,p), Machine_berth(:,:,p), exitflag] = ...
                BackTimeCheck(mooring_time(:,p), service_time(:,p), m_Ships(:,:,p), Machine_qt, Machine, Machine_berth(:,:,p), Ship, Berth_time(:,p), max_machine, min_machine, lim, ship, A_add, b_add);
            
            if exitflag == -2
                f(p:trys_orig) = inf; 
                break;
            end
            
            % update next position too
            mooring_time(:,p+1) = mooring_time(:,p);
            service_time(:,p+1) = service_time(:,p);
            m_Ships(:,:,p+1) = m_Ships(:,:,p); 
            Berth_time(:,p+1) = Berth_time(:,p);
            Machine_berth(:,:,p+1) = Machine_berth(:,:,p);
            f(p) = f(p) + f_B; f(p+1) = f(p);
            
            % evaluate the minimum efficiency (for the next iteration)
            alpha = 99999999;
            for j = 1:lim
                m_total = sum(m_Ships(:,ship(j),p));
                for k = 1:Machine_qt
                    aux_alpha = Machine(k).v*m_Ships(k,ship(j),p)/m_total;
                    if aux_alpha < alpha
                        alpha = aux_alpha;
                    end
                end
            end
            
            % force the machine allocation to be more effective
            [A_add,b_add] = CalcRendMin(lim,Machine_qt,[Machine(:).v],alpha+1,m_Ships(:,ship,p));

            p = p+2;
            
        end
        %%%%%%%%%%%%%%%%%%%%%% Back time check end %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        T_aux = max(max(Berth_time));
        ind_us = setdiff(ind_us,ship);
        count = count+lim;
        
        if count >= Ship_qt
            break;
        end

        [ship, lim, Aloc] = PreOpt(Ship, Berth_qt, ind_us, T_aux, Aloc, tol_wait, Berth_time(:,1));
        
        A_add = []; b_add = []; p=1;
        %%%%%%%%%%%%%%%%% find second machine alocation %%%%%%%%%%%%%%%%%%%%%%
        while p <= trys_orig
            if f(p) == inf 
                p = p+1;
                continue;
            end
            
            % force the machine allocation to be more effective
            if mod(p,2) == 0 %par
                % evaluate the minimum efficiency (for the next iteration)
                alpha = 99999999;
                for j = 1:lim
                    m_total = sum(m_Ships(:,ship(j),p));
                    for k = 1:Machine_qt
                        aux_alpha = Machine(k).v*m_Ships(k,ship(j),p)/m_total;
                        if aux_alpha < alpha
                            alpha = aux_alpha;
                        end
                    end
                end
                [A_add,b_add] = CalcRendMin(lim,Machine_qt,[Machine(:).v],alpha+1,m_Ships(:,ship,p));
            else
                A_add = []; b_add = [];
            end

            [mooring_time(:,p), service_time(:,p), m_Ships(:,:,p), f_B, Berth_time(:,p), Machine_berth(:,:,p), ~] = ...
                BackTimeCheck(mooring_time(:,p), service_time(:,p), m_Ships(:,:,p), Machine_qt, Machine, Machine_berth(:,:,p), Ship, Berth_time(:,p), max_machine, min_machine, lim, ship, A_add, b_add);
            
            if exitflag == -2
                f(p) = inf;
            else
                f(p) = f(p) + f_B;
            end

            p = p+1;

        end
        %%%%%%%%%%%%%%%%%%%%%% Second Back time check end %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        T_aux = max(max(Berth_time));
        ind_us = setdiff(ind_us,ship);
        count = count+lim;
        
        if count >= Ship_qt
            break;
        end
        
        [ship, lim, Aloc] = PreOpt(Ship, Berth_qt, ind_us, T_aux, Aloc, tol_wait, Berth_time(:,1));
        
        A_add = []; b_add = []; p=1;
        %%%%%%%%%%%%%%%%% find tird machine alocation %%%%%%%%%%%%%%%%%%%%%%
        while p <= trys_orig
            
            [mooring_time(:,p), service_time(:,p), m_Ships(:,:,p), f_B, Berth_time(:,p), Machine_berth(:,:,p), ~] = ...
                BackTimeCheck(mooring_time(:,p), service_time(:,p), m_Ships(:,:,p), Machine_qt, Machine, Machine_berth(:,:,p), Ship, Berth_time(:,p), max_machine, min_machine, lim, ship, A_add, b_add);
            
            f(p) = f(p) + f_B;
            p = p+1;

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % select the best combination to continue
        [~, ind_comb] = min(f);
        for p = 1:trys_orig
            service_time(:,p) = service_time(:,ind_comb);
            mooring_time(:,p) = mooring_time(:,ind_comb);
            m_Ships(:,:,p) = m_Ships(:,:,ind_comb);
            Berth_time(:,p) = Berth_time(:,ind_comb);
            Machine_berth(:,:,p) = Machine_berth(:,:,ind_comb);
            f(p) = f(ind_comb);
        end    
        
        T_aux = max(max(Berth_time));
        ind_us = setdiff(ind_us,ship);
        count = count+lim;

    end
    %%%%%%%%%%%%%%%%%%%%%%%%% Main Loop end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % select the best combination to continue
    [~, ind_comb] = min(f);
    for j = 1:trys_orig
        service_time(:,p) = service_time(:,ind_comb);
        mooring_time(:,p) = mooring_time(:,ind_comb);
        m_Ships(:,:,p) = m_Ships(:,:,ind_comb);
        Berth_time(:,p) = Berth_time(:,ind_comb);
        Machine_berth(:,:,p) = Machine_berth(:,:,ind_comb);
        f(p) = f(ind_comb);
    end
    
    f_aloc = 0;
    for i = 1:Ship_qt
        f_aloc = f_aloc + c(1)*(mooring_time(i,1)-Ship(i).a) + c(2)*service_time(i,1);
    end
    
    if f_aloc < f_best
        f_best = f_aloc;
        Aloc_best = Aloc;
        mooring_best = mooring_time(:,1);
        service_best = service_time(:,1);
        m_Ships_best = m_Ships(:,:,1);
    end
    
end

opt_time = toc;

filename = strcat(path, name,'.xlsb');

f_best

write_excel(filename, Ship_qt, Berth_qt, f_best, opt_time, Aloc_best, mooring_best, service_best, m_Ships_best);

clear all
end