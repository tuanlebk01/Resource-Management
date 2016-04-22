%%%% Using NARX to predict workload %%%%%%%%%%%%%%%
load cpuMean
x = cpuMean(1:end);
y = cpuMean(1:end);
inputSeries = con2seq(x);
targetSeries = con2seq(y);
% Create a network.
inputDelays = 1:4;
feedbackDelays = 1:4;
hiddenLayerSize = 20;
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize);
% Prepare the data for training.
[inputs,inputStates,layerStates,targets] = ...
    preparets(net,inputSeries,{},targetSeries);
% Set up the division of data.
net.divideParam.trainRatio = 80/100;
net.divideParam.valRatio   = 10/100;
net.divideParam.testRatio  = 10/100;
% to train the network
[net,tr] = train(net,inputs,targets,inputStates,layerStates);
% Test the network.
outputs = net(inputs,inputStates,layerStates);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs)
% View the network diagram.
%view(net)
% Plot the performance training record to check for potential overfitting.
%figure, plotperform(tr)
% Close the loop on the NARX network, meaning we can use multiple
% predictions.
netc = closeloop(net);
netc.name = [net.name ' - Closed Loop'];
%view(netc)
[xc,xic,aic,tc] = preparets(netc,inputSeries,{},targetSeries);
yc = netc(xc,xic,aic);
mapeError = mape(cell2mat(tc),cell2mat(yc))
plot(cell2mat(yc))
hold on 
plot(cell2mat(tc))
perfc = perform(netc,tc,yc)
% Remove a delay from the network, to get the prediction one time step early.
nets = removedelay(net);
nets.name = [net.name ' - Predict One Step Ahead'];
%view(nets)
[xs,xis,ais,ts] = preparets(nets,inputSeries,{},targetSeries);
ys = nets(xs,xis,ais);
earlyPredictPerformance = perform(nets,ts,ys)
