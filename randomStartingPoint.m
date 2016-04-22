function [startP, endP] = randomStartingPoint(inputData,interval)
n = length(inputData);
randomP = randi([1 n],1,1);
if randomP + interval > n
    startP = randomP - interval;
    endP = startP + interval;
else
    startP = randomP;
    endP = startP + interval;
end
end
