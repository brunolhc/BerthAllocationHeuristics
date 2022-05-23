% Remove the berth patterns who will make a bad port combination

function[Pattern, Pattern_qt] = Uncombinable_Pattern(Pattern, Machine, Pattern_qt, M)
% Pattern - Set of all berth paterns
% Pattern_qt - Number of berth pattens 
% M - Number of machine types
% Machine is a structure, contains:
%       Machine(i).q - available of machine type i
%       Machine(i).v - tax of machine type i

remove = [];
Pattern_qt_new = Pattern_qt;

for i = 1:Pattern_qt 
   for j = 1:M
       % if the patter uses the maximum machines of any type remove it
       if Pattern(j,i) == Machine(j).q
           remove = [remove, i];
           Pattern_qt_new = Pattern_qt_new-1;
       end
   end
end

Pattern(:,remove) = [];
[~,Pattern_qt] = size(Pattern);