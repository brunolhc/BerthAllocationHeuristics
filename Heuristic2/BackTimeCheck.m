function[mooring_time, service_time, m_Ships, f, Berth_time, Machine_berth, exitflag] = ...
    BackTimeCheck(mooring_time, service_time, m_Ships, Machine_qt, Machine, Machine_berth, Ship, Berth_time, max_machine, min_machine, lim, ship, A_add, b_add)

M = [Machine(:).q];
f = inf;

% find the maximum end time to be the first reference
T_berth_max(1:lim) = max(Berth_time);

% first optimize to find first reference values
[m,T,t,f,exitflag] = ConstroiModelo(lim, Machine_qt, max_machine, min_machine, ...
    [Ship(ship).q], [Machine(:).v], M, [Ship(ship).a], T_berth_max, A_add, b_add);

if exitflag == -2
    return
end

% sort the initial time
[~,I_ord] = sort(Berth_time);
T_berth_aux(1:lim) = Berth_time(I_ord(lim));

a = []; b_aux = [];
% find the best time
for i = lim:-1:1

    % Add maximum machine constraints, to reduce the time windows
    a = zeros(Machine_qt, lim*(Machine_qt+2));
    b_aux = zeros(Machine_qt,1);
    for j = 0:Machine_qt-1
        a(j+1, (1:i)+j*lim) = 1;
        b_aux(j+1) = Machine(j+1).q - sum(Machine_berth(j+1,...
            find(Berth_time > Berth_time(I_ord(i)))));
        % b_aux(j+1) = sum(Machine_berth(j+1,find(Berth_time >= Berth_time((I_ord(i))))));
    end
    
    T_berth_aux1 = T_berth_aux;
    for j = 1:i
        T_berth_aux1(j) = Berth_time(I_ord(i));
    end

    
    [m_aux,T_aux,t_aux,f_aux,exitflag] = ConstroiModelo(lim, Machine_qt, max_machine, min_machine, ...
        [Ship(ship).q], [Machine(:).v], M, [Ship(ship).a], T_berth_aux1, [A_add; a], [b_add; b_aux]);
    
    % verify if have upgrade on the function value
    if(f_aux < f)
        A_add = [A_add; a];
        b_add = [b_add; b_aux];
        f = f_aux; m = m_aux; T = T_aux; t = t_aux;
        for j = 1:i-1
            T_berth_aux(j) = Berth_time(I_ord(i));
        end
    end
end

% update positions and result
exitflag = 1;
m_Ships(:,ship) = m;
Machine_berth(:,I_ord(1:lim)) = m_Ships(:,ship);

service_time(ship) = t;
mooring_time(ship) = T;

Berth_time(I_ord(1:lim)) = mooring_time(ship)+service_time(ship);