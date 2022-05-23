function [ x_rem ] = Remove_PAB( x, y )
% Remove y of x, special caution with zero case
% x_rem - x without the elements of y

x_rem = x;

zero_y = find(y == 0); % ind of zeros in y
qt_y = length(zero_y); % quantity of zeros in y vector
zero_x = find(x == 0); % ind of zeros in x


zero_x = zero_x(randperm(length(zero_x)));  % select rendom positions of zeros to remove
x_rem(zero_x(1:qt_y)) = [];

y(zero_y) = [];

for i = 1:length(y)
    x_rem(find(x_rem == y(i))) = [];
end

end
