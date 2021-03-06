%%%%%% Using ANFIS to predict workload %%%%%%%%%%%%%%%%%%%
%% load data and initial data
clear
load cpuTwoMinuteInterval
x = cpuMean;  % input data which is removed the last 500 data points.;
overallMape = [];
for i = 1:10
    index = 1;
n = length(x);
errorCheck = [];
errorTest = [];
trnRatio = 0.7;
valRatio = 0.15;
maxStep = 10;
overallError = [];
numMFs = [2 2 2 2];
inmftype = 'gaussmf';
outmftype = 'linear';
point = round(n*0.2); % 60% left for buiding a model
startP = randi([point n-maxStep],1,1)
%% multi-step prediction with 100 timesteps ahead.
for timestep = 1:maxStep
    %% Create training, validation data for the method.
    disp('new index')
    for t = timestep*3+1:point-timestep
        Data(index,:) = [x(t-timestep*3) x(t-timestep*2) x(t-timestep) x(t) x(t+timestep)];
        index = index +1;
    end
    n = index;
    trnData = Data(1:round(n*trnRatio),:);
    chkData = Data(round(n*trnRatio) : round(n*trnRatio) + round(valRatio*n),:);
    fismat = genfis1(trnData,numMFs,inmftype,outmftype);
    [fismat1,error1,ss,fismat2,error2] = ...
          anfis(trnData,fismat,[],[0 0 0 0],chkData);
 
    testingData = [x(startP+1) x(startP+1) x(startP+1) x(startP+1)];
    predictedV = evalfis(testingData,fismat2);
    error = mape(x(startP+timestep+1),predictedV);
    errorTest = [errorTest error];
    
end
meanError = mean(errorTest);

overallMape = [overallMape meanError];
end
fprintf('MAPE: %f\n',mean(overallMape));
%% plot error.
% figure(1)
% plot(overallMape);
% xlabel('Timestep')
% ylabel('MAPE(%)')

