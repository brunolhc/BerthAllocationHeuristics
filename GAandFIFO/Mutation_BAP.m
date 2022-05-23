function [ x ] = Mutation_BAP( x, size )
%Changes 2 positions of vector x

a = randi(size); b = randi(size);
while b == a
    b = randi(size);
end

aux = x(b);
x(b) = x(a);
x(a) = aux;
    
end