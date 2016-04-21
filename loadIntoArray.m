function [time,cpu,ram] = loadIntoArray(fileName,numLines)
time = csvread(fileName,0,0,[0,0,numLines-2,0]);
%JobID = csvread(fileName,0,2,[0,2,numLines-2,2]);
%TaskID = csvread(fileName,0,3,[0,3,numLines-2,3]);
cpu = csvread(fileName,0,5,[0,5,numLines-2,5]);
ram = csvread(fileName,0,6,[0,6,numLines-2,6]);
end