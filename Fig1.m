clc;close all; clear;
coherence = [0.032,0.064, 0.128, 0.256];
rt_mean = zeros(1,4);
rt_std = zeros(1,4);
accuracy_mean = zeros(1, 4);
accuracy_std = zeros(1, 4);
data = load('all_trials.mat').data;
for k=1:1:4
    ind = data(:,2) == coherence(k);
    accuracy_mean(k) = mean(data(ind,5));
    accuracy_std(k) = 2* std(data(ind,5))/sqrt(size(data,1));
    rt_mean(k) = mean(data(ind, 6));
    rt_std(k) = 2* std(data(ind, 6))/sqrt(size(data,1));
end
%% Plot RT mean
figure;
subplot(1,2,1)
errorbar(coherence*100, rt_mean*1000,rt_std*1000,'o')
hold on;
plot(coherence*100, rt_mean*1000,'LineWidth',2)
xlabel('Motion Strengh (%Coh)','LineWidth',3)
ylabel('Reaction Time (ms)','LineWidth',3)
% PLot accuracy
subplot(1,2,2)
errorbar(coherence*100, accuracy_mean,accuracy_std,'o')
hold on;
plot(coherence*100, accuracy_mean,'LineWidth',2)
xlabel('Motion Strengh (%Coh)','LineWidth',3)
ylabel('Probability Correct (ms)','LineWidth',3)
%% Per Phase Plot
close all;clear;clc;
data = load('per_phase.mat');
[rt_mean1, rt_std1, acc_mean1, acc_std1] = RT_accuracy(data.phase1);
[rt_mean2, rt_std2, acc_mean2, acc_std2] = RT_accuracy(data.phase2);
[rt_mean3, rt_std3, acc_mean3, acc_std3] = RT_accuracy(data.phase3);
rt_mean = [rt_mean1,rt_mean2,rt_mean3];
rt_std = [rt_std1, rt_std2, rt_std3];
acc_mean = [acc_mean1, acc_mean2, acc_mean3];
acc_std = [acc_std1, acc_std2, acc_std3];

figure;
subplot(1,2,1)
x = [1,2,3];
bar(x,rt_mean*1000,'r')
hold on;
er = errorbar(x, rt_mean*1000, rt_std*1000);
er.Color = [0 0 0];                            
er.LineStyle = 'none';
xlabel('Phase')
ylabel('Reaction Time(ms)')
subplot(1,2,2)
bar(x,acc_mean,'r')
hold on;
er = errorbar(x, acc_mean, acc_std);
er.Color = [0 0 0];                            
er.LineStyle = 'none'; 
xlabel('Phase')
ylabel('Accuracy')
%% T-test part
% In this section we examine that distribution are discriminatable or not
figure;
histogram(data.phase1(:,6),20,'Normalization','probability')
hold on;
histogram(data.phase2(:,6),20,'Normalization','probability')
hold on
histogram(data.phase3(:,6),20,'Normalization','probability')
legend('Phase 1', 'Phase 2', 'Phase 3')
ylabel('Normaliz Distributio')
xlabel('t(s)')
% t_test
[h1_1, p1_1] = ttest2(data.phase1(:,6), data.phase2(:,6));

[h2_2, p2_2] = ttest2(data.phase1(:,6), data.phase3(:,6));

[h3_3, p3_3] = ttest2(data.phase2(:,6), data.phase3(:,6));
fprintf('t-test between phase1 and phase2: h = %d, p = %.4f\n', h1_1, p1_1);
fprintf('t-test between phase1 and phase3: h = %d, p = %.4f\n', h2_2, p2_2);
fprintf('t-test between phase2 and phase3: h = %d, p = %.4f\n', h3_3, p3_3);

% Plot its box

data1 = data.phase1(:,6);
data2 = data.phase2(:,6);
data3 = data.phase3(:,6);


combinedData = [data1; data2; data3];

group = [ones(length(data1), 1); 
         2 * ones(length(data2), 1); 
         3 * ones(length(data3), 1)];

% Create box plot
figure;
boxplot(combinedData, group, 'Labels', {'Phase 1', 'Phase 2', 'Phase 3'})

% Add title and labels
title('Box Plot of Three RT Distributions')
ylabel('Values')

%% Function part
function [rt_mean, rt_std, acc_mean, acc_std] = RT_accuracy(data)
    acc_mean = mean(data(:,5));
    acc_std = std(data(:,5))/sqrt(size(data,1));
    rt_mean = mean(data(:, 6));
    rt_std = std(data(:, 6))/sqrt(size(data,1));
end

