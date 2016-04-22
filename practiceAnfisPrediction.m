load mgdata.dat
time = mgdata(:,1);
x = mgdata(:, 2); %%% size of x is 1201
for t = 118:1117, % 1000 elements in traing data, max size is 1123
    Data(t-117,:) = [x(t-18) x(t-12) x(t-6) x(t) x(t+6)];
end
trnData = Data(1:500,:);
chkData = Data(501:end,:);
fismat = genfis1(trnData);
[fismat1,error1,ss,fismat2,error2] = ...
	  anfis(trnData,fismat,[],[0 0 0 0],chkData);
  anfis_output = evalfis([trnData(:,1:4); chkData(:,1:4)],fismat2);
index = 125:1124; %%%% SOLVED
subplot(2,1,1)
plot(time(index),[x(index) anfis_output])
legend('actual values','predicted values');
xlabel('Time (sec)')
title('MG Time Series and ANFIS Prediction')
subplot(2,1,2)
plot(time(index),x(index) - anfis_output)
xlabel('Time (sec)')
title('Prediction Errors')