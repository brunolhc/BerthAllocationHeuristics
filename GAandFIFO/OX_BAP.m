function [ F1,F2 ] = OX_BAP( P1, P2, size )
%type OX crossover 
% exemple: | is the cut, here the cut is position 5 and 8
% Father1 - (2 1 5 4 | 7 8 9 3 | 6 10)
% Father2 - (1 5 4 6 | 10 2 8 7 | 3 9)
% Separate the Father1 interior cut for Child1 and Father2 interior cut for
% Child2
% Child1 - (X X X X | 7 8 9 3 | X X)
% Child2 - (X X X X | 10 2 8 7 | X X)
% Then aply the father2 elements in order ignoring the duplicated
% Same for Child2 and Father1
% Child1 - (1 5 4 6 | 7 8 9 3 | 10 2)
% Child2 - (9 1 5 4 | 10 2 8 7 | 6 3)
%
%In: P1, P2 - Father 1 and Father 2
%    m - lenght of entris
% Out - F1, F2 - Son 1 and Son 2


%P1 = [1 0 2 3 0 4]; P2 = [2 3 0 0 4 1];

%Cut points
% a = 4; b = 7;
a = randi(size); b = randi(size);
while b == a
    b = randi(size);
end
    
if a>b
    aux = b;
    b = a; a = aux;
end

%Complement for F1 and F2 
F1_comp = Remove_PAB(P2,P1(a:b));
F2_comp = Remove_PAB(P1,P2(a:b));


F1 = [F1_comp(1:a-1); P1(a:b) ; F1_comp(a:(size-(b-a+1)))];
F2 = [F2_comp(1:a-1); P2(a:b) ; F2_comp(a:(size-(b-a+1)))];
    
end