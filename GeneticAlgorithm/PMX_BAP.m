function [ F1,F2 ] = PMX_BAP( P1, P2, size )
%type PMX-partially mapped crossover
% exemple: | is the cut, here the cut is position 5 and 8
% Father1 - (2 1 5 4 | 7 8 9 3 | 6 10)
% Father2 - (1 5 4 6 | 10 2 8 7 | 3 9)
% Make Father1 interior cut equal Father2, and viceversa
% Father1 - (2 1 5 4 | 3 9 8 7 | 6 10)
% Father2 - (1 5 4 6 | 7 8 2 10 | 3 9)
% Then aply swap on diferent positions (to make equal the other cut)
% Same for Child2 and Father1
% Child1 - (9 1 5 4 | 10 2 8 7 | 6 3)
% Child2 - (1 5 4 6 | 7 8 9 3 | 10 2)

%P1 = [1 0 2 3 0 4]; P2 = [2 3 0 0 4 1];

F1 = P1; F2 = P2;

%position to change;
a = randi(size); b = randi(size);
while b == a
    b = randi(size);
end
    
if a>b
    aux = b;
    b = a; a = aux;
end

%find zero positions
F1_zero = find(P1==0);
F2_zero = find(P2==0);

for i = a:b
    if P2(i) == 0
        if F1(i) == 0
            break;
        end
        index = randi(length(F1_zero));
        F1(F1_zero(index)) = F1(i);
        F1(i) = P2(i);
        F1_zero(index) = [];
    else
        index = find(F1 == P2(i));
        F1(index) = F1(i);
        F1(i) = P2(i);
        if F1(index) == 0;
            F1_zero = union(F1_zero, index);
        end
    end
    F1_zero = setdiff(F1_zero,i);
end

for i = a:b
    if P1(i) == 0
        if F2(i) == 0
            break;
        end
        index = randi(length(F2_zero));
        F2(F2_zero(index)) = F2(i);
        F2(i) = P1(i);
        F2_zero(index) = [];
    else
        index = find(F2 == P1(i));
        F2(index) = F2(i);
        F2(i) = P1(i);
        if F2(index) == 0;
            F2_zero = union(F2_zero, index);
        end
        F2_zero = setdiff(F2_zero,i);
    end
    
end
        
    
end