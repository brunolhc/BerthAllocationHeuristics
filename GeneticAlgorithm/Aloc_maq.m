function[T_Ships, t_Ships, m_Ships] = Aloc_maq(aloc_N, Ship_qt, Berth_qt, Arrival_time, Ship_cargo, Machine_qt, M, min_M, max_M, rate)

berths = find(aloc_N == 0);
aloc_N = [aloc_N 0];
Position = [0, berths]+1;
T_berth = zeros(Berth_qt,1);
T_Ships = zeros(Ship_qt, 1);
t_Ships = zeros(Ship_qt,1);
m_Ships = zeros(Machine_qt, Ship_qt);
Berth_qt_aux = Berth_qt;
M_berth = zeros(Machine_qt,Berth_qt);
Ship_berth = zeros(Ship_qt,1);
aux = 1;
for i = 1:Ship_qt+Berth_qt-1
    if(aloc_N(i) == 0)
        aux = aux+1;
    else
        Ship_berth(aloc_N(i)) = aux;
    end
end

% Verify if berth schedule ends
%     aux_P = [];
%     aux = 0;
%     for i = 1:Berth_qt_aux
%         if aloc_N(Position(i)) == 0
%             aux_P = [aux_P i];
%             aux = aux+1; %number of active berths
%             if Berth_qt_aux - aux == 0
%                 break;
%             end
%         end
%     end

aux_P = find(aloc_N(Position)==0);
Berth_qt_aux = Berth_qt_aux - length(aux_P);
Position(aux_P) = [];

while Berth_qt_aux
    
    T_berth_max(1:Berth_qt_aux) = max(T_berth);
    
    % first optimize to find first reference values
    [~,T,t,~,~] = ConstroiModelo(Berth_qt_aux, Machine_qt, max_M, min_M, ...
        Ship_cargo(aloc_N(Position)), rate, M, Arrival_time(aloc_N(Position)), T_berth_max, [], []);
    
    T_min_end = min(T + t);
    %find concorrent berths, and eliminate ships with no concorrent service
    Set = find(T<T_min_end);
    Ship_qt_aux = length(Set);
    
    T_berth_max = zeros(1,length(Set));
    for j = 1:length(Set)
        T_berth_max(j) = max(T_berth);
    end
    
    %second optimization, only with concorrent ships
    [m,T,t,f,~] = ConstroiModelo(Ship_qt_aux, Machine_qt, max_M, min_M, ...
        Ship_cargo(aloc_N(Position(Set))), rate, M, Arrival_time(aloc_N(Position(Set))), T_berth_max, [], []);
    
    [~,I_ord] = sort(T_berth(Ship_berth(aloc_N(Position(Set)))));
    
    T_berth_aux(1:Ship_qt_aux) = T_berth(Ship_berth(aloc_N(Position(Set(I_ord(Ship_qt_aux))))));
    %find the best time
    A_add = []; b_add = [];
    for i = Ship_qt_aux:-1:1
        a = zeros(Machine_qt, Ship_qt_aux*(Machine_qt+2));
        b_aux = zeros(Machine_qt,1);
        
        for j = 0:Machine_qt-1
            %if(sum(M_berth(Ship_berth(aloc_N(Position(Set(I_ord(1:i)))))))>0)
            a(j+1, I_ord(1:i)+j*Ship_qt_aux) = 1;
            b_aux(j+1) = M(j+1) - sum(M_berth(j+1,...
                find(T_berth > max(T_berth(Ship_berth(aloc_N(Position(Set(I_ord(i)))))), Arrival_time(aloc_N(Position(Set(I_ord(i)))))))));
            %end
        end
        
                %Faltou regredir o tempo?
        T_berth_aux1 = T_berth_aux;
        for j = 1:i-1
            T_berth_aux1(j) = T_berth(Ship_berth(aloc_N(Position(Set(I_ord(i))))));
        end
        
        [m_aux,T_aux,t_aux,f_aux,exitflag] = ConstroiModelo(Ship_qt_aux, Machine_qt, max_M, min_M, ...
            Ship_cargo(aloc_N(Position(Set))), rate, M, Arrival_time(aloc_N(Position(Set))), T_berth_aux1, [A_add; a], [b_add; b_aux]);
        
        % Adiciona restrições de maximo de maquinas
        if(f_aux < f)
            A_add = [A_add; a];
            b_add = [b_add; b_aux];
            f = f_aux; m = m_aux; T = T_aux; t = t_aux;
            for j = 1:i-1
                T_berth_aux(j) = T_berth(Ship_berth(aloc_N(Position(Set(I_ord(i))))));
            end
        else
            T_berth_aux = T;
        end
    end
    
    % update positions and result
    m_Ships(:,aloc_N(Position(Set))) = m;
    t_Ships(aloc_N(Position(Set))) = t;
    T_Ships(aloc_N(Position(Set))) = T;
    T_berth(Ship_berth(aloc_N(Position(Set)))) = T_Ships(aloc_N(Position(Set)))+t_Ships(aloc_N(Position(Set)));
    
    M_berth(:,Ship_berth(aloc_N(Position(Set)))) = m_Ships(:,aloc_N(Position(Set)));
    Position(Set) = Position(Set)+1;
    
    
    % Verify if berth schedule ends
    %    aux_P = [];
    %    aux = 0;
    %     for i = 1:Berth_qt_aux
    %         if aloc_N(Position(i)) == 0
    %             aux_P = [aux_P i];
    %             aux = aux+1; %number of active berths
    %             if Berth_qt_aux - aux == 0
    %                 break;
    %             end
    %         end
    %     end
    aux_P = find(aloc_N(Position)==0);
    Berth_qt_aux = Berth_qt_aux - length(aux_P);
    Position(aux_P) = [];
    
end
%