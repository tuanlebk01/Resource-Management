rng('default')

rnds = rand(1,100);
trnd = linspace(0,1,100);

fnc = rnds + trnd;

% plot(fnc)

Mean = mean(fnc(1:25));
StandardD = std(fnc(1:25));

[a,b]=cusum(fnc,5,1,mfnc,sfnc);

compared = 5*StandardD + Mean
fnc(a)


% figure(2)
% plot(fnc)