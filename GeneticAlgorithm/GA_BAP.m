function [ sol, t_sol, T_sol, machine_sol ] = GA_BAP( path, name )
% M - Quantity of machine types
% N - Quantity of ships
% B - Quantity of berths
% Ship is a structure, contains:
%       Ship(i).name - name of ship i (used to be i)
%       Ship(i).a - arrival time of ship i
%       Ship(i).b - max time of ship i
%       Ship(i).q - cargo of ship i
% Machine is a structure, contains:
%       Machine(i).q - available of machine type i
%       Machine(i).v - tax of machine type i

fprintf('Test: %s \n',name);
filename = strcat(path, name);

addpath('C:\Program Files\IBM\ILOG\CPLEX_Studio126\cplex\matlab\x64_win64');
% Reads date from an excel file
[Ship, Ship_qt, Machine, Machine_qt, Berth_qt, max_machine, ...
    min_machine, ~, c] = LeExcel(path, name);

%Validates the number of machines and berths
[Berth_qt] = ValidaDados(Machine, Machine_qt, Berth_qt, min_machine);

size_pop = 25; %min(2*Ship_qt,30);
max_it = 20;

%%%%%%%%%%%%%%%%%%%%%%%%% Initial declaration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
size_pop_tg = round(0.35*size_pop); % Targeted BAP populations
size_pop_fifo = round(0.45*size_pop);

tax_med = zeros(1,Berth_qt); % Mean machine tax
t_est = zeros(Ship_qt,Berth_qt); % Estimated berth time

pop = zeros(Ship_qt+Berth_qt-1,size_pop);
mut = round(0.05*size_pop);
if mut == 0
    mut = 1;
end

fit_sol = 0;
cont = 0;
c(1) = 4; % Coef of T
c(2) = 1; % Coef of t
%%%%%%%%%%%%%%%%%%%%%%% Initial declaration end %%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% Find mean tax of machines in berths %%%%%%%%%%%%%%%%%
for i = 1:Berth_qt
    tax_b = 1000*((Machine(1).q/Berth_qt)*Machine(1).v);
    for j = 1:Machine_qt
        tax_a = (Machine(j).q/Berth_qt)*Machine(j).v;
        if tax_a <= tax_b
            tax_b = tax_a;
        end
    end
    tax_med(i) = tax_b;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%% Initial pop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fit_pop = zeros(1, size_pop);
z_pop = zeros(1, size_pop);
T = zeros(Ship_qt, size_pop);
t = zeros(Ship_qt, size_pop);
machine_used = zeros(Machine_qt, Ship_qt, size_pop);

pop(:, 1:size_pop_tg) = ...
    TargetedPop_BAP(Ship, Ship_qt, Berth_qt, t_est, size_pop_tg);
pop(:, size_pop_tg+size_pop_fifo+1:size_pop) = ...
    RandomPop_BAP(Ship_qt, Berth_qt, size_pop-size_pop_tg-size_pop_fifo);

[fifo_time, fifo_service, Aloc1, fifo_machine, Fifo_Machine_Berth, fifo_f] = ...
    FIFO(Ship, Ship_qt, Machine, Machine_qt, Berth_qt, min_machine, max_machine, c, filename);

% Transforms the matricial solution form in the vector form
[fifo_aloc] = MatrixSolToVectorial(Ship_qt, Berth_qt, Aloc1);

for i = size_pop_tg+1:size_pop_tg+size_pop_fifo
    pop(:, i) = fifo_aloc;
end

for i = size_pop_tg+1:size_pop_tg+size_pop_fifo
    T(:,i) =  fifo_time(:);
    t(:,i) = fifo_service(:);
    z_pop(i) = fifo_f;
    fit_pop(i) = 1/(z_pop(i)+1);
    machine_used(:,:,i) = fifo_machine';
