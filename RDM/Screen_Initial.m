function scr=Screen_Initial(scr)


% 1. OPEN THE SCREEN.
[scr.wptr, scr.w_rect] = Screen('OpenWindow',scr.scr_ptr,scr.back_color,scr.w_size);


% 2. COMPUTE PIXELS PER DEGREE for the given screen

if isempty(scr.mon_width_cm)
    scr.mon_width_cm = Screen('DisplaySize', scr.scr_ptr) / 10;
end

scr.pix_per_deg = scr.w_rect(3) * ...
                            (1 ./ (2 * atan2(scr.mon_width_cm / 2, scr.view_dist_cm))) * ...
                            pi/180;


% 3. Get monitor refresh rate
if ~isempty(scr.mon_refresh)
    scr.mon_refresh = Screen('NominalFrameRate', scr.scr_ptr);
end


% 4. Hide the cursor
HideCursor;



