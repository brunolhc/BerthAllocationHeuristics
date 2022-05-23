function[ind] = Busca(x,a,m)
% find the element a in x vector 

ind = 0;

for i = 1:m
    if x(i) == a
        ind = i;
    end
end

end