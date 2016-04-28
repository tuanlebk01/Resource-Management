function [net] = smartTraining(net,input,windowSize,errorTolerance)
% option 1: a sliding window will be used. Option 2: the size of training data will be increase.
trainingInput = input(end-windowSize:end);
[net] = trainingNetwork(trainingInput,net,errorTolerance,1);
end
    