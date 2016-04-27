%%%%%% Using ANFIS to predict workload %%%%%%%%%%%%%%%%%%%
%% load data and initial data
clear all
load cpuOneMinuteInterval.mat
x = cpuMean;  % input data which is removed the last 500 data points.;
n = length(x);
interval = 100; % the length of testing data.
errorCheck = [];
errorTest = [];
trnRatio = 0.6;
valRatio = 0.2;
maxStep = 1;
overallError = [];
M = cell(100,1); % to store MAPE array for each training
numMFs = [2 2 2 2];
inmftype = 'gbellmf';
outmftype = 'linear';
%% multi-step prediction with 100 timesteps ahead.
for timestep = 1:maxStep
    %% Create training, validation data for the method.
    for t = maxStep*3+1:n-maxStep
        Data(t,:) = [x(t-timestep*3) x(t-timestep*2) x(t-timestep) x(t) x(t+timestep)];
    end
    trnData = Data(1:n*trnRatio,:);
    chkData = Data(n*trnRatio : n*trnRatio + valRatio*n,:);
    fismat = genfis1(trnData,numMFs,inmftype,outmftype);
    [fismat1,error1,ss,fismat2,error2] = ...
          anfis(trnData,fismat,[],[0 0 0 0],chkData);
     %% repeat 100 times for every timesteps
    for i = 1:10
        %% Create testing data with random starting point.
        [startP, endP] = randomStartingPoint(x(1:end-1),interval);
        for t1 = startP:endP
            testingData(t1-startP+1,:) = [x(t1) x(t1) x(t1) x(t1)];
        end
        index = startP+1:endP+1; % time t + timestep
        anfis_output_test = evalfis(testingData(:,:),fismat2);
        errorOfTest = mape(anfis_output_test(1:interval+1),x(index));
        errorTest = [errorTest errorOfTest];
        meanError = mean(errorTest);
    end
    overallError = [overallError meanError];
end
%% plot error.
figure(1)
plot(overallError);
xlabel('Timestep')
ylabel('MAPE(%)')
title('Multi-prediction with ANFIS');

