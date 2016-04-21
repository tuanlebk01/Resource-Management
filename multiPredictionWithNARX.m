% Solve an Autoregression Time-Series Problem with a NAR Neural Network
% Script generated by Neural Time Series app
% Created 08-Apr-2016 10:00:05
%
% This script assumes this variable is defined:
%
%   cpuMean - feedback time series.
%% Load data
clear all
close all
load cpuMean
cpuMean = con2seq(cpuMean);
N = 300; % skip the last 300 data points.
T = cpuMean(1:end-N);
%% Choose a Training Function
trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

%% Create a Nonlinear Autoregressive Network
feedbackDelays = 1:2;
hiddenLayerSize = 15;
net = narnet(feedbackDelays,hiddenLayerSize,'open',trainFcn);
net.trainParam.showWindow = false;

%% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer
% states. Using PREPARETS allows you to keep your original time series data
% unchanged, while easily customizing it for networks with differing
% numbers of delays, with open loop or closed loop feedback modes.
[x,xi,ai,t] = preparets(net,{},{},T);

%% Setup Division of Data for Training, Validation, Testing
%[trainingSize,net] = trainingNetwork(T,net,6); MY FUNCTION
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

%% Train network
[x,xi,ai,t] = preparets(net,{},{},T);
[net,tr] = train(net,x,t,xi,ai);
%% prediction with one-step ahead
n = length(x);
repeatT = 10;
xMatrix = zeros(repeatT,100);
predictedYMatrix = zeros(repeatT,100);
for i = 1:repeatT
    %% Randomly change the size of input data
    randomP = randi([1 n-500],1,1);
    y = net(x(1:randomP),xi,ai);
    %% Multi-step prediction
    predictedY = y(end);
    for timeStep = 2:100
        tempx = y;
        y = net(tempx,xi,ai);
        temPredictedY = y(end);
        predictedY = [predictedY temPredictedY];
    end
    xMatrix(i,:) = cell2mat(predictedY);
    predictedYMatrix(i,:) = cell2mat(x(randomP+1:randomP+100));
end
%% compute MAPE for every timesteps.
ErrorMape = [];
for i = 1:100
    tempX = xMatrix(:,i)';
    tempY = predictedYMatrix(:,i)';
    errorMape = mape(tempX,tempY);
    ErrorMape = [ErrorMape errorMape];
end
%% plots    
figure(1)
plot(ErrorMape);
xlabel('Timestep');
ylabel('MAPE(%)');
title('Multi-step prediction with NARX');
