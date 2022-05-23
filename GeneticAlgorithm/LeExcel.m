function[Ship, Ship_qt, Machine, Machine_type, Berth_qt, max_machine, ...
    min_machine, M, c] = LeExcel(path, name)
% LeExcel - reads the data of a excel file (with the corect format)
%   path - excel path
%   name - name of excel file
%   Machine_type - Number of machine types
%   M - Large number
%   Berth_qt - Number of berths
%   max_machine - maximum working machines at same time on a ship
%   min_machine - minimum working machines at same time on a ship
%   c - coef of the objective function
%   Ship is a structure, conteins at least:
%       Ship(i).a - Arrival time of ship i
%       Ship(i).b - Max time of ship i
%   Machine is a structure, contains:
%       Machine(i).q - available of machine type i
%       Machine(i).v - tax of machine type i


arq = strcat(path,name); %'C:\Users\Bruno\Dropbox\Unicamp\Doutorado\MatLab\Heuristicav2\Testes\'
arq = strcat(arq,'.xlsb');


Ship_qt = xlsread(arq,'Data','A2');
Berth_qt = xlsread(arq,'Data','A5');
Machine_type = xlsread(arq,'Data','A14');
M = xlsread(arq,'Data','A11');

Ship(:).q = zeros(1,Ship_qt);
for i = 1:Ship_qt
    Ship(i).q = xlsread(arq,'Data',strcat('G', num2str(i+3)));
    Ship(i).a = xlsread(arq,'Data',strcat('E', num2str(i+3)));
    Ship(i).b = xlsread(arq,'Data',strcat('F', num2str(i+3)));
end

%Machine(i).q = zeros(1,Machine_type);
max_machine = zeros(1,Machine_type);
min_machine = zeros(1,Machine_type);
for i = 1:Machine_type
    Machine(i).q = xlsread(arq,'Data',strcat('K', num2str(i+4)));
    Machine(i).v = xlsread(arq,'Data',strcat('L', num2str(i+4)));
    max_machine(i) = xlsread(arq,'Data',strcat('N', num2str(i+4)));
    min_machine(i) = xlsread(arq,'Data',strcat('M', num2str(i+4)));
end

c(1)=4;
c(2) = 1;