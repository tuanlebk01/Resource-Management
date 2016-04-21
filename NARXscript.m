clear all
load cpuMean
x = cpuMean(1:end-2);
y = cpuMean(2:end-1);
inputSeries = con2seq(x);
targetSeries = con2seq(y);
% Solve an Autoregression Problem with External Input with a NARX Neural Network
% Script generated by Neural Time Series app
% Created 06-Apr-2016 16:50:20
%
% This script assumes these variables are defined:
%
%   inputSeries - input time series.
%   targetSeries - feedback time series.

X = inputSeries;
T = targetSeries;

% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

% Create a Nonlinear Autoregressive Network with External Input
inputDelays = 1:2;
feedbackDelays = 1:2;
hiddenLayerSize = 15;
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize,'open',trainFcn);

% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer
% states. Using PREPARETS allows you to keep your original time series data
% unchanged, while easily customizing it for networks with differing
% numbers of delays, with open loop or closed loop feedback modes.
[x,xi,ai,t] = preparets(net,X,{},T);

% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 80/100;
net.divideParam.valRatio = 10/100;
net.divideParam.testRatio = 10/100;

% Train the Network
[net,tr] = train(net,x,t,xi,ai);

% Test the Network
y = net(x,xi,ai);
e = gsubtract(t,y);
performance = perform(net,t,y)

% View the Network
%view(net)

% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotregression(t,y)
%figure, plotresponse(t,y)
%figure, ploterrcorr(e)
%figure, plotinerrcorr(x,e)

% Closed Loop Network
% Use this network to do multi-step prediction.
% The function CLOSELOOP replaces the feedback input with a direct
% connection from the outout layer.
netc = closeloop(net);
netc.name = [net.name ' - Closed Loop'];
%view(netc)
% multi prediction: time step is 100; t = 3000; input(3000:3100);
%output(3100:3200)
index = 3000:3050;
index1 = 3001:3051;
input = X(index);
target = T(index1);
x2 = num2cell(rand(1,51));
[xc,xic,aic,tc] = preparets(netc,input,{},target);
yc = netc(x2,xic,aic);
%closedLoopPerformance = perform(net,tc,yc)
figure(1)
plot(cell2mat(X(3051:3101)));
hold on
plot(cell2mat(yc))
legend('actual values','predicted values')
title('Multi-prediction')
errorMultiP = mape(cell2mat(X(3051:3101)),cell2mat(yc))
%errorMultiP1 = mape(X(3100:3200),cell2mat(yc)
% Step-Ahead Prediction Network
% For some applications it helps to get the prediction a timestep early.
% The original network returns predicted y(t+1) at the same time it is
% given y(t+1). For some applications such as decision making, it would
% help to have predicted y(t+1) once y(t) is available, but before the
% actual y(t+1) occurs. The network can be made to return its output a
% timestep early by removing one delay so that its minimal tap delay is now
% 0 instead of 1. The new network returns the same outputs as the original
% network, but outputs are shifted left one timestep.
nets = removedelay(net);
nets.name = [net.name ' - Predict One Step Ahead'];
% view(nets)
[xs,xis,ais,ts] = preparets(nets,X,{},T);
ys = nets(xs,xis,ais);
stepAheadPerformance = perform(nets,ts,ys)
figure(2)
plot(cell2mat(t))
hold on
plot(cell2mat(y))
legend('actual values','predicted values')
title('single prediction')
errorSingleP = mape(cell2mat(t),cell2mat(y))
