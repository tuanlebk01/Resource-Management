function [net,code] = trainingNetwork(T,net,threshold,maxIteration)
%% Code = 1, training is successful otherwise its not successful.
trainingSize = 7; % 70% percent of data will used to train the method.
[x,xi,ai,t] = preparets(net,{},{},T);
counter = 1;
while (1)
    % lets fix 70% for training and 15% for validation and testing.
        leftParts = (100-trainingSize*10)/2;
        net.divideParam.trainRatio = trainingSize*10/100;
        net.divideParam.valRatio = leftParts/100;
        net.divideParam.testRatio = leftParts/100;
        % Train the Network
        [net] = train(net,x,t,xi,ai);
        % Test the Network
        y = net(x,xi,ai);
        errorMape = mape(cell2mat(t),cell2mat(y)); % ERROR HERE, not t
        if errorMape < threshold
            code = 1;
            break
        end
        if counter == maxIteration
            code = 0;
            break
        end
        counter = counter + 1;
end