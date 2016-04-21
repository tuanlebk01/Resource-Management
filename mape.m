function [percent] = mape(demand,predictedValue)
% NOTE: should pass parameters in ORDER to avoid NOT A NUMBER.

n = length(demand);
error = zeros(n,1);

for i = 1:n
    error(i) = abs(demand(i) - predictedValue(i))/demand(i)*100;
end

percent = mean(error);
    