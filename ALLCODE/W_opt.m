%%
% Load your data
% Data format: [correctness, RT, coherence]
data = load('per_phase.mat');

phase1 = data.phase1(:,[5,6,2]);
phase2 = data.phase2(:,[5,6,2]);
phase3 = data.phase3(:,[5,6,2]);

%fixed parameters
thr = 0.45;
u0 = 30;



% Initial guess for parameters [nDT, I0]
initial_params = [0.4, 0.45];
options = optimset('Display', 'iter', 'MaxIter', 150, 'MaxFunEvals', 2000);

% Optimize for Phase 1
[best_params_1, ~, ~, output_1] = fminsearch(@(params) fit_wang_model(params, phase1, thr, u0), initial_params, options);

disp('Best parameters for phase 1:');
disp(best_params_1);
disp('Number of iterations for phase 1:');
disp(output_1.iterations);
disp('Number of function evaluations for phase 1:');
disp(output_1.funcCount);
%%
 
model1 = wang_model(best_params_1, phase1, thr, u0);

figure;
histogram(phase1(:,2),20) % RT from data
hold on;
histogram(model1(:,2),20) % RT from model
title('Phase 1');
ylabel('RT distribution')
legend('Real distribution','Model distribution')
 %%
% Optimize for Phase 2 ( It was noe wanted)
thr = 0.45;
u0 = 28;

% Initial guess for parameters [nDT, I0]
initial_params = [0.4, 0.45];
[best_params_2, ~, ~, output_2] = fminsearch(@(params) fit_wang_model(params, phase2, thr, u0), initial_params, options);

disp('Best parameters for phase 2:');
disp(best_params_2);
disp('Number of iterations for phase 2:');
disp(output_2.iterations);
disp('Number of function evaluations for phase 2:');
disp(output_2.funcCount);
%PLot 
model2 = wang_model(best_params_2, phase2, thr, u0);
figure
histogram(phase2(:,2),20) % RT from data
hold on;
histogram(model2(:,2),20) % RT from model
title('Phase 2');


%% Optimize for Phase 3
thr = 0.25;
u0 = 25;

% Initial guess for parameters [nDT, I0]
initial_params = [0.4, 0.45];
[best_params_3, ~, ~, output_3] = fminsearch(@(params) fit_wang_model(params, phase3, thr, u0), initial_params, options);

disp('Best parameters for phase 3:');
disp(best_params_3);
disp('Number of iterations for phase 3:');
disp(output_3.iterations);
disp('Number of function evaluations for phase 3:');
disp(output_3.funcCount);
model3 = wang_model(best_params_3, phase3, thr, u0);
%%
figure;
histogram(phase3(:,2),20) % RT from data
hold on;
histogram(model3(:,2),20) % RT from model
title('Phase 3');
ylabel('RT distribution')
legend('Real distribution','Model distribution')
%% Plot distribution



% Plot for model 1 (compare distributions)
figure;
subplot(1,3,1)
histogram(phase1(:,2),20) % RT from data
hold on;
histogram(model1(:,2),20) % RT from model
title('Phase 1');

subplot(1,3,2)
histogram(phase2(:,2),20) % RT from data
hold on;
histogram(model2(:,2),20) % RT from model
title('Phase 2');

subplot(1,3,3)
histogram(phase3(:,2),20) % RT from data
hold on;
histogram(model3(:,2),20) % RT from model
title('Phase 3');

%% Function part 
function C1 = wang_model(params, data, thr, u0)
    nDT = params(1);
    I0 = params(2);

    ModelRunNo = size(data, 1);
    C1 = zeros(ModelRunNo, 3);
    
    for j0 = 1:ModelRunNo
        coh_level = 25.6;
        X = WANG([thr, coh_level, I0, u0]);
        
        C1(j0, 2) = X(1) + nDT; % reaction time
        C1(j0, 1) = X(3); % choice/correctness
    end
end


function [error] = fit_wang_model(params, data, thr, u0)
    nDT = params(1);
    I0 = params(2);

    ModelRunNo = size(data, 1);
    C1 = zeros(ModelRunNo, 6);
    
    for j0 = 1:ModelRunNo
        coh_level = 25.6;
        X = WANG([thr, coh_level, I0, u0]);
        
        C1(j0, 3) = X(3); % choice
        C1(j0, 5) = X(1) + nDT; % reaction time
        C1(j0, 6) = X(3); % correctness
    end
    
    % Calculate error as the difference between model and data RTs and correctness
    model_rts = C1(:, 5);
    model_correctness = C1(:, 6);
    data_rts = data(:, 2);
    data_correctness = data(:, 1);

    rt_error = sum((model_rts - data_rts).^2);
    correctness_error = sum((model_correctness - data_correctness).^2);
    error = rt_error + correctness_error;
end
