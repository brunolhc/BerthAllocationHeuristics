function[Port_P, Port_P_tax, service_time] = selectedPortPattern(arq)
% Machine_type - Number of machine types
% M - Large number
% Berth_qt - Number of berths
% Ship is a structure, contains:
%       Ship(i).a - arrival time of ship i
%       Ship(i).b - max time of ship i
%       Ship(i).q - cargo of ship i
% Machine is a structure, contains:
%       Machine(i).q - available of machine type i
%       Machine(i).v - tax of machine type i

%arq = 'C:\Users\Lenovo\Dropbox\Unicamp\Doutorado\MatLab\Heuristica\Testes\Test_Case_30B100N6745.xlsb'
%if nargin == 3
    %if strcmp(tipo,'xlsb')
        %arq = strcat(path,name); %'C:\Users\User\opl\PBAP\'
        %arq = strcat(arq,'.xlsb');
        
        
        Ship_qt = xlsread(arq,'Data','A2');
        Berth_qt = xlsread(arq,'Data','A5');
        Machine_type = xlsread(arq,'Data','A14');
        M = xlsread(arq,'Data','A11');
        
        Ship(:).q = zeros(1,Ship_qt);
        for i = 1:Ship_qt
            Ship(i).q = xlsread(arq,'Data',strcat('G', num2str(i+3)));
        end
        
        Machine(i).q = zeros(1,Machine_type);
        % Machine(i).v = zeros(1,Machine_type);
        maxM = zeros(1,Machine_type);
        for i = 1:Machine_type
            Machine(i).q = xlsread(arq,'Data',strcat('K', num2str(i+4)));
            Machine(i).v = xlsread(arq,'Data',strcat('L', num2str(i+4)));
            maxM(i) = xlsread(arq,'Data',strcat('N', num2str(i+4)));
        end
        
%     else
%         
%         [Ship, Machine, Berth_qt, Machine_type, Ship_qt, M, ~, maxM] = feval(name);
%         
%     end
% end


% Create berths patterns
P = [];
[~, index, ~, ~, ~, ~, P] = AllCombs(1, 1, ones(1,Machine_type), ones(1,Machine_type), maxM, Machine_type, P);
Pattern_qt = index -1;

[~,~,qt_aux] = size(P);
P(:,:,Pattern_qt+1:qt_aux) = [];


%Remove uncombinable patterns
[P, Pattern_qt] = Uncombinable_Pattern(P, Machine, Pattern_qt, Machine_type);

% Calculate the tax of remaining berths patterns
tax = zeros(1,Pattern_qt);
for j = 1:Pattern_qt
    tax(j) = Pattern_tax(Machine, P(:,j), Machine_type);
end

% Remove inefficient patterns
[P, tax, Pattern_qt] = Eficiency_Verify(Machine, P, tax, Machine_type, Pattern_qt);

% Add the zero pattern
P = [zeros(Machine_type,1),P];
tax = [0 tax];
zeroIndex = 1;
Pattern_qt = Pattern_qt + 1;

% Add max pattern
P = [P, maxM'];
tax = [tax Pattern_tax(Machine, maxM', Machine_type)];
maxIndex = Pattern_qt + 1;
Pattern_qt = Pattern_qt + 1;

aux = []; aux_tax = [];
i=1;
index = 1;
Berth_qt = Berth_qt;
Port_P = zeros(Machine_type, Berth_qt, 5); Port_P_tax = zeros(Berth_qt, 5);



%best efficience pattern
[~,index] = max(tax);

machineAcumutaled = zeros(Machine_type,1);
for i = 1:Berth_qt
    Port_P(:, i, 1) = P(:, index);
    Port_P_tax(i,1) = tax(index);
    machineAcumutaled = machineAcumutaled + P(:, index);
    for j = 1:Machine_type
        if machineAcumutaled(j)+ P(j, index) >= Machine(j).q
            index = zeroIndex;
        end
    end
end



% regulated pattern
Port_P_tax(:,2) = 9999999*ones(Berth_qt,1);
% Port_P(:,:,2) = zeros(Berth_qt,Machine_type);
for i = 1:Machine_type
    %aux = Machine(i).q*Machine(i).v/Berth_qt;
    machine = Machine(i).q;
    berth = Berth_qt;
    while berth > 0
        Port_P(i,berth,2) = ceil(machine/berth);
        machine = machine - ceil(machine/berth);
        berth = berth-1;
    end
end

for i = 1:Berth_qt
    for j = 1:Machine_type
        if Port_P_tax(i,2) > Port_P(j,i,2)*Machine(j).v
            Port_P_tax(i,2) = Port_P(j,i,2)*Machine(j).v;
        end
    end
end

% inverted regulated pattern
Port_P_tax(:,3) = 9999999*ones(Berth_qt,1);
% Port_P(:,:,2) = zeros(Berth_qt,Machine_type);
for i = 1:Machine_type
    %aux = Machine(i).q*Machine(i).v/Berth_qt;
    machine = Machine(i).q;
    berth = Berth_qt;
    while berth > 0
        Port_P(i,berth,3) = ceil(machine/berth);
        machine = machine - ceil(machine/berth);
        berth = berth-1;
    end
end

for i = 1:Berth_qt
    for j = 1:Machine_type
        if Port_P_tax(i,3) > Port_P(j,i,3)*Machine(j).v
            Port_P_tax(i,3) = Port_P(j,i,3)*Machine(j).v;
        end
    end
end



% maximum pattern
index = maxIndex;
machineAcumutaled = zeros(Machine_type,1);
for i = 1:Berth_qt
    Port_P(:, i, 4) = P(:, index);
    Port_P_tax(i,4) = tax(index);
    machineAcumutaled = machineAcumutaled + P(:, index);
    for j = 1:Machine_type
        if machineAcumutaled(j)+ P(j, index) >= Machine(j).q
            index = zeroIndex;
        end
    end
end



% inverted maximum pattern
[~,index] = max(tax);

machineAcumutaled = zeros(Machine_type,1);
for i = Berth_qt:-1:1
    Port_P(:, i, 5) = P(:, index);
    Port_P_tax(i,5) = tax(index);
    machineAcumutaled = machineAcumutaled + P(:, index);
    for j = 1:Machine_type
        if machineAcumutaled(j)+ P(j, index) >= Machine(j).q
            index = zeroIndex;
        end
    end
end

service_time = zeros(Ship_qt,Berth_qt,5);
for i = 1:Ship_qt
    for j = 1:Berth_qt
        for p = 1:5
            service_time(i,j,p) = Ship(i).q/Port_P_tax(j,p);
        end
    end
end
end

