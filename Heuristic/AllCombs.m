% Create all berths patterns

function[i, index, aux, ini_p, max_p, max, P] = AllCombs(i, index, aux, ini_p, max_p, max, P)
% P is a matrix of all combinations
% i - Initial level/node of the tree (needs to be one on the first call)
% index - Actual index of matrix P (needs to be one on the first call) 
% aux - Actual combination of the positions (needs to be zeros/ones on the first call)
% ini_p - Initial velue for each level
% max_p - Maximum value of each node
% max - Number of levels


if i > max
    index = index+1;
    P(:,index) = aux;
    return
    
else
    % For all nivel nodes
    for k = ini_p(i):max_p(i)
        aux(i) = k;
        [~, index, ~, ini_p, max_p, max, P] = AllCombs(i+1, index, aux, ini_p, max_p, max, P);
        
    end
end

