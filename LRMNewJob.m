load ramHourMean.mat
% endPoint = 101;
% predicedPoints = 1;
% Ram = resourceUsage.RAM(1:endPoint,:);
n = length(ramMean);
x = ramMean;
startPoint = round(n*0.4);
endPoint = round(n*1)-1;
%% one-step prediction
% time = 1:n;
% Error = [];
% for i = startPoint:endPoint
%     time = 1:i;
%     model1 = fitlm(time,x(1:i));
%     predicted = predict(model1,i+1);
%     actual = x(i+1);
%     error = mape(predicted,actual);
%     Error = [Error error];
% end
% overallError = mean(Error)

% overallError = 22.6614
%% multi-step prediction
% 
time = 1:startPoint;
Error1 = [];
predictedV = [];
tic
model1 = fitlm(time,x(1:startPoint));
toc
for i = startPoint+1:endPoint
    predicted = predict(model1,i);
    predictedV = [predictedV predicted];
    actual = x(i);
    error = mape(predicted,actual);
    Error1 = [Error1 error];
end
overallError = mean(Error1)
actualV = x(startPoint+1:end);


