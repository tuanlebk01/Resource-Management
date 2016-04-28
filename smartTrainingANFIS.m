function [net] = smartTrainingANFIS(net,input,windowSize,errorTolerance)
% A sliding window will be used
trnRatio = 0.7;
valRatio = 0.15;
timestep = 1;
input = input(end-windowSize:end);
n = length(input);
for t = 4:n-1
    Data(t-3,:) = [input(t-timestep*3) input(t-timestep*2) input(t-timestep) input(t) input(t+timestep)];
end
trnData = Data(1:n*trnRatio,:);
chkData = Data(n*trnRatio : n*trnRatio + valRatio*n,:);
fismat = genfis1(trnData);
[fismat1,error1,ss,net,error2] = ...
          anfis(trnData,fismat,[],[0 0 0 0],chkData);
end
    