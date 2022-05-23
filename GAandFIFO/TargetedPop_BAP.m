function [ pop ] = TargetedPop_BAP( Ship, N, B, t_est, size_pop )
%   Create the initial pop of a GA, trying to find good solutions
% N - Quantity of ships
% B - Quantity of berths
% t_est(N,B) - Estimated handling time
% size_pop - Size of population
% Ship is a structure, conteins at least:
%       Ship(i).a - Arrival time of ship i
%       Ship(i).b - Max time of ship i

pop = zeros(N+B-1,size_pop); % Population

%%%%%%%%%%%%%%%%%%%%%%%%% Main Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for p = 1:size_pop
    T = zeros(B,1); % Berth time
    pop_aux = zeros(N,B); % Matricial form of a solution
    count = 1;
    T_aux = 0; % Last Berth time
    ind_us = 1:N; % Ind of unsigned ships
    
    
    while count <= N % While there are ships unsigned
        % Find waiting ships
        ind_s = zeros(1,length(ind_us)); % ind of wating ships
        k = 1;
        for i = 1:length(ind_us)
            if Ship(ind_us(i)).a <= T_aux
                ind_s(k) = ind_us(i);
                k = k+1;
            end
        end
        
        % Remove nulls(Berths)
        ind_s(ind_s == 0) = [];
        
        % If there aren't ships waiting, find next arrival time
        if length(ind_s) <= 0;
            T_aux = min([Ship(ind_us).a]);
            ind_s = size(length(ind_us),1);
            k=1;
            for i = 1:length(ind_us)
                if Ship(ind_us(i)).a <= T_aux +0.0001
                    ind_s(k) = ind_us(i);
                    k=k+1;
                end
            end
            
            % Remove nulls (Berths)
            ind_s(ind_s==0) = [];
        end
        
        % Find free berths
        ind_b = find(T <= T_aux + 0.0001); % Find free berths
        
        % If there are ships waiting, assign to a free berth (select a
        %random wating ship)
        s = ind_s(randi(length(ind_s)));
        b = ind_b(randi(length(ind_b)));
        
        aux = find(pop_aux(:,b)==0, 1, 'first');
        pop_aux(aux,b) = s;
        
        % Remove the assigned ships
        ind_us = setdiff(ind_us,s);
        
        T(b) = max(T(b),Ship(s).a) + t_est(s,b);
        
        T_aux = min(T);
        count = count+1;
            
    end

    % Transforms the matricial solution form in the vector form
    k = 1; i = 1; count = 1; count2 = 0;
    while count <= N+B-1 && count2 < N
        if pop_aux(i,k) == 0
            if i ~= 1
                count = count+1; i = 1;
            end
            k = k+1;
        else
            pop(count,p) = pop_aux(i,k);
            i = i+1; count = count+1; count2 = count2+1;
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%% Main Loop end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        