% close all
% clear all
% load data
% data = data + 1; % to avoid log(0) in data
% data = log(data);
data = ramMean;
size1 = 3500; % 2*size2+size1 is not bigger than wholeSize.
size2 = 500; % 2*size2+size1 is not bigger than wholeSize.
wholeSize = length(data);
trainingData = zeros(size1, 1);
checkData = zeros(size2, 1);
% prepare training data
trainingData(:, 1) = data(1:size1);
trainingData(:, 2) = data(size2 +1:size2+size1);
trainingData(:, 3) = data(2*size2+1:2*size2+size1);
trainingData(:, 4) = data(wholeSize-size1+1:wholeSize);
% trainingData(:, 5) = data(301:800);

% prepare checking data
checkData(:, 1) = data(size1 +1 :size1 + size2);
checkData(:, 2) = data(1:size2);
checkData(:, 3) = data(size2+1:2*size2);
checkData(:, 4) = data(wholeSize-size1-size2+1:wholeSize-size1);
fismat = genfis1(trainingData,[3 3 3],'gbellmf','linear');
[trainingFismat,trainingError] = anfis(trainingData, fismat,40,[]);

input = [trainingData(:,1:3); checkData(:,1:3)];
anfisOutput = evalfis(input, trainingFismat);

index = 1000:5000;

% diff = data(index)'-anfisOutput(index);
% figure(1)
% plot(time(index), diff);
% xlabel('Time (sec)','fontsize',10);
% title('ANFIS Prediction Errors','fontsize',10);


%plot comparison between prediced and actual values
figure(2)
plot(data(index)');
hold on
plot(anfisOutput(index));
legend('Actual values','Predicted values');
xlabel('Time (Minutes with 5-minute interval)');
ylabel('RAM consumption of jobs');
error = rmse(data(index)',anfisOutput(index))
mapeError = mape(data(index)',anfisOutput(index))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%Anfis using gaussmf%%%%%%%%%%%%%
% RMSE for CPU consumption without variance reduction:  0.0323
% RMSE for CPU consumption with variance reduction:  0.0270
%%%%%%%%%%%%%%%%%%%%Anfis using gbellmf%%%%%%%%%%%%%
% RMSE for CPU consumption without variance reduction:  0.0270
% RMSE for RAM consumption without variance reduction:  0.0317









