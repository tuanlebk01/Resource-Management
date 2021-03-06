%%%%%   NARX model experiments for auto-retraining with threshold.
%% load data
clear
load ramFiveMinuteInterval
Size = [];
overallMape = [];
originalData1 = con2seq(ramMean); % original data.
z = length(originalData1);
%% initial values
for percent = 5:80

    originalData = originalData1(1:round(z*percent/100));
inputPercent = 40; % the size of input data for training, validation and testing.
retrainingOption = 0;
OverallMape = [];
Error = [];
Time = [];
ErrorT = []; % to compute threshold
G = 0; %
errorTolerance = 500;
efficient = 0.2; % threshold = targetMean + targetStd*efficient
alarm = 0;
CurrentPoints = []; % to store ponts at which Error reached to the threshold.
errorCheckInterval = 3; % MUST BE HIGHER DELAY.
fixedErrorCheckInterval = 3; % errorCheckInterval = errorCheckInterval.
windowSize = 0;
increment = 1; % the size of step in computing error.
delay = 2;
layerSize = 7;
trainingCounter = 0;

%% set what size of input used.
n = length(originalData);
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
%net.divideFcn = 'divideblock'; % divede the data into three sequence blocks.
%% Prepare the Data for Training and Simulation
[x,xi,ai,t] = preparets(net,{},{},T); %NOTE: t is shilft left with T

%% Training with threshold.
[net] = trainingNetwork(T,net,70,1);
%% runing without re-training.
currentPoint1 = round(n*81/100); % the end point of input data.
index = currentPoint1:n; % compute error with first errorCheckInterval data points.
inputSeries1 = originalData(index);
[xs,xis,ais,ts] = preparets(net,{},{},inputSeries1);
ys = net(ts,xis,ais); % ts is similar to actualV
actualV = cell2mat(originalData(currentPoint1+delay:n)); % this needs DELAY number of initial values (currentPoint, currentPoint +1) to predict.
error1 = mape(actualV,cell2mat(ys(1:end)));
s = round(n*inputPercent/100);
fprintf('The training data size: %d\n',s);
%% retraining option
if retrainingOption == 1
    %% compute threshold based on error standard variation.
    tempN = length(ys);
    for i = 1:tempN
        tempError = mape(actualV(i),cell2mat(ys(i)));
        ErrorT = [ErrorT tempError];
    end
    targetMean = mean(ErrorT(1:windowSize));
    targetStd = std(ErrorT(1:windowSize));
    threshold = targetMean + targetStd*efficient;
    fprintf('Target Mean: %f\n',targetMean);
    fprintf('Target Standard Variation: %f\n',targetStd);
    fprintf('Threshold: %f\n',threshold);
    fprintf('Error Tolerance: %f\n',errorTolerance);

    %% compute error with an initial interval and then increase this one by one until reaching the threshold.
    currentPoint = round(n*inputPercent/100); % the end point of input data.
    index = currentPoint-delay:currentPoint; % compute error with first errorCheckInterval data points.
    inputSeries = originalData(index);
    while (1)
        [xT,xiT,aiT,tT] = preparets(net,{},{},inputSeries);
        ys = net(tT,xiT,aiT); % ts is similar to actualV
        actualV = cell2mat(tT(end)); % this needs DELAY number of initial values (currentPoint, currentPoint +1) to predict.
        error = mape(actualV,cell2mat(ys(1:end)));
        disp(currentPoint+errorCheckInterval);
        Error = [Error error];
        % cusum, sum G up when error exceeds threshold.
         if error > threshold
            g = error - threshold;
            G = G + g;
            if G > errorTolerance
                disp('Alarm turn on')
                alarm = 1;
                G = 0;
            end
         end  
        if alarm == 1
            % re-train with a sliding window.
            disp('Training');
            CurrentPoints = [CurrentPoints currentPoint];
            currentPoint = currentPoint+errorCheckInterval; % update the current point.
            inputData = originalData(1:currentPoint); % NOTE: It may be large.
            tic
            [net] = smartTraining(net,inputData,windowSize,50);
            t = toc;
            Time = [Time t];
            trainingCounter = trainingCounter + 1;
            errorCheckInterval = fixedErrorCheckInterval;
            if currentPoint+errorCheckInterval > n
                CurrentPoints = [CurrentPoints length(originalData)];
                Error = [Error error];
                disp('reached to the end of the series in training phase')
                break
            end  
            index = currentPoint+errorCheckInterval-delay:currentPoint+errorCheckInterval;
            inputSeries = originalData(index); % update input data.
        else
            % increase errorCheckInterval.
            errorCheckInterval = errorCheckInterval + increment;
            if currentPoint+errorCheckInterval > n
                CurrentPoints = [CurrentPoints length(originalData)];
                Error = [Error error];
                disp('reached to the end of the series increament phase')
                break
            end
            index = currentPoint+errorCheckInterval-delay:currentPoint+errorCheckInterval;
            inputSeries = originalData(index);
        end
        if trainingCounter > 10000 || currentPoint+errorCheckInterval > n
            CurrentPoints = [CurrentPoints length(originalData)];
            Error = [Error error];
            disp('reached to the end of the series')
            break
        end
        alarm = 0; % reset alarm.
    end


    %% compute mean of error durung a whole running.

    overallMAPE = mean(Error);
    fprintf('MAPE with re-training: %d\n',overallMAPE);
end
fprintf('The length of training input: %d\n',round(n*inputPercent/100));
fprintf('NAR: MAPE without re-training: %d\n',error1);
size = round(n*inputPercent/100);
Size = [Size size];
overallMape = [overallMape error1];
end
%% plot
figure(1)
plot(Size,overallMape);
xlabel('Size of input data')
ylabel('MAPE(%)')
% figure(1)
% stem(CurrentPoints)
% xlabel('Number of training times')
% ylabel('Number of data points')
% title('The number of re-training for NARX model during the running')
% figure(2)
% plot(Time)
% xlabel('Number of training times')
% ylabel('Time (second)')
% title('Time to re-train NARX model')
% 
% subplot(3,1,1);
% plot(cell2mat(originalData));
% xlabel('Time with 5-minute interval')
% ylabel('CPU consumption');
% title('CPU consumption in the Google trace');
% subplot(3,1,2);
% ePoint = n;
% sPoint = n - length(Error);
% plot([sPoint-1:ePoint],Error);
% xlabel('Time with 5-minute interval')
% ylabel('MAPE (%)')
% title('One-step Prediction using NARX')