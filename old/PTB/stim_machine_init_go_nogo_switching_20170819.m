function stim_machine_init_go_nogo_switching

global fsm


fsm.s = daq.createSession('ni');
fsm.s.addDigitalChannel('Dev1', 'Port0/Line0', 'InputOnly');
fsm.s.addDigitalChannel('Dev1', 'Port0/Line4', 'InputOnly');% 

fsm.s.inputSingleScan; % first call is slowest



%when working with the PTB it is a good idea to enclose the whole body of your program
%in a try ... catch ... end construct. This will often prevent you from getting stuck
%in the PTB full screen mode
try
    % Make sure this is running on OpenGL Psychtoolbox:
    AssertOpenGL;
    
    % Disable synctests for this quick demo:
    %fsm.oldSyncLevel = Screen('Preference', 'SkipSyncTests', 2);
    
    % Choose screens:
    allscreens = Screen('Screens');
    %screenidL = allscreens(end);
    %screenidR = allscreens(end-1);
    %screenidR = allscreens(2);
    % new machine
    fsm.twomonitors = 1;
    screenidL = 1;
    if fsm.twomonitors; screenidR = 3; end
    
    % Setup imagingMode and window position/size depending on mode:
    rect = [];
    imagingMode = 0;
    fsm.filterMode = 0;
    
    % Open a fullscreen onscreen window on that display, choose a background
    % color of 128 = gray with 50% max intensity:
    [fsm.winL,screenRect] = Screen('OpenWindow', screenidL, 128, rect, [], [], [], [], imagingMode);
    if fsm.twomonitors;[fsm.winR,screenRect] = Screen('OpenWindow', screenidR, 128, rect, [], [], [], [], imagingMode);end
    fsm.ifi = Screen('GetFlipInterval', fsm.winL);
    
    if 1
        % Load gamma correction table
        load ('M:\Data\Adil\FSM_mesoscope\gamma corection mesoscope\calib20170817_DellU2715H_bright50_cont50.mat')
        Screen('LoadNormalizedGammaTable', fsm.winL, GammaTable'*[1 1 1]);
        if fsm.twomonitors;Screen('LoadNormalizedGammaTable', fsm.winR, GammaTable'*[1 1 1]);end
    end
    % Screen parameters:
 
    scrset.disp             = [screenRect(3),screenRect(4)];
    scrset.cntr             = [scrset.disp(1)/2,scrset.disp(2)/2];
    scrset.fp               = scrset.cntr;
    
    scrset.monitor_distance = 20; % distance of monitor (cm)
    scrset.monitor_width    = 47.5; % Dell P2210: monitor width (cm) 47.5 x 30 cm
    
    scrset.ppd = (( 0.5*scrset.disp(1)) / (atand((0.5*scrset.monitor_width)./scrset.monitor_distance))); % number of pixels per degree Elmain2.cpp Line 880
    fsm.scrset = scrset;
    
    SF = fsm.spatialfreq;
    period   = round(scrset.ppd./SF);
    fsm.phase = 0; %phasesteps(T); phasesteps = pi:(2.*pi.*Steps):3*pi; % use single phase (and translate later)
    
    %We know the refresh rate, so we can work out
    %how many phase steps we need per refresh
%     Refresh = 60;
%     shiftperframe = Pixpersec/Refresh;
%     
    % Initial stimulus params for the gabor patch:
    res = [1440 1440];% monior y resolution 4*[323 323];
    %fsm.sc = 250.0; % spatial const of gaussian
    fsm.sc = inf;%250.0; % spatial const of gaussian
    freq = 1/period;
    tilt = 0;
    contrast = 0; % to start with gray
    aspectratio = 1;
    
    tw = res(1);
    th = res(2);
    
    % Build a procedural gabor texture for a gabor with a support of tw x th
    % pixels, and a RGB color offset of 0.5 -- a 50% gray.
    %gabortex1 = CreateProceduralGabor(fsm.winL, tw, th, 0, [0.5 0.5 0.5 0.0],1,.5);
    %gabortex2 = CreateProceduralGabor(fsm.winR, tw, th, 0, [0.5 0.5 0.5 0.0],1,.5);
    fsm.gabortex1 = CreateProceduralGabor(fsm.winL, tw, th, 0, [0.5 0.5 0.5 0.0],1,.5);
    if fsm.twomonitors;fsm.gabortex2 = CreateProceduralGabor(fsm.winR, tw, th, 0, [0.5 0.5 0.5 0.0],1,.5);end
    
    %%% for a checkerboard stim %%%
    % Define a simple 8 by 8 checker board
    checkerboard = 255*repmat(eye(2), 2, 2);
    
    % Make the checkerboard into a texure (4 x 4 pixels)
    fsm.checkerTextureL = Screen('MakeTexture', fsm.winL, checkerboard);
    if fsm.twomonitors;fsm.checkerTextureR = Screen('MakeTexture', fsm.winR, checkerboard);end
    [s1, s2] = size(checkerboard);
    baseRect = [0 0 s1 s2] .* 190;% scale
    [xCenter, yCenter] = RectCenter(screenRect);
    fsm.dstRect = CenterRectOnPointd(baseRect, xCenter, yCenter); % centered
    
    
    % Draw the gabor once, just to make sure the gfx-hardware is ready for the
    % benchmark run below and doesn't do one time setup work inside the
    % benchmark loop: See below for explanation of parameters...
    Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], tilt, [], [], [], [], kPsychDontDoRotation, [fsm.phase, freq, fsm.sc, contrast, aspectratio, 0, 0, 0]);
    if fsm.twomonitors;Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], tilt, [], [], [], [], kPsychDontDoRotation, [fsm.phase, freq, fsm.sc, contrast, aspectratio, 0, 0, 0]);end
    
    % Perform initial flip to gray background and sync us to the retrace:
    pause(0.1)
    Screen('Flip', fsm.winL,[],[],1,1); % with multiflip
    drawnow;pause(0.001);
    return
    
catch
    % This section is executed only in case an error happens in the
    % experiment code implemented between try and catch...
    ShowCursor;
    Screen('CloseAll');
    %Screen('Preference', 'SkipSyncTests', fsm.oldSyncLevel);
    psychrethrow(psychlasterror); %output the error message
end

