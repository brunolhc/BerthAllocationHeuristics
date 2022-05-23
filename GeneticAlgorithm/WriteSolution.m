function[] = WriteSolution(excel_name, x, m, T, t, N, M, B)
%   White a solution of BAP optimization on a excel file
% excel_name(string) - name of the excel
% x(N+B-1) - ship alocation 
% m(M,N+B-1) - machine alocation
% T(N+B-1) - mooring time
% t(N+B-1) - service time
% N - Number of ships
% M - number of machine types
% B - number of berths


%%%%%%%%%%%%%%%%%%%%%%%% Initial Configs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% adds a zero on the end of the vector (just to facilitate) 
x_aux = [x;0];

%find the positions of berths
Berths_pos = find(x_aux == 0);
Berths_pos = [0;Berths_pos];

file = strcat('Tests/', excel_name);
sheet_name = 'Result_AG';



% We need a range for every parameter for every berth
% ini = 2;
% for i = 1:(B*(3+M))
%     xlRange(i) = strcat('D', i+ini, ':AAA', i+ini);
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k = 1;
ini = 2;
for i = 1:B % *(3+M))
    xlswrite(file,x(Berths_pos(i)+1:Berths_pos(i+1)-1)',sheet_name,strcat('D', num2str(k+1+ini)));
    xlswrite(file,T(Berths_pos(i)+1:Berths_pos(i+1)-1)',sheet_name,strcat('D', num2str(k+2+ini)));
    xlswrite(file,t(Berths_pos(i)+1:Berths_pos(i+1)-1)',sheet_name,strcat('D', num2str(k+3+ini)));
    for j = 1:M
        xlswrite(file,m(j,Berths_pos(i)+1:Berths_pos(i+1)-1),sheet_name,...
            strcat('D', num2str(k+3+ini+j)));
    end
    k = k+3+M;
end

%xlswrite(filename,A,sheet,xlRange)