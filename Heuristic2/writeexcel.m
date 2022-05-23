function[] = writeexcel(filename, sheet, Port_Pattern, Port_Pattern_Tax)

[m,n,p] = size(Port_Pattern);

Machines = cell(1,m);
Berths = cell(n,1);

for i = 1:m
    Machines(i) = cellstr(strcat('Machine_', num2str(i)));
end

for i = 1:n
    Berths(i) = cellstr(strcat('Berth_', num2str(i)));
end

k = 1;

for i = 1:p
    xlR = strcat(strcat('B', num2str(k)), ':', strcat('B', num2str(k)));
    Pattern_num = strcat('Pattern_', num2str(i));
    xlswrite(filename,cellstr(Pattern_num),sheet,xlR);
    
    xlR = strcat('B', num2str(k+1));
    xlswrite(filename,cellstr(Berths'),sheet,xlR);
    
    xlR = strcat('A', num2str(k+2));
    xlswrite(filename,cellstr(Machines'),sheet,xlR);
    
    xlR = strcat('A', num2str(k+m+2));
    xlswrite(filename,cellstr('Berth_rate'),sheet,xlR);
    
    xlR = strcat('B', num2str(k+2));
    xlswrite(filename,Port_Pattern(:,:,i),sheet,xlR);
    
    xlR = strcat('B', num2str(k+m+2));
    xlswrite(filename,Port_Pattern_Tax(:,i)',sheet,xlR);
    
    k = k+m+4;
end
    