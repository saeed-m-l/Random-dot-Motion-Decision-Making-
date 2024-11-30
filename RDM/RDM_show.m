function [complete, cur_t, keyCode] = RDM_show(trial_index, dot, scr, direction, coherence, target_color, fp_loc, right_target_loc, left_target_loc)

global data;

%% Initialize dots  

    %set the variables that will be needed for the calculation of dots positions
aperture = dot.aperture;
density = dot.density;
duration = dot.duration;
    %calculate the number of dots for a 'rectangular' aperture. we
    %will apply an oval mask at each frame later.
ndots = round(density .* (aperture(:,3).*aperture(:,4)) / scr.mon_refresh);
dot_angle = pi*direction;

loopi = 1;


    %find the xy displacement of coherent dots
dxdy = repmat(dot.speed*dot.interval/scr.mon_refresh*...
              [cos(dot_angle) -sin(dot_angle)], ndots, 1) * scr.pix_per_deg;
          
d_ppd = repmat(dot.whole_radius, ndots, 1);
dot_pos = (rand(ndots,2,dot.interval)-0.5)*2;
for j = 1 : dot.interval
    dot_pos(:,:,j) = dot_pos(:,:,j) .* d_ppd;
end
 

%% draw dots on the screen 


start_t     = GetSecs;
keyIsDown   = 0;
complete    = 1;       % if the time exceeds the duration, trial is not completed
% flag        = 0;

while 1     %endless loop
    
%     [keyIsDown, secs, keyCode] = KbCheck();
        
    cur_t = GetSecs - start_t;
    if (cur_t >= duration)      %check if the stimulus has been shown for more than 5 secs
        complete = 0;           %subject did not complete the trial
        beep400 = MakeBeep(400,0.2,48000); %give audio feedback
        sound(beep400,48000);
        break;
    end    
    
    Screen('FillOval', scr.wptr, target_color, fp_loc);
    Screen('FillOval', scr.wptr, target_color, right_target_loc);
    Screen('FillOval', scr.wptr, target_color, left_target_loc);
    
    % update dots positions and draw them on the screen
        %find the index of coherently moving dots in this frame
    L = rand(ndots,1) < coherence;
        %move the coherent dots
    dot_pos(L,:,loopi) = dot_pos(L,:,loopi) + dxdy(L,:);
        %replace the other dots
    dot_pos(~L,:,loopi) = (rand(sum(~L),2)-0.5)*2 .* d_ppd(~L,:);
        %wrap around
    L = dot_pos(:,1,loopi) > d_ppd(:,1);
    dot_pos(L,1,loopi) = dot_pos(L,1,loopi) - 2*d_ppd(L,1);
    L = dot_pos(:,1,loopi) < -d_ppd(:,1);
    dot_pos(L,1,loopi) = 2*d_ppd(L,1) - dot_pos(L,1,loopi);
    L = dot_pos(:,2,loopi) > d_ppd(:,2);
    dot_pos(L,2,loopi) = dot_pos(L,2,loopi) - 2*d_ppd(L,2);
    L = dot_pos(:,2,loopi) < -d_ppd(:,2);
    dot_pos(L,2,loopi) = 2*d_ppd(L,2) - dot_pos(L,2,loopi);
        %find the dots that will be shown in the aperture. note that dot_pos
        %is calculated relative to the center of the aperture (not the screen). use 
        %AP_ for filtering.
    L = isInsideRegion(dot_pos(:,:,loopi), (dot.aperture(1)* scr.pix_per_deg),dot.whole_radius(1));
        %round dot_pos and transpose it because Screen wants positions in row format
    pos = round(dot_pos(L,:,loopi))';
        %draw on the screen
    if any(isnan(prod(pos,1))==0)
        Screen('DrawDots', scr.wptr, pos, dot.size, dot.color, dot.whole_center(1:2));
    end
        %update the loop counter
    loopi = loopi + 1;
    if loopi > dot.interval
        loopi = 1;
    end
    
        %flip the screen to make things visible
    Screen('Flip', scr.wptr);  
    
    
    [keyIsDown, secs, keyCode] = KbCheck();
        
    % check if the subject has responded
    if keyIsDown

        a = KbName(keyCode)
        a(1)
        hh = strcmp(a ,'right');
        gg = strcmp(a ,'left');
        
        if (strcmp(a(1) ,'right') || hh(1) ||  strcmp(a(1) ,'left') || gg(1))
            data.keyCode{trial_index}= a;
            break;
            cur_t = GetSecs - start_t;
        end
    end
    
end





