function [y] = movingAverage(x,window_size)

n = length(x);
y = zeros(n + 1,1);
for i=window_size+1:n+1
    y(i) = mean(x(i-window_size:i-1));
end


