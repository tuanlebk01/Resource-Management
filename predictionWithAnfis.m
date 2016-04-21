%%%%%% Using ANFIS to predict workload %%%%%%%%%%%%%%%%%%%
load cpuMean
logOption = 0;
plotOption = 0;
originalX = cpuMean;
x = cpuMean;
if logOption == 1
    x=-log10(cpuMean);
end
bigSize = length(x);
n = 5000;
time=1:6000;
endTrnPoint = 4000;
errorCheck = [];
errorTest = [];
for timestep = 1:100 % prediction with 100 next values ahead.
    for t = 301:n
        Data(t,:) = [x(t-timestep*3) x(t-timestep*2) x(t-timestep) x(t) x(t+timestep)];
    end
    trnData = Data(1:4000,:);
    chkData = Data(4001:end,:);
    testData = x(n+1:bigSize);
    fismat = genfis1(trnData);
    [fismat1,error1,ss,fismat2,error2] = ...
          anfis(trnData,fismat,[],[0 0 0 0],chkData);
    anfis_output = evalfis([trnData(:,1:4); chkData(:,1:4)],fismat2);
    % figure(1)
    % plot(anfis_output)
    % hold on
    % plot(x(1:5000));
    % legend('actual values','predicted values');
    % xlabel('Time (5-minute interval)')
    % ylabel('CPU consumption');
    % title('Prediction using ANFIS model');
    % hold off
    ErrorOfTrain = mape(x(41:5040)',anfis_output);
    
    % ANFIS with test data, using multi-prediction with input data size is
    % 500.
    for t1 = 5001:5500
        testingData(t1-5000,:) = [x(t1) x(t1) x(t1) x(t1)];
    end
    index = 5001+timestep:5500+timestep; % time t + timestep
    anfis_output_test = evalfis(testingData(:,:),fismat2);
    if plotOption == 1
        figure(timestep)
        plot(x(index));
        hold on
        plot(anfis_output_test(1:499));
        hold off
        legend('actual values','predicted values');
        title('Test with test data');
    end
    errorOfTest = mape(anfis_output_test(1:499),x(index));
    errorCheck = [errorCheck ErrorOfTrain];
    errorTest = [errorTest errorOfTest];
    if logOption == 1
        predictedValues = 10.^-anfis_output_test;
        errorOfTest1 = mape(predictedValues(1:499),originalX(index))
        errorTestWithLog = [errorTest errorOfTest];
    end
end
figure(2)
plot(errorTest);
xlabel('Timestep')
ylabel('MAPE(%)')
title('Multi-prediction with ANFIS');
%%%%%%%%%%%%%%result%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cpu without logarithm: 86%
% cpu with logarithm: 96%
% ram without logarithm: 88%
% cpu with logarithm: 96%
