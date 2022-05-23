function[] = write_excel(filename, Ship_qt, Berth_qt, f_aloc, opt_time, Aloc, mooring_time, service_aloc, Machine_used)

xlR = 'H1'; sheet = 'Result';
xlswrite(filename,f_aloc,sheet,xlR);

xlR = 'E1'; sheet = 'Result';
xlswrite(filename,opt_time,sheet,xlR);

% Aloc_sol =[];
% for k = 1:Berth_qt
%     for i = 1:Ship_qt
%         if Aloc(i,k) ~= 0
%             Aloc_sol(i,k) = strcat('Ship ', num2str(Aloc(i,k)));
%         else 
%             break;
%         end
%     end
% end


for k = 1:Berth_qt
    if ~isempty(nonzeros(Aloc(:,k)))
        xlR = strcat('D', num2str((k-1)*6+3)); sheet = 'Result'; write = nonzeros(Aloc(:,k));
        xlswrite(filename,write',sheet,xlR);
        
        xlR = strcat('D', num2str((k-1)*6+4)); sheet = 'Result'; write = mooring_time(nonzeros(Aloc(:,k)));
        xlswrite(filename,write',sheet,xlR);
        
        xlR = strcat('D', num2str((k-1)*6+5)); sheet = 'Result'; write = service_aloc(nonzeros(Aloc(:,k)));
        xlswrite(filename,write',sheet,xlR);
        
        xlR = strcat('D', num2str((k-1)*6+6)); sheet = 'Result'; write = Machine_used(:,nonzeros(Aloc(:,k)));
        xlswrite(filename,write,sheet,xlR);
        
    end
end