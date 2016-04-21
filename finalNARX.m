% Solve an Autoregression Time-Series Problem with a NAR Neural Network
% Script generated by Neural Time Series app
% Created 08-Apr-2016 10:00:05
%
% This script assumes this variable is defined:
%
%   cpuMean - feedback time series.
clear all
close all
load cpuMean
cpuMean = con2seq(cpuMean);
T = cpuMean;
randomOption =1;
% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

% Create a Nonlinear Autoregressive Network
feedbackDelays = 1:6;
hiddenLayerSize = 15;
net = narnet(feedbackDelays,hiddenLayerSize,'open',trainFcn);

% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer
% states. Using PREPARETS allows you to keep your original time series data
% unchanged, while easily customizing it for networks with differing
% numbers of delays, with open loop or closed loop feedback modes.
[x,xi,ai,t] = preparets(net,{},{},T);

% Setup Division of Data for Training, Validation, Testing
[trainingSize,net] = trainingNetwork(T,net,6);


% Closed Loop Network
% Use this network to do multi-step prediction.
% The function CLOSELOOP replaces the feedback input with a direct
% connection from the outout layer.
netc = closeloop(net);
netc.name = [net.name ' - Closed Loop'];
errorM = []; % error when using multi-prediction
OverallE = [];

for interval = 2:100
    for j = 1:50 %% taking 100 times to see error
        % view(netc)
        [xc,xic,aic,tc] = preparets(netc,{},{},T);
        [startP,endP] = randomStartingPoint(T,interval);
        index = startP:endP;
        if randomOption == 1
            sqData = rand(1,interval+1);
            sqData = con2seq(sqData);
        end
        if randomOption == 1
            x2 = sqData; % minimum size is 3
        else
            x2 = T(index);
        end
        actualV = T(startP+interval+1:startP+interval*2+1); % need to be compared with prediced values
        yc = netc(x2,xic,aic);
        %closedLoopPerformance = perform(net,tc,yc);
%         if interval == 30
%             figure(1)
%             plot(cell2mat(actualV))
%             hold on; plot(cell2mat(yc))
%             legend('Actual values','Predicted values');
%         end
        errorm = mape(cell2mat(yc(1:end-1)),cell2mat(actualV));
        errorM = [errorM errorm];
    end
    overallE = mean(errorM);
    OverallE = [OverallE overallE];
end
    
    
figure(2)
plot(OverallE)
ylabel('MAPE')
xlabel('Timestep');
title('Prediction using NARX with close network');

break;
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
[xs,xis,ais,ts] = preparets(nets,{},{},T);
ys = nets(xs,xis,ais);
stepAheadPerformance = perform(nets,ts,ys)
figure(1)
plot(cell2mat(ts))
hold on; plot(cell2mat(ys))
legend('Actual values','Predicted values');
title('Prediction using NARX with open network');
errorS = mape(cell2mat(ys(1:end-1)),cell2mat(ts(1:end-1)))