load resourceUsage.mat
% jobID = 17109330, type = 3
    meanErrorRAM = zeros(19,1); 
    meanErrorCPU = zeros(19,1);
for endPoint = 2:20

    predicedPoints = 5;
    TaskNumber = 171;
    rows = resourceUsage.JobID == 17109330;
    ram = resourceUsage.CPU(rows);
    cpu = resourceUsage.RAM(rows);
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
    meanErrorRAM(endPoint-1) = mean(errorRAM)
    meanErrorCPU(endPoint-1) = mean(errorCPU);
end

figure(1)
plot(meanErrorRAM)
hold on
plot(meanErrorCPU)
legend('RAM','CPU')
xlabel('Number of training points used to build model.');
ylabel('MAPE %');
hold off