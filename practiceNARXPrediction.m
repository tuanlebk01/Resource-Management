clear all
load cpuMean
x = cpuMean(1:end-2);
y = cpuMean(2:end-1);
X = con2seq(x);
T = con2seq(y);
net = narxnet(1:2,1:2,10);
[x,xi,ai,t] = preparets(net,X,{},T);
net = train(net,x,t,xi,ai);
y = net(x,xi,ai);
%view(net)
netc = closeloop(net);
%view(netc)
[x,xi,ai,t] = preparets(netc,X,{},T);
yc = netc(x,xi,ai);
x1 = x(1:20);
t1 = t(1:20);
%x2 = x(21:80);
x2 = num2cell(rand(1,20));
[x,xi,ai,t] = preparets(net,x1,{},t1);
[y1,xf,af] = net(x,xi,ai);
[netc,xi,ai] = closeloop(net,xf,af);
[y2,xf,af] = netc(x2,xi,ai);
figure(1)
plot(cell2mat(y2))
hold on; plot(cell2mat(T(1:40)))
mape(cell2mat(y2),cell2mat(T(1:40)))
