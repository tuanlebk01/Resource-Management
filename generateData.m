timeUnit = 10^6; %miro second
startTime = 600*timeUnit;
timeInterval = 3600;
ramMean = [];
cpuMean = [];
cpu = [];
ram = [];
time = [];
%taskID = [];
%jobID = [];
D = dir(['E:\Googledata\task_usage', '\*.csv']);
Num = length(D(not([D.isdir])));
tempStartTime = startTime;
index = 1;
[fileName,numberLines] = readlines(index);
[time,cpu,ram] = loadIntoArray(fileName,numLines);
while(1)
    position1 = find(time == tempStartTime);
    position2 = find(time == tempStartTime + timeInterval*timeUnit);
    firstP = position1(1);
    lastP = position2(end);
    if firstP == 0 % time + time unit is bigger than time in an array
        index = index +1; % move to the next file
            if index > Num % exit when exceeding the number of files
                return
            end
        [fileName,numberLines] = readlines(index);
        [time,cpu,ram] = loadIntoArray(fileName,numLines);
        position1 = find(time == tempStartTime);
        position2 = find(time == tempStartTime + timeInterval*timeUnit);
        firstP = position1(1);
        lastP = position2(end);
    elseif lastP == 0 % time + time interval is bigger than time in an array
        temP = find(time == tempStartTime);
        temIndex = temP(1); % get the last index of the last computed data point.
        tempTime = time(temIndex:end);
        tempCpu = cpu(temIndex:end);
        tempRam = ram(temIndex:end);
        index = index +1; % move to the next file
            if index > Num % exit when exceeding the number of files
                return
            end
        [fileName,numberLines] = readlines(index);
        [time,cpu,ram] = loadIntoArray(fileName,numLines);
        time = [tempTime;time];
        cpu = [tempCpu;cpu];
        ram = [tempRam;ram];
        position1 = find(time == tempStartTime);
        position2 = find(time == tempStartTime + timeInterval*timeUnit);
        firstP = position1(1);
        lastP = position2(end);
    end
        
        
    Ram = mean(ram(firstP:lastP));
    Cpu = mean(cpu(firstP:lastP));
    ramMean = [ramMean Ram];
    cpuMean = [cpuMean Cpu];
    tempStartTime = tempStartTime + timeInterval*timeUnit + 1*timeUnit;
    if index >3
        break
    end
end


