%     for j = 1:Ship_qt
%         for k = 1:Machine_qt
%             machine_used(k,j,i) = fifo_machine(j,k);
%         end
%     end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%% Main loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for it = 1:max_it
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% Create new individuals %%%%%%%%%%%%%%%%%%%%%
    % Mixed of OX and PMX tachinics
    
    % Allocate positions for new individuals
    sons = zeros(Ship_qt+Berth_qt-1,4*size_pop);
    T_sons = zeros(Ship_qt,4*size_pop);
    t_sons = zeros(Ship_qt,4*size_pop);
    fit_sons = zeros(1,4*size_pop);
    z_sons = zeros(1,4*size_pop);
    machine_used_sons = zeros(Machine_qt, Ship_qt, 4*size_pop);
    
    for i = 1:size_pop
        a = randi(size_pop); b = randi(size_pop);
        
        % Recombinations
        [sons(:,i), sons(:,size_pop+i)] = PMX_BAP( pop(:,a), pop(:,b), ...
            Ship_qt+Berth_qt-1 );
        [sons(:,2*size_pop+i), sons(:,3*size_pop+i)] = OX_BAP( pop(:,a), ...
            pop(:,b), Ship_qt+Berth_qt-1 );
    end
    
    % Allocate machines
    for i = 1:4*size_pop
        [T_sons(:,i), t_sons(:,i), machine_used_sons(:,:,i)] = ...
            Aloc_maq(sons(:,i)', Ship_qt, Berth_qt, [Ship(:).a], [Ship(:).q], ...
            Machine_qt, [Machine(:).q], min_machine, max_machine, [Machine(:).v]);
        % Try a equilibrated allocation
        [ mt, st, fifo_machine,zb, fb ] = ...
            EvalF(Ship, Ship_qt, Machine, Machine_qt, Berth_qt, Fifo_Machine_Berth, sons(:,i)', c);
        z_sons(i) = c(1)*sum(T_sons(:,i)-[Ship(:).a]')+c(2)*sum(t_sons(:,i));
        fit_sons(i) = 1/(z_sons(i)+1);
        if fb > fit_sons(i)
            T_sons(:,i) = mt;
            t_sons(:,i) = st;
            machine_used_sons(:,:,i) = fifo_machine';
            z_sons(i) = zb;
            fit_sons(i) = fb;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%% Select individuals %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pop_ext = [pop, sons];
    fit_ext = [fit_pop, fit_sons];
    z_ext = [z_pop, z_sons];
    T_ext = [T, T_sons];
    t_ext = [t, t_sons];
    machine_ext = zeros(Machine_qt, Ship_qt, 5*size_pop);
    machine_ext(:,:,1:size_pop) = machine_used;
    machine_ext(:,:,size_pop+1:5*size_pop) = machine_used_sons;
    
    % Find best solution until current iteration
    [f_y,index] = max(fit_ext);
    if f_y > fit_sol
        fit_sol = f_y;
        sol = pop_ext(:,index);
        T_sol = T_ext(:,index);
        t_sol = t_ext(:,index);
        z_sol = z_ext(index);
        fprintf('best_sol:%f \n',z_sol);
        machine_sol = machine_ext(:,:,index);
        cont = 0;
        filename = strcat(path, name,'.xlsb');
        matrix_sol = VectorialSolToMatrix(sol,Ship_qt,Berth_qt);
        write_excel(filename, Ship_qt, Berth_qt, z_sol, -1, matrix_sol, T_sol, t_sol, machine_sol);
    else
        cont = cont+1;
        if cont>=8
            break;
        end
    end
    
    %Torneio
%         for i = 1:size_pop
%             a = randi(5*size_pop);
%             b = randi(5*size_pop);
%             [pop(:,i), fit_pop(i), z_pop(i), T(:,i), t(:,i), machine_used(:,:,i)] = ...
%                 Torneio_BAP(pop_ext(:,a), pop_ext(:,b), fit_ext(a), ...
%                 fit_ext(b), z_ext(a), z_ext(b), T_ext(:,a), T_ext(:,b), ...
%                 t_ext(:,a), t_ext(:,b), machine_ext(:,:,a), machine_ext(:,:,b));
%         end
%     
    
    %Take best individuals
    [~, I_ord] = sort(fit_ext);
    fit_pop = fit_ext(I_ord(4*size_pop+1:5*size_pop));
    z_pop = z_ext(I_ord(4*size_pop+1:5*size_pop));
    pop = pop_ext(:,I_ord(4*size_pop+1:5*size_pop));
    T = T_ext(:,I_ord(4*size_pop+1:5*size_pop));
    t = t_ext(:,I_ord(4*size_pop+1:5*size_pop));
    machine_used = machine_ext(:,:,I_ord(4*size_pop+1:5*size_pop));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Mutation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Random position exchange
    
    for i = 1:mut
        a = randi(size_pop);
        aux = Mutation_BAP( pop(:,a), Ship_qt+Berth_qt-1 );
        [aux_T, aux_t, aux_m] = Aloc_maq(aux', Ship_qt, Berth_qt, ...
            [Ship(:).a], [Ship(:).q], Machine_qt, [Machine(:).q], ...
            min_machine, max_machine, [Machine(:).v]);
        z_fit = c(1)*sum(aux_T-[Ship(:).a]')+c(2)*sum(aux_t);
        aux_fit = 1/(1+z_fit);
        %if aux_fit > 0 %> fit_pop(a)
        fit_pop(a) = aux_fit;
        z_pop(a) = z_fit;
        pop_ext(:,a) = aux;
        T_ext(:,a) = aux_T;
        t_ext(:,a) = aux_t;
        machine_ext(:,:,a) = aux_m;
        %end
    end
    fprintf('iteration:%d \n',it);
end

tempo = toc;
fprintf('Total time:%f| Best Sol:%f \n',tempo, z_sol);

filename = strcat(path, name,'.xlsb');

matrix_sol = VectorialSolToMatrix(sol,Ship_qt,Berth_qt);
write_excel(filename, Ship_qt, Berth_qt, z_sol, tempo, matrix_sol, T_sol, t_sol, machine_sol);

%clear all;
end

