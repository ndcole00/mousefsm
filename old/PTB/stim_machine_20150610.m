function stim_machine_20150610

global fsm


s = daq.createSession('ni');
s.addDigitalChannel('Dev1', 'Port0/Line0:4', 'InputOnly');
s.inputSingleScan; % first call is slowest



%when working with the PTB it is a good idea to enclose the whole body of your program
%in a try ... catch ... end construct. This will often prevent you from getting stuck
%in the PTB full screen mode
try
    % Make sure this is running on OpenGL Psychtoolbox:
    AssertOpenGL;
    
    % Disable synctests for this quick demo:
    %oldSyncLevel = Screen('Preference', 'SkipSyncTests', 2);
    
    % Choose screens:
    allscreens = Screen('Screens');
    screenidL = allscreens(end);
    screenidR = allscreens(end-1);
    
    % Setup imagingMode and window position/size depending on mode:
    rect = [];
    imagingMode = 0;
    
    % Open a fullscreen onscreen window on that display, choose a background
    % color of 128 = gray with 50% max intensity:
    [winL,screenRect] = Screen('OpenWindow', screenidL, 128, rect, [], [], [], [], imagingMode);
    winR = Screen('OpenWindow', screenidR, 128, rect, [], [], [], [], imagingMode);
    ifi = Screen('GetFlipInterval', winL);
    
    % Screen parameters:
    scrset.ifi              = ifi; % refresh rate
    scrset.disp             = [screenRect(3),screenRect(4)];
    scrset.cntr             = [scrset.disp(1)/2,scrset.disp(2)/2];
    scrset.fp               = scrset.cntr;
    
    scrset.monitor_distance = 20; % distance of monitor (cm)
    scrset.monitor_width    = 47.5; % Dell P2210: monitor width (cm) 47.5 x 30 cm
    
    scrset.ppd = (( 0.5*scrset.disp(1)) / (atand((0.5*scrset.monitor_width)./scrset.monitor_distance))); % number of pixels per degree Elmain2.cpp Line 880
  
    SF = fsm.spatialfreq;
    period   = round(scrset.ppd./SF);
    phase = 0; %phasesteps(T); phasesteps = pi:(2.*pi.*Steps):3*pi; % use single phase (and translate later)
    
    %We know the refresh rate, so we can work out
    %how many phase steps we need per refresh
