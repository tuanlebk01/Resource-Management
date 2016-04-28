function [net] = trainingNetwork(T,net,threshold,maxIteration)
%% Code = 1, training is successful otherwise its not successful.
trainingSize = 7; % 70% percent of data will used to train the method.yy
trainingData = T(1:0.9*end); % use 90% for training data
testData = T(0.9*end:end); % 10% for testing
counter = 1;
numNN = 10; % number of network
NN = cell(1,numNN);
perfs = zeros(1,numNN);
leftParts = (100-trainingSize*10)/2;
net.divideParam.trainRatio = trainingSize*10/100;
net.divideParam.valRatio = leftParts/100;
net.divideParam.testRatio = leftParts/100;
[xT,xiT,aiT,tT] = preparets(net,{},{},trainingData);
for i= 1:numNN
        % Train the Network
        NN{i} = train(net,xT,tT,xiT,aiT);
        % Test the Network
        net = NN{i};
        [x,xi,ai,t] = preparets(net,{},{},testData);
        y = net(t,xi,ai);
        perfs(i) = mse(net,t,y);
        counter = counter + 1;
end
minE = min(perfs);
minPosition = find(perfs==minE);
net = NN{minPosition(1)};





