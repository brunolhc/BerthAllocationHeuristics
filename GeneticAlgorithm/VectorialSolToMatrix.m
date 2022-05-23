function[matrix_sol] = VectorialSolToMatrix(sol,Ship_qt,Berth_qt)

matrix_sol = zeros(Ship_qt,Berth_qt);
j = 1; k = 1;
for i = 1:length(sol)
    if sol(i)
        matrix_sol(j,k) = sol(i);
        j = j+1;
    else
        j = 1; k = k+1;
    end
end