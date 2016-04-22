endPoint = 101;
predicedPoints = 1;
Ram = resourceUsage.RAM(1:endPoint,:);
time = 1:endPoint;
model1 = fitlm(time,Ram);
predicted = predict(model1,endPoint+1)
actual = resourceUsage.RAM(endPoint+1,:)
error = mape(predicted,actual)
resourceUsage(endPoint:endPoint+2,:)