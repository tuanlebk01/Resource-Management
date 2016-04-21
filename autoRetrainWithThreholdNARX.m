%%%%%   ANFIS model experiments for auto-retraining with threshold.
%% load data
clear
load cpuFiveMinuteInterval
originalData = con2seq(cpuMean); % original data.
%% Option
trainingOption = 1;
%% initial values
OverallMape = [];
Error = [];
Time = [];
ErrorT = []; % to compute threshold
G = 0; % 
alarm = 0;
CurrentPoints = []; % to store ponts at which Error reached to the threshold.
threshold = 6; % 5 percent.
errorCheckInterval = 3; % MUST BE HIGHER DELAY.
fixedErrorCheckInterval = 3; % errorCheckInterval = errorCheckInterval.
windowSize = 500;
increment = 1; % the size of step in computing error.
delay = 3;
layerSize = 10;

%% set what size of input used.
n = length(originalData);
inputPercent = 6.1; % the size of input data for training, validation and testing.
index = 1:round(n*inputPercent/100);
if windowSize > round(n*inputPercent/100)
    s = round(n*inputPercent/100);
    disp('window size is bigger than input data');
    disp(windowSize)
    disp(s)
    return
end
T = originalData(index);

%% Choose a Training Function
trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

%% Create a Nonlinear Autoregressive Network
feedbackDelays = 1:delay;
hiddenLayerSize = layerSize;
net = narnet(feedbackDelays,hiddenLayerSize,'open',trainFcn);
net.trainParam.showWindow = false;
%% Prepare the Data for Training and Simulation
[x,xi,ai,t] = preparets(net,{},{},T); %NOTE: t is shilft left with T

%% Training with threshold.
[net,code] = trainingNetwork(T,net,70,1);
if code == 0
    disp('Training failed');
end
%% runing without re-training.
currentPoint1 = round(n*inputPercent/100); % the end point of input data.
index = currentPoint1:n; % compute error with first errorCheckInterval data points.
inputSeries1 = originalData(index);
[xs,xis,ais,ts] = preparets(net,{},{},inputSeries1);
ys = net(ts,xis,ais); % ts is similar to actualV
actualV = cell2mat(originalData(currentPoint1+delay:n)); % this needs DELAY number of initial values (currentPoint, currentPoint +1) to predict.
error1 = mape(actualV,cell2mat(ys(1:end)));
fprintf('MAPE without re-training: %f\n',error1);
s = round(n*inputPercent/100);
fprintf('The training data size: %d\n',s);
%% compute threshold based on error standard variation.
tempN = length(ys);
for i = 1:tempN
    tempError = mape(actualV(i),cell2mat(ys(i)));
    ErrorT = [ErrorT tempError];
end
targetMean = mean(ErrorT(1:windowSize/2));
targetStd = std(ErrorT(1:windowSize/2));
threshold = targetMean + targetStd*0.5;
%% compute error with an initial interval and then increase this one by one until reaching the threshold.
currentPoint = round(n*inputPercent/100); % the end point of input data.
index = currentPoint:currentPoint+errorCheckInterval; % compute error with first errorCheckInterval data points.
inputSeries = originalData(index);
trainingCounter = 0;
if trainingOption == 1;
    while (1)
        [xs,xis,ais,ts] = preparets(net,{},{},inputSeries);
        ys = net(ts,xis,ais); % ts is similar to actualV
        actualV = cell2mat(originalData(currentPoint+delay:currentPoint+errorCheckInterval)); % this needs DELAY number of initial values (currentPoint, currentPoint +1) to predict.
        error = mape(actualV,cell2mat(ys(1:end)));
        disp(currentPoint+errorCheckInterval);
        Error = [Error error];
         if error > threshold
            g = error - threshold;
            G = G + g;
            if G > 500
                disp('Alarm turn on')
                alarm = 1;
                G = 0;
            end
         end  
        if alarm == 1
            % re-train with a sliding window.
            alarm = 0;
            disp('Training');
            CurrentPoints = [CurrentPoints currentPoint];
            currentPoint = currentPoint+errorCheckInterval; % update the current point.
            inputData = originalData(1:currentPoint); % NOTE: It may be large.
            tic
            [net,code] = smartTraining(net,inputData,windowSize,50);
            t = toc;
            Time = [Time t];
            if code == 0
                disp('Training failed');
            end
            trainingCounter = trainingCounter + 1;
            M{trainingCounter} = Error; % store Error in a cell.
            Error = []; % reset this array.
            errorCheckInterval = fixedErrorCheckInterval;
            if currentPoint+errorCheckInterval > n
                CurrentPoints = [CurrentPoints length(originalData)];
                M{trainingCounter} = Error;
                disp('reached to the end of the series in training phase')
                break
            end  
            index = currentPoint:currentPoint+errorCheckInterval;
            inputSeries = originalData(index); % update input data.
        else
            % increase errorCheckInterval.
            errorCheckInterval = errorCheckInterval + increment;
            if currentPoint+errorCheckInterval > n
                CurrentPoints = [CurrentPoints length(originalData)];
                Error = [Error error]; %NOTE HERE!
                M{trainingCounter} = Error;
                disp('reached to the end of the series increament phase')
                break
            end
            index = currentPoint:currentPoint+errorCheckInterval;
            inputSeries = originalData(index);
        end
        if trainingCounter > 10000 || currentPoint+errorCheckInterval > n
            CurrentPoints = [CurrentPoints length(originalData)];
            Error = [Error error]; %NOTE HERE!
            M{trainingCounter} = Error;
            disp('reached to the end of the series')
            break
        end
    end
end

    
%% compute mean of error durung a whole running.
OverallError = [];
for j = 1:length(CurrentPoints)-1
    ErrorInTraining = mean(M{j});
    OverallError = [OverallError ErrorInTraining];
end
overallMAPE = mean(OverallError);
fprintf('MAPE with re-training: %d\n',c);
fprintf('MAPE without re-training: %d\n',error1);

%% plot
figure(1)
stem(CurrentPoints)
xlabel('Number of training times')
ylabel('Number of data points')
title('The number of re-training for NARX model during the running')
figure(2)
plot(Time)
xlabel('Number of training times')
ylabel('Time (second)')
title('Time to re-train NARX model')

subplot(3,1,1);
plot(cell2mat(originalData));
xlabel('Time with 5-minute interval')
ylabel('CPU consumption');
title('CPU consumption in the Google trace');
subplot(3,1,2);
for j = 1:length(CurrentPoints)-1
    if size(M{j},2) == 1
         plot([CurrentPoints(j)+delay:CurrentPoints(j+1)],M{j},'+');
    else
         plot([CurrentPoints(j)+delay:CurrentPoints(j+1)],M{j});
    end
    hold on
end
xlabel('Time with 5-minute interval')
ylabel('MAPE (%)')
title('One-step Prediction using NARX')