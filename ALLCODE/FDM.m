%% Creating DDM file
close all;clear;clc;
data = load('per_phase.mat');
createDat(data.phase1,'phase1.dat');
createDat(data.phase2,'phase2.dat');
createDat(data.phase3,'phase3.dat');

%% PLoting the results
% From 3 file witch are in same foolder i got this results
driftRate = [1.5858, 1.6620, 1.9707]; %KS
DSbound = [1.3818, 1.2877, 1.2592]; %CS
noneDStime = [0.7044, 0.5631, 0.4577]; %KS
% Plot this 3 figures
x = [1,2,3];
figure;
subplot(1,3,1)
plot(x,driftRate,'--','Color','red')
hold on;
scatter(x,driftRate,'blue','filled')
xlabel('Phase','LineWidth',3)
ylabel('Drift Rate','LineWidth',3)
subplot(1,3,2)
plot(x,DSbound,'--','Color','red')
hold on;
scatter(x,DSbound,'blue','filled')
xlabel('Phase','LineWidth',3)
ylabel('Decision Bound','LineWidth',3)
subplot(1,3,3)
plot(x,noneDStime,'--','Color','red')
hold on;
scatter(x,noneDStime,'blue','filled')
xlabel('Phase','LineWidth',3)
ylabel('None Decision Time',LineWidth=3)
%% Function Part
function createDat(data,name)
tmp = [data(:,5),data(:,6)];
writematrix(tmp,name,'Delimiter', 'space')
end
