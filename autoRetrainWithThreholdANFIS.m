%%%%%% Using ANFIS to predict workload %%%%%%%%%%%%%%%%%%%
%% load data ramOneMinuteInterval ramHourMean
% clear
load cpuFiveMinuteInterval
s = length(cpuMean);
overallMape = [];
Sizes = [];
for percent = 5:80
%% Initial values.
retraining = 0; %% retraining option.
originalData = cpuMean;
inputPercent = percent; % percent unit.
n = length(originalData);
endPoint = round(n*inputPercent/100);
x = originalData(1:endPoint);
m = length(x);
CurrentPoints = []; % to store ponts at which Error reached to the threshold.
Error = [];
alarm = 0; % alarm
G = 0;
trainingCounter = 0;
drift = 700;
efficient = 0.3; % NOTE: this can be changed by varying the size of input when computing mean and ST target.
errorCheckInterval = 1; 
fixedErrorCheckInterval = 1; % errorCheckInterval = errorCheckInterval.
windowSize = 0;
increment = 1; % the size of step in computing error.
trnRatio = 0.7;
valRatio = 0.15;
maxStep = 1;
timestep = 1;
numMFs = [2 2 2 2];
numMFs1 = [3 3 3 3];
inmftype1 = 'gaussmf';
inmftype = 'gbellmf';
outmftype = 'linear';
%% compare size of input used with the window size.
if windowSize > endPoint
    s = round(n*inputPercent/100);
    disp('window size is bigger than input data');
    disp(windowSize)
    disp(s)
    return
end

%% Create training, validation data for the method.
for t = maxStep*3+1:m-maxStep
    Data(t,:) = [x(t-timestep*3) x(t-timestep*2) x(t-timestep) x(t) x(t+timestep)];
end
trnData = Data(1:round(m*trnRatio),:);
chkData = Data(round(m*trnRatio) : round(m*trnRatio) + round(valRatio*m),:);
fismat = genfis1(trnData,numMFs,inmftype,outmftype);
[fismat1,error1,ss,net,error2] = ...
          anfis(trnData,fismat,[],[0 0 0 0],chkData);
  %% runing without re-training.
currentPoint1 = round(n*81/100); % the end point of input data.
index = currentPoint1:n; % compute error with first errorCheckInterval data points.
for t1 = currentPoint1:n-1
        testingData(t1-currentPoint1+1,:) = [originalData(t1) originalData(t1) originalData(t1) originalData(t1)];
end
index = currentPoint1+1:n; % time t + timestep
predictedV = evalfis(testingData(:,:),net);
errorNoRetraining = mape(originalData(index),predictedV);
%% re-training option
if retraining == 1
    %% compute threshold based on error standard variation.
    ErrorT = [];
    tempN = length(predictedV);
    for i = 1:tempN
        tempError = mape(originalData(currentPoint1+i),predictedV(i));
        ErrorT = [ErrorT tempError];
    end
    targetMean = mean(ErrorT(1:windowSize));
    targetStd = std(ErrorT(1:windowSize));
    threshold = targetMean + targetStd*efficient;
    fprintf('Target Mean: %f\n',targetMean);
    fprintf('Target Standard Variation: %f\n',targetStd);
    fprintf('Threshold: %f\n',threshold);
    fprintf('Error Tolerance: %f\n',drift);

    %% fitst input series
    currentPoint = endPoint+errorCheckInterval; % time t.
    currentValue = originalData(currentPoint);
    inputSeries = [currentValue currentValue currentValue currentValue];
    %% Compute MAPE and do re-training when meeting the threshold.
    while(1)
        y = evalfis(inputSeries(:,:),net);
        acutalValues = originalData(currentPoint+errorCheckInterval+1:currentPoint+errorCheckInterval+1);
        error = mape(acutalValues,y);
        %disp(error);
        Error = [Error error];
        if error > threshold
            g = error - threshold;
            G = G + g;
            if G > drift
                disp('Alarm turn on')
                alarm = 1;
                G = 0;
            end
        end  
        if alarm == 1
            disp(error);
            disp('training');
            CurrentPoints = [CurrentPoints currentPoint];
            currentPoint = currentPoint+errorCheckInterval; % update the current point.
            inputData = originalData(1:currentPoint); % NOTE: It may be large.
            [net] = smartTrainingANFIS(net,inputData,windowSize,50);
            trainingCounter = trainingCounter + 1;
            errorCheckInterval = fixedErrorCheckInterval; % reset
            if currentPoint+errorCheckInterval +1 > n
                CurrentPoints = [CurrentPoints length(originalData)];
                disp('reached to the end of the series in training phase')
                break
            end  
            % create input data
            t1 = currentPoint+errorCheckInterval;
            inputSeries = [originalData(t1) originalData(t1) ...
                    originalData(t1) originalData(t1)];
        else
            % increase errorCheckInterval.
            disp('increase errorCheckInterval.');
            disp(currentPoint+errorCheckInterval);
            errorCheckInterval = errorCheckInterval + increment;
            if currentPoint+errorCheckInterval + 1 > n
                CurrentPoints = [CurrentPoints length(originalData)];
                disp('reached to the end of the series increament phase')
                break
            end
            t1 = currentPoint+errorCheckInterval;
            inputSeries = [originalData(t1) originalData(t1) ...
                    originalData(t1) originalData(t1)];
        end
        if trainingCounter > 10000 || currentPoint+errorCheckInterval + 1 > n
            CurrentPoints = [CurrentPoints length(originalData)];
            disp('reached to the end of the series')
            break
        end
        alarm = 0; % reset alarm.
    end
    %% compute mean of error durung a whole running.

    overallMAPE = mean(Error);
    fprintf('MAPE with re-training: %d\n',overallMAPE);
end %% end re-trainging option.
fprintf('The length of training input: %d\n',endPoint);
fprintf('ANFIS: MAPE without re-training: %d\n',errorNoRetraining);
size = endPoint;
Sizes = [Sizes size];
overallMape = [overallMape errorNoRetraining];


end
figure(1)
plot(Sizes,overallMape);
xlabel('Size of training data')
ylabel('MAPE(%)')
%% plot
% figure(1)
% stem(CurrentPoints)
% xlabel('Number of training times')
% ylabel('Number of data points')
% title('The number of re-training for ANFIS model during the running')
% figure(2)
% plot(Time)
% xlabel('Number of training times')
% ylabel('Time (second)')
% title('Time to re-train ANFIS model')
% 
% subplot(2,1,1);
% plot(originalData);
% xlabel('Time with 5-minute interval')
% ylabel('CPU consumption');
% title('CPU consumption in the Google trace');
% subplot(2,1,2);
% for j = 1:length(CurrentPoints)-1
%     if size(M{j},2) == 1
%          plot([CurrentPoints(j)+1:CurrentPoints(j+1)],M{j},'+');
%     else
%          plot([CurrentPoints(j)+1:CurrentPoints(j+1)],M{j});
%     end
%     hold on
% end
% xlabel('Time with 5-minute interval')
% ylabel('MAPE (%)')
% title('One-step Prediction using ANFIS')
    



