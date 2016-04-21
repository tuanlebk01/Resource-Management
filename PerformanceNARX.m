%%%%% experiments for testing performance of ANFIS model.
clear
load cpuMean
cpuMean = con2seq(cpuMean); % original data.
OverallMape = []; % 
Time = [];
Error = [];
Error1 = [];
Error2 = [];
for i = 1:19
tic
n = length(cpuMean);
inputPercent = i*5; % the size of input data for training, validation and testing.
index = 1:round(n*inputPercent/100);
T = cpuMean(index);
numberOfSamples = 1000;

%% Choose a Training Function
trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

%% Create a Nonlinear Autoregressive Network
feedbackDelays = 1:2;
hiddenLayerSize = 10;
net = narnet(feedbackDelays,hiddenLayerSize,'open',trainFcn);
net.trainParam.showWindow = false;
%% Prepare the Data for Training and Simulation
[x,xi,ai,t] = preparets(net,{},{},T); %NOTE: t is shilft left with T

%% Training with threshold.
[net,code] = trainingNetwork(T,net,6,100);
time = toc;
Time = [Time time];
if code == 0
    disp('Training failed');
end
%% Step-Ahead Prediction Network, randomly picking a value in x to predict.
% Taking 1000 samples to compute error.
nets = removedelay(net);
endPoint = round(n*inputPercent/100);
for i = 1:numberOfSamples
    startP = randi([endPoint n-500],1,1); % random points are in the range which exclude data input.
    inputSeries = cpuMean(startP-1:startP); % minimum is delay + 1
    [xs,xis,ais,ts] = preparets(nets,{},{},inputSeries);
    ys = nets(xs,xis,ais);
    actualV = cell2mat(cpuMean(startP+1));
    overallMape = mape(cell2mat(ys),actualV);
    OverallMape = [OverallMape overallMape];
end
error = mean(OverallMape);
Error = [Error error];
%% compute error when input data is a long series.
endP = round(n*inputPercent/100); % the end point of input data.
index1 = endP:endP+1000; % the size of testing data
inputSeries1 = cpuMean(index1);
[xs1,xis1,ais1,ts1] = preparets(nets,{},{},inputSeries1);
ys1 = nets(ts1,xis1,ais1);
actualV = cell2mat(cpuMean(endP+2:endP+1000)); % this needs two initial values (endP, endP +1) to predict.
error1 = mape(cell2mat(ys1(1:end-1)),actualV);
Error1 = [Error1 error];
%% compute error based on a random size of testing data except input data.
interval = 1000; % 1000 data points will be included.
% finding a random interval
endP1 = round(n*inputPercent/100);
randomPoint = randi([endP1 n-500],1,1); % excluding the last 500 data points.
if randomPoint + interval > n -500
    startPoint = randomPoint - interval;
    endPoint = randomPoint;
else
    startPoint = randomPoint;
    endPoint = randomPoint + interval;
end
index2 = startPoint:endPoint;
inputSeries2 = cpuMean(index2);
[xs2,xis2,ais2,ts2] = preparets(nets,{},{},inputSeries2);
ys2 = nets(ts2,xis2,ais2);
actualV = cell2mat(cpuMean(startPoint+2:endPoint)); % this needs two initial values (endP, endP +1) to predict endP +2.
error2 = mape(cell2mat(ys2(1:end-1)),actualV);
Error2 = [Error2 error];
%% plot for different input data sizes
end
%plot(OverallMape);