%     Refresh = 60;
%     shiftperframe = Pixpersec/Refresh;
%     
    % Initial stimulus params for the gabor patch:
    res = 2*[323 323];
    sc = 80.0;
    freq = 1/period;
    tilt = 0;
    contrast = 0; % to start with gray
    aspectratio = 1;
    
    tw = res(1);
    th = res(2);
    
    % Build a procedural gabor texture for a gabor with a support of tw x th
    % pixels, and a RGB color offset of 0.5 -- a 50% gray.
    %gabortex1 = CreateProceduralGabor(winL, tw, th, 0, [0.5 0.5 0.5 0.0],1,.5);
    %gabortex2 = CreateProceduralGabor(winR, tw, th, 0, [0.5 0.5 0.5 0.0],1,.5);
    gabortex1 = CreateProceduralGabor(winL, tw, th, 0, [0.5 0.5 0.5 0.0]);
    gabortex2 = CreateProceduralGabor(winR, tw, th, 0, [0.5 0.5 0.5 0.0]);
    
    % Draw the gabor once, just to make sure the gfx-hardware is ready for the
    % benchmark run below and doesn't do one time setup work inside the
    % benchmark loop: See below for explanation of parameters...
    Screen('DrawTexture', winL, gabortex1, [], [], tilt, [], [], [], [], kPsychDontDoRotation, [phase+00, freq, sc, contrast, aspectratio, 0, 0, 0]);
    Screen('DrawTexture', winR, gabortex2, [], [], tilt, [], [], [], [], kPsychDontDoRotation, [phase+00, freq, sc, contrast, aspectratio, 0, 0, 0]);
    
    % Perform initial flip to gray background and sync us to the retrace:
    vbl = Screen('Flip', winL,[],[],[],1); % with multiflip
    grayscreen = 1;
    firstframedone = 0;
    
    % Animation loop: Run till stop
    
    while ~fsm.stim_machine_stop
        
        teensyinput = s.inputSingleScan;
        % only one of these 5 should be on at any time
        % 1: cueL, 2:cueR, 3: stim both sides, 4:contrast change L, 5:contrast change R
        if max(teensyinput)==0;
            trigg = 0;
            phase = 0;
            firstframedone = 0;
        else
            if ~firstframedone
                
                trigg = find(teensyinput);
                SF = fsm.spatialfreq;
                period   = round(scrset.ppd./SF);
                tilt = fsm.orientation;
                cyclespersecond = fsm.temporalfreq;
                
                freq = 1/period;
                contrast = fsm.contrast;
                changedcontrast = contrast + contrast * (fsm.contrastchange/100);
                firstframedone = 1;
            end
            phaseincrement = (cyclespersecond * 360) * ifi;
            phase = phase + phaseincrement;
        end
        
        switch trigg
            
            case 0 % gray screen
                if ~grayscreen
                    contrastL = 0;
                    contrastR = 0;
                    
                    Screen('DrawTexture', winL, gabortex1, [], [], tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq, sc, contrastL, aspectratio, 0, 0, 0]);
                    Screen('DrawTexture', winR, gabortex2, [], [], 180-tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq, sc, contrastR, aspectratio, 0, 0, 0]);
                    vbl = Screen('Flip', winL, vbl + 0.5 * ifi,[],[],1);
                    
                    grayscreen = 1;
                end
            
            case 1 % cueL                
                grayscreen = 0;                
                contrastL = contrast;
                contrastR = 0;
                
                Screen('DrawTexture', winL, gabortex1, [], [], tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq, sc, contrastL, aspectratio, 0, 0, 0]);
                Screen('DrawTexture', winR, gabortex2, [], [], 180-tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq, sc, contrastR, aspectratio, 0, 0, 0]);
                vbl = Screen('Flip', winL, vbl + 0.5 * ifi,[],[],1);
                
            case 2 % cueR                
                grayscreen = 0;                
                contrastL = 0;
                contrastR = contrast;
                
                Screen('DrawTexture', winL, gabortex1, [], [], tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq, sc, contrastL, aspectratio, 0, 0, 0]);
                Screen('DrawTexture', winR, gabortex2, [], [], 180-tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq, sc, contrastR, aspectratio, 0, 0, 0]);
                vbl = Screen('Flip', winL, vbl + 0.5 * ifi,[],[],1);
                
                 
            case 3 % Stim on both sides                
                grayscreen = 0;                
                contrastL = contrast;
                contrastR = contrast;
                
                Screen('DrawTexture', winL, gabortex1, [], [], tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq, sc, contrastL, aspectratio, 0, 0, 0]);
                Screen('DrawTexture', winR, gabortex2, [], [], 180-tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq, sc, contrastR, aspectratio, 0, 0, 0]);
                vbl = Screen('Flip', winL, vbl + 0.5 * ifi,[],[],1);
               
                  
            case 4 % Change contrast L                
                grayscreen = 0;                
                contrastL = changedcontrast;
                contrastR = contrast;
                
                Screen('DrawTexture', winL, gabortex1, [], [], tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq, sc, contrastL, aspectratio, 0, 0, 0]);
                Screen('DrawTexture', winR, gabortex2, [], [], 180-tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq, sc, contrastR, aspectratio, 0, 0, 0]);
                vbl = Screen('Flip', winL, vbl + 0.5 * ifi,[],[],1);
               
           case 5 % Change contrast R                
                grayscreen = 0;                
                contrastL = contrast;
                contrastR = changedcontrast;
                
                Screen('DrawTexture', winL, gabortex1, [], [], tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq, sc, contrastL, aspectratio, 0, 0, 0]);
                Screen('DrawTexture', winR, gabortex2, [], [], 180-tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq, sc, contrastR, aspectratio, 0, 0, 0]);
                vbl = Screen('Flip', winL, vbl + 0.5 * ifi,[],[],1);
               
        end
        
        
    end
    
    % A final synced flip, so we can be sure all drawing is finished when we
    % reach this point:
    Screen('Flip', winL,[],[],[],1);
    
    
    % Close window, release all ressources:
    Screen('CloseAll');
    
    % Restore old settings for sync-tests:
    %Screen('Preference', 'SkipSyncTests', oldSyncLevel);
    
    % Done.
    return;
catch
    % This section is executed only in case an error happens in the
    % experiment code implemented between try and catch...
    ShowCursor;
    Screen('CloseAll');
    %Screen('Preference', 'SkipSyncTests', oldSyncLevel);
    psychrethrow(psychlasterror); %output the error message
end

