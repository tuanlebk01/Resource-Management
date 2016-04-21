% jobID = 17109330, type = 3
endPoint = 10;
predicedPoints = 1;
TaskNumber = 24;
rows = resourceUsage.VarName3 == 3418339;
ram = resourceUsage.VarName6(rows);
cpu = resourceUsage.VarName7(rows);
job1 = table(ram(1:TaskNumber),cpu(1:TaskNumber));
job1.Properties.VariableNames{1}='RAM';
job1.Properties.VariableNames{2}='CPU';
time = 1:endPoint;
model1 = fitlm(time,job1.RAM(1:endPoint));
model2 = fitlm(time,job1.CPU(1:endPoint));
errorRAM = zeros(predicedPoints,1);
errorCPU = zeros(predicedPoints,1);
for i = 1:predicedPoints
    x = (endPoint+1:endPoint+i)';
    predictedRAM = predict(model1,x);
    predictedCPU = predict(model2,x);
    errorRAM(i) = mape(predictedRAM,job1.RAM(endPoint+1:endPoint+i));
    errorCPU(i) = mape(predictedCPU,job1.CPU(endPoint+1:endPoint+i));
end

figure(1)
plot(errorRAM)
hold on
plot(errorCPU)
legend('RAM','CPU')
xlabel('Number of future values are predicted.');
ylabel('MAPE %');
hold off