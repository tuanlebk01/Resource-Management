load mgdata.dat
a = mgdata;
time = a(:, 1);
x_t = a(:, 2);

trn_data = zeros(500, 5);
chk_data = zeros(500, 5);

% prepare training data
trn_data(:, 1) = x_t(101:600);
trn_data(:, 2) = x_t(107:606);
trn_data(:, 3) = x_t(113:612);
trn_data(:, 4) = x_t(119:618);
trn_data(:, 5) = x_t(125:624);

% prepare checking data
chk_data(:, 1) = x_t(601:1100);
chk_data(:, 2) = x_t(607:1106);
chk_data(:, 3) = x_t(613:1112);
chk_data(:, 4) = x_t(619:1118);
chk_data(:, 5) = x_t(625:1124);

index = 119:1118; % ts starts with t = 0

fismat = genfis1(trn_data,[2 2 2 2],'gbellmf','linear');
[trn_fismat,trn_error] = anfis(trn_data, fismat,40,[],chk_data)

input = [trn_data(:, 1:4); chk_data(:, 1:4)];
anfis_output = evalfis(input, trn_fismat);
break
index = 125:1124;

diff = x_t(index)-anfis_output;
plot(time(index), diff);
xlabel('Time (sec)','fontsize',10);
title('ANFIS Prediction Errors','fontsize',10);









