function[m,T,t,f,exitflag] = ConstroiModelo(Ship_qt, Machine_qt, max_M, min_M, ...
    Ship_cargo, tax, M, Arrival_time, Berth_time, A_add, b_add)

%x = solution vector (m[i,alpha], T[i], t[i])

%addpath('C:\Program Files\IBM\ILOG\CPLEX_Studio126\cplex\matlab\x64_win64');
max_machine = max(max_M);

A = zeros(Machine_qt+Machine_qt*Ship_qt*max_machine, Ship_qt*(Machine_qt+2));
b = zeros(Machine_qt+Machine_qt*Ship_qt*max_machine, 1);
c = zeros(1,Ship_qt*(Machine_qt+2));
ub = 1000*ones(Ship_qt*(Machine_qt+2),1);
lb = zeros(Ship_qt*(Machine_qt+2),1);
ctype = char(Ship_qt*(Machine_qt+2),1);

lin = 1;
for j = 1:Machine_qt
    for i = 1:Ship_qt
        A(lin,(j-1)*Ship_qt+i) = 1;
        b(lin) = M(j);
    end
    lin = lin+1;
end

for j = 1:Machine_qt
    for i = 1:Ship_qt
        for k = 2:max_machine
            A(lin,i+Ship_qt*(Machine_qt+1)) = -1;
            A(lin,i+(j-1)*Ship_qt) = -Ship_cargo(i)/(tax(j)*(k-1)) + Ship_cargo(i)/(tax(j)*k);
            b(lin) = -k*(Ship_cargo(i)/(tax(j)*(k-1)) - Ship_cargo(i)/(tax(j)*k)) - Ship_cargo(i)/(tax(j)*k);
            lin = lin+1;
        end
    end
end

for j = 1:Machine_qt
    for i = 1:Ship_qt
        ub(i+(j-1)*Ship_qt) = max_M(j);
        lb(i+(j-1)*Ship_qt) = min_M(j);
    end
end

lin = Ship_qt*Machine_qt;
for i = 1:Ship_qt
    lb(lin+i) = max(Arrival_time(i), Berth_time(i));
    c(lin+i) = 4;
    c(lin+Ship_qt+i) = 1;
end

for i = 1:Ship_qt*Machine_qt
    ctype(i) = 'I';
end
for i = Ship_qt*Machine_qt+1:Ship_qt*(Machine_qt+2)
    ctype(i) = 'C';
end
% Ship_qt, Machine_qt, max_M, min_M, ...
%     Ship_cargo, tax, M, Arrival_time, Berth_time, A_add, b_add
% size(c),size([A; A_add]),size([b; b_add]),size(lb),size(ub),size(ctype')
% x = cplexmilp(f,Aineq,bineq,Aeq,beq,sostype,sosind,soswt,lb,ub,ctype)
[x,f,exitflag] = cplexmilp(c,[A; A_add],[b; b_add],[],[],[],[],[],lb,ub,ctype');

m = zeros(Machine_qt, Ship_qt);
% T = zeros(1, Ship_qt);
% t = zeros(1,Ship_qt);

if exitflag ~= -2
    T = x(Machine_qt*Ship_qt+1:(Machine_qt+1)*Ship_qt);
    t = x((Machine_qt+1)*Ship_qt+1:(Machine_qt+2)*Ship_qt);
    for i = 1:Ship_qt
        for j = 1:Machine_qt
            m(j,i) = x(Ship_qt*(j-1)+i);
        end
    end
else
    T = [];
    t = [];
    m = [];
    f = inf;
end
    