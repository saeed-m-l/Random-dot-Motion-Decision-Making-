%% Decision making _Training Phase 2
% Soodeh Majidpour, Elham Ramezannezhad

close all;   
clear all;
clc;
Screen('Preference', 'SkipSyncTests', 1); 

try
%% Get the subject data

prompt   = {'Name','Block No.'};
defaults = {'Name','1'};
answer   = inputdlg(prompt, 'Subject''s information', 1, defaults);
if isempty(answer)
    return
end
[subName, block] = deal(answer{:});
%Create the structure for the data to be stored
data.name       = subName;
data.block      = str2double(block);
data.date       = datestr(now,'mm_dd_yyyy_HH_MM_SS');

fileName        = strcat(subName,'_block_',block,'.mat');

%% Parameter setting

%trial parameters
num_trial       = 200;
escape          = KbName('q'); 

% screen param
scr.scr_ptr         = 0;            % screen pointer
scr.mon_width_cm    = 36.5;      
scr.mon_refresh     = 60;  
scr.view_dist_cm    = 57;
scr.w_size          = [];
scr.back_color      = [0 0 0];
scr                 = Screen_Initial(scr);
scr_center          = scr.w_rect(3:4)/2;

% dots param
dot.aperture        = [0 0 5 5];
dot.speed           = 5; % It was five
dot.density         = 16.7;
dot.interval        = 3;
dot.size            = 2;
dot.duration        = 1.5;        % 1 s
dot.color           = [255 255 255];
dot.whole_center    = (scr.w_rect(3:4)/2);
dot.whole_radius    = (dot.aperture(3:4)/2) * scr.pix_per_deg;

% single_coherence    = [0, 0.032, 0.064, 0.128, 0.256, 0.512];     %coherence of the trials

single_coherence    = [0.032, 0.064, 0.128, 0.256]; 
%set fixation point and target parameters
fp_diam             = 0.3 * scr.pix_per_deg;      %diameter of fixation point
target_diam         = 0.5 * scr.pix_per_deg;        %diameter of targets
fp_radius           = fp_diam/2;
target_radius       = target_diam/2;
target_color        = [255 0 0];

fp_loc              = [scr_center(1)-fp_radius, scr_center(2)-fp_radius ...
                    scr_center(1)+fp_radius, scr_center(2)+fp_radius];
right_target_width  = scr_center(1) + (10 * scr.pix_per_deg);     %width of center of the right target
right_target_loc    = [right_target_width-target_radius, scr_center(2)-target_radius,...       %location of the right target
                    right_target_width+target_radius, scr_center(2)+target_radius];
left_target_width   = scr_center(1) - (10 * scr.pix_per_deg);      %width of center of the left target
left_target_loc     = [left_target_width-target_radius, scr_center(2)-target_radius,...         %location of the left target
                    left_target_width+target_radius, scr_center(2)+target_radius];

%Create the matrix of conditions
condition           = repmat(single_coherence',50,1);         %Repeat conditions to create needed trials for one block
condition           = condition(Shuffle(1:num_trial),:);      %Shuffle rows of the matrix to generate random trials
      
%Generate random directions for RDM
direction           = [zeros(num_trial/2,1);ones(num_trial/2,1)];    %0 indicates right and 1 indicates left
direction           = Shuffle(direction);

%Create the matrix of trials consisting of conditions and directions
trials              = [(1:num_trial)', condition, direction];
                                % 1: number of trial
                                % 2: coherence of the stimulus
                                % 3: direction


rec    = zeros(num_trial, 4);   % subject response is saved in this matrix
                                % 1: subject response
                                % 2: response status (correctness of response)
                                % 3: reaction time
                                % 4: completed or not

   % focus on command window
 commandwindow;
    %set the priority to the maximum
 Priority(MaxPriority(scr.scr_ptr));
 
 
%% stimulus presentation 

    %wait 0.5 sec
WaitSecs(0.5);

for i = 1 : num_trial
    
    %Show fixation point
    Screen('FillOval', scr.wptr, target_color, fp_loc);
    Screen('Flip', scr.wptr);
  
    % wait for keyboard
    [secs, keyCode2, deltaSecs] = KbWait();
    % check if the pressed key is Space Key
    while (~strcmp(KbName(keyCode2) ,'space'))
        [secs, keyCode2, deltaSecs] = KbWait();
    end
    WaitSecs(0.1);
        
    %RDM_Show
    [complete, t1, keyCode1] = RDM_show(i, dot, scr, trials(i,3), trials(i,2), target_color, fp_loc, right_target_loc, left_target_loc); 
    
    if complete
        rec(i,4) = 1;      %trial has been completed
        rec(i,3) = t1;     %save the response time
        if strcmp(KbName(keyCode1) ,'right')
            rec(i,1) = 0;
        else
            rec(i,1) = 1;
        end
    end

    Screen('Flip', scr.wptr);
    
    % Audio feedback
    if rec(i,1) == trials(i,3) 
        rec(i,2) = 1;           %subjcet gave the correct response
        beep250 = MakeBeep(250,0.2,48000);
        sound(beep250,48000);
    else 
        rec(i,2) = 0;           %subjcet gave the wrong response
        beep550 = MakeBeep(550,0.2,48000);
        sound(beep550,48000);
    
    end   
end

%Store the result of the block
result = [trials, rec];         
            % 1: number of trial
            % 2: coherence of the stimulus
            % 3: direction
            % 4: subject response
            % 5: response status (correctness of response)
            % 6: reaction time
            % 7: completed or not
            

%% Compute the performance and reaction time, give feedback

accuracy_index      = find((result(:,2)~= 0) & (result(:,7) ~= 0));   %Exclude the not completed trials and those with 0% coherence
accuracy            = sum(result(accuracy_index,5))/numel(accuracy_index);
mean_RT             = mean(result(:,6));

%Compute the reaction time for 0% coherence
zero_index          = find((result(:,2)== 0) & (result(:,7) ~= 0));
zero_mean_RT        = mean(result(zero_index,6));


%Save the result of the subject
data.result         = result;
data.mean_RT        = mean_RT;
data.accuracy       = accuracy;
data.zero_mean_RT   = zero_mean_RT;
save(fileName, 'data');

%Give feedback due to the performance and accuracy
if (zero_mean_RT < 1) && (accuracy >= 0.8) 
    feedback_msg = 'Keep it Up!';
elseif (zero_mean_RT < 1) && (accuracy < 0.8)
    feedback_msg = 'Try to be more accurate!';
elseif (zero_mean_RT > 1) && (accuracy >= 0.8)
    feedback_msg = 'Try to be faster!';
end

%Draw the feedback message on screen
Screen('DrawText', scr.wptr, feedback_msg, fp_loc(1)-70, fp_loc(2), [255 10 10]);
Screen('Flip', scr.wptr);
WaitSecs(2);
KbWait();

%% Termination 

    %set the priority of the thread back to zero
    Priority(0);    
    %close all the windows and screens
    Screen('CloseAll');   
    %make the cursor visible
    ShowCursor;

catch err
    
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    rethrow(err);
    
end 