function[A,b] = CalcRendMin(Ship_qt,Machine_qt,tax,alpha,m)

A = zeros(Ship_qt*Machine_qt, Ship_qt*(Machine_qt+2));
b = zeros(Ship_qt*Machine_qt,1);

for i = 1:Ship_qt
    for k = 1:Machine_qt
        for j = 1:Machine_qt
            A(i*k, Ship_qt*(j-1)+i) = 1; %m(j,i)
        end
        b(i*k) = (1/alpha)*m(k,i)*tax(k);
    end
end