%% This gives all all data
close all;clear;clc;
matFiles = dir(fullfile('./','*.mat'));
data = zeros(200*length(matFiles), 7);
for k=1:1:length(matFiles)
    filename = matFiles(k).name;
    tmp = load(filename);
    data(1+(k-1)*200:k*200,:) = tmp.data.result; 
end
save('all_trials.mat','data')
%% This gives per phase data
close all;clear;clc;
matFiles = dir(fullfile('./','*.mat'));
phase1 = zeros(400 * 3, 7);
phase2 = zeros(800 * 3, 7);
phase3 = zeros(400 * 3, 7);
cphase1=1;
cphase2=1;
cphase3=1;
for k=1:1:length(matFiles)
    filename = matFiles(k).name;
    [~, name, ~] = fileparts(filename);
    lastChar = name(end);
    if ismember(lastChar,{'1', '2'})
        tmp = load(filename);
        phase1(1+(cphase1-1)*200:cphase1*200,:) = tmp.data.result; 
        cphase1 = cphase1 +1;
    elseif ismember(lastChar, {'3','4','5','6'})
        tmp = load(filename);
        phase2(1+(cphase2-1)*200:cphase2*200,:) = tmp.data.result; 
        cphase2 = cphase2 +1;
    else
        tmp = load(filename);
        phase3(1+(cphase3-1)*200:cphase3*200,:) = tmp.data.result; 
        cphase3 = cphase3 +1;
    end 
end
save('per_phase.mat','phase1',"phase2",'phase3')


