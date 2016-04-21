function error = mse(demand,predictedValues)

n = length(demand);
error = zeros(n,1);

for i = 1:n
    error(i) = (demand(i)-predictedValues(i))^2;
end
error = sqrt(mean(error));