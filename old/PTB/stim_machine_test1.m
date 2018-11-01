function stim_machine_test1

try
   
    
    
    % Make sure this is running on OpenGL Psychtoolbox:
    AssertOpenGL;
    
    % Initial stimulus params for the gabor patch:
    res = 2*[323 323];
    phase = 0;
    sc = 80.0;
    freq = .1;
    tilt = 0;
    contrast = 100.0;
    aspectratio = 1;
    
    
    % Disable synctests for this quick demo:
    oldSyncLevel = Screen('Preference', 'SkipSyncTests', 2);
    
    % Choose screens:
    allscreens = Screen('Screens');
    screenidL = allscreens(end);
    screenidR = allscreens(end-1);
    
    
    % Setup imagingMode and window position/size depending on mode:
    
    rect = [];
    imagingMode = 0;
    
    % Open a fullscreen onscreen window on that display, choose a background
    % color of 128 = gray with 50% max intensity:
    winL = Screen('OpenWindow', screenidL, 128, rect, [], [], [], [], imagingMode);
    winR = Screen('OpenWindow', screenidR, 128, rect, [], [], [], [], imagingMode);
    ifi = Screen('GetFlipInterval', winL);
    
    tw = res(1);
    th = res(2);
   
    % Build a procedural gabor texture for a gabor with a support of tw x th
    % pixels, and a RGB color offset of 0.5 -- a 50% gray.
    gabortex1 = CreateProceduralGabor(winL, tw, th, 0, [0.5 0.5 0.5 0.0],1,.5);
    gabortex2 = CreateProceduralGabor(winR, tw, th, 0, [0.5 0.5 0.5 0.0],1,.5);
     
    % Draw the gabor once, just to make sure the gfx-hardware is ready for the
    % benchmark run below and doesn't do one time setup work inside the
    % benchmark loop: See below for explanation of parameters...
    Screen('DrawTexture', winL, gabortex1, [], [], tilt, [], [], [], [], kPsychDontDoRotation, [phase+180, freq, sc, contrast, aspectratio, 0, 0, 0]);
    Screen('DrawTexture', winR, gabortex2, [], [], tilt, [], [], [], [], kPsychDontDoRotation, [phase+180, freq, sc, contrast, aspectratio, 0, 0, 0]);
    
    % Perform initial flip to gray background and sync us to the retrace:
    vbl = Screen('Flip', winL,[],[],[],1); % with multiflip
    ts = vbl;
    count = 0;
    
    % Animation loop: Run for 10000 iterations:
    while count < 10000
        count = count + 1;
        
        % Set new rotation angle:
        %tilt = count/10;
        
        % Drift phase and aspectratio as well...
       
            phase = count * 10;
            
        
        % Draw the Gabor patch: We simply draw the procedural texture as any other
        % texture via 'DrawTexture', but provide the parameters for the gabor as
        % optional 'auxParameters'.
        Screen('DrawTexture', winL, gabortex1, [], [], tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq, sc, contrast, aspectratio, 0, 0, 0]);
        Screen('DrawTexture', winR, gabortex2, [], [], tilt, [], [], [], [], kPsychDontDoRotation, [180-phase, freq/2, sc, contrast, aspectratio, 0, 0, 0]);
        
        
        %Screen('Flip', win1,[],[],[],1); % with multiflip
        vbl = Screen('Flip', winL, vbl + 0.5 * ifi,[],[],1);
        % In non-benchmark mode, we now readback the drawn gabor from the
        % framebuffer and then compare it against the Matlab reference:
        
        
        
        % Abort requested? Test for keypress:
        if KbCheck
            break;
        end
        
    end
    
    % A final synced flip, so we can be sure all drawing is finished when we
    % reach this point:
    tend = Screen('Flip', winL,[],[],[],1);
    
    
    % Close window, release all ressources:
    Screen('CloseAll');
    
    % Restore old settings for sync-tests:
    Screen('Preference', 'SkipSyncTests', oldSyncLevel);
    
    % Done.
    return;
catch
    % This section is executed only in case an error happens in the
    % experiment code implemented between try and catch...
    ShowCursor;
    Screen('CloseAll');
    Screen('Preference', 'SkipSyncTests', oldSyncLevel);
    psychrethrow(psychlasterror); %output the error message
end

