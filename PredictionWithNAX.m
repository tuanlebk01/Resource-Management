%%%%%% experiments for ANFIS with differents input data size and training
%%%%%% data.
clear
close all
load cpuMean
cpuMean = con2seq(cpuMean);
inputOption = 1; % for changing input data size.
OverallMape = []; % using when inputOption == 1
sizeOfStep = 100;
NumberOfSteps = 20;
for step = 1:NumberOfSteps %% changing input size
    index = 1:step*sizeOfStep;
    T = cpuMean(index);
    if inputOption == 0
        T = cpuMean;
    end
    %% Choose a Training Function
    trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

    %% Create a Nonlinear Autoregressive Network
    feedbackDelays = 1:6;
    hiddenLayerSize = 15;
    net = narnet(feedbackDelays,hiddenLayerSize,'open',trainFcn);

    %% Prepare the Data for Training and Simulation

    [x,xi,ai,t] = preparets(net,{},{},T); %NOTE: t is shilft left with T

    %% Setup Division of Data for Training, Validation, Testing
    PerformanceMape = [];
    for trainingSize = 6:6 % from 10% to 90%
        leftParts = (100-trainingSize*10)/2;
        net.divideParam.trainRatio = trainingSize*10/100;
        net.divideParam.valRatio = leftParts/100;
        net.divideParam.testRatio = leftParts/100;
        %% Train the Network
        [net,tr] = train(net,x,t,xi,ai);
        %% Test the Network
        y = net(x,xi,ai);
        e = gsubtract(t,y);
        performanceMape = mape(cell2mat(t),cell2mat(y));
        PerformanceMape = [PerformanceMape performanceMape];
    end
    if inputOption == 0
        figure(3)
        plot([1:9]*10,PerformanceMape)
        xlabel('The ratio between training data and input data (%)');
        ylabel('MAPE')
        title('A comparison of error when changing the size of traning data')
    end
    
    %% Step-Ahead Prediction Network
    nets = removedelay(net);
    nets.name = [net.name ' - Predict One Step Ahead'];
    [xs,xis,ais,ts] = preparets(nets,{},{},T);
    ys = nets(xs,xis,ais);
    stepAheadPerformance = perform(nets,ts,ys);
    if inputOption == 0
        figure(1)
        plot(cell2mat(ts))
        hold on; plot(cell2mat(ys))
        legend('Actual values','Predicted values');
        title('Prediction using NARX with open network');
        xlabel('Time with 5-minute interval')
        ylabel('CPU consumption')
        errorS = mape(cell2mat(ys(1:end-1)),cell2mat(ts(1:end-1)))
    end
    overallMape = mape(cell2mat(ys(1:end-1)),cell2mat(ts(1:end-1)));
    OverallMape = [OverallMape overallMape];
    
end
%% plot for different input data sizes
if inputOption == 1
    plot([1:NumberOfSteps]*sizeOfStep,OverallMape);
    ylabel('MAPE (%)');
    xlabel('The length of input data');
    title('A comparison of error with different input data sizes');
end