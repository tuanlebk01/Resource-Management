clear
load cpuHourMean
% endPoint = 101;
% predicedPoints = 1;
% Ram = resourceUsage.RAM(1:endPoint,:);
input = cpuMean;
n = length(input);
x = input;
overallMape = [];
for i = 1:10
point = round(n*0.1);
startPoint = randi([point n-100],1,1)
endPoint = round(n*1)-1;
%% one-step prediction
% time = 1:n;
% Error = [];
% for i = startPoint:endPoint
%     time = 1:i;
%     model1 = fitlm(time,x(1:i));
%     predicted = predict(model1,i+1);
%     actual = x(i+1);
%     error = mape(actual,predicted);
%     Error = [Error error];
% end
% overallError = mean(Error)

% overallError = 22.6614
%% multi-step prediction
% 
time = 1:point;
Error1 = [];
predictedV = [];
tic
model1 = fitlm(time,x(1:point));
toc
for i = startPoint+1:startPoint + 101
    predicted = predict(model1,i);
    predictedV = [predictedV predicted];
    actual = x(i);
    error = mape(actual,predicted);
    Error1 = [Error1 error];
end
overallError = mean(Error1)
actualV = x(startPoint+1:end);
overallMape = [overallMape overallError];
end

error = mean(overallMape)
