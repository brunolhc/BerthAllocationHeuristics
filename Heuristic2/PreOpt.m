function[ship, lim, Aloc] = PreOpt(Ship, Berth_qt, ind_us, T_aux, Aloc, tol_wait, Berth_time)

% Find waiting ships
ind_wait = zeros(1,length(ind_us)); % ind of wating ships
k = 1;

for i = 1:length(ind_us)
    if Ship(ind_us(i)).a <= T_aux + tol_wait
        ind_wait(k) = ind_us(i);
        k = k+1;
    end
end

% Remove nulls(Berths) ???
ind_wait(ind_wait == 0) = [];
% If there aren't ships waiting, find next arrival time
if length(ind_wait) <= 0;
    T_aux = min([Ship(ind_us).a]);
    ind_wait = size(length(ind_us),1);
    k=1;
    for i = 1:length(ind_us)
        if Ship(ind_us(i)).a <= T_aux
            ind_wait(k) = ind_us(i);
            k=k+1;
        end
    end
    
    % Remove nulls (Berths)
    ind_wait(ind_wait==0) = [];
end

% Find free berths
ind_b = find(Berth_time <= T_aux); % Find free berths


% If there are ships waiting, assign to a free berth (select min
% cargo ship)
[~,ind_wait_sorted] = sort([Ship(ind_wait).q]);
[~,ind_berth_sorted] = sort(Berth_time(ind_b));

pos_berth = zeros(1,Berth_qt);
for i = 1:Berth_qt
    pos_berth(i) = find(Aloc(:,i)==0, 1, 'first');
end

lim = min(length(ind_berth_sorted), length(ind_wait_sorted));
for i = 1:lim
    Aloc(pos_berth(ind_b(ind_berth_sorted(i))),ind_b(ind_berth_sorted(i))) = ...
        ind_wait(ind_wait_sorted(i));
end

ship = ind_wait(ind_wait_sorted(1:lim));