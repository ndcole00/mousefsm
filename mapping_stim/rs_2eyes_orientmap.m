
function rs_2eyes_orientmap

DEMO       = 0; % if DEMO set to 1, show stimulus, leave out saving of logfiles/writing triggers etc.
USBCONNECT = 1; % if USBCONNECT is 1, then bits sent to USBport
SHOWTEXT   = 0;
PASSIVEMODE = 1; % presenting stimuli without reading digital input from Labview using inputSingleScan
TOKEN       = 1; % ask user to specify token

EYESEL = 1; % 0=both eyes, 1=only left eye (other grey), 2=only right eye, 3=left and right but only conditions with one grating at a time

if ~DEMO
    %FILENAME%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    n = 1;
    %Concatenation to make filename
    rootdir = 'C:\Jasper\Data\AuxRec\';
    stem    = 'rs_2eyes';
    
    D=datestr(now,'yyyymmdd_HHMMSS');
    if TOKEN==1,
        TOK=input('Enter Token: ','s');
        TOK=['__',TOK,'_'];
    else
        TOK='';
    end
    fnt = [rootdir,D,TOK,stem,'.mat'];
    if exist(fnt), error('filename already exists!'); end
    filename = fnt;
else
    filename = 'DEMO';
end

if USBCONNECT
    s = daq.createSession('ni');
    s.addDigitalChannel('Dev1', 'Port0/Line0:2', 'OutputOnly'); % stimulus bits to auxiliary computer
    s.addDigitalChannel('dev1', 'Port1/Line0:7', 'OutputOnly'); % word bit to auxiliary computer
    s.addDigitalChannel('dev1', 'Port2/Line0',   'InputOnly'); % word bit to auxiliary computer
    
    % outputs
    % 1(P0.0 AuxRec) word bit
    % 2(P0.1 AuxRec) stim bit
    % 3(P0.2 AuxRec) targ bit
    % 9:16(P1.1:P1.7,P2.0=PFI1:PFI8 AuxRec) value of word bit
    % inputs to StimComp
    % 1(P0.0 StimComp) word bit
    % 2(P0.1 StimComp) stim bit
    % 3(P0.2 StimComp) targ bit
    % 3(P0.8:P1.5 StimComp) value of word bit
    bits.wrd = 1;
    bits.stm = 2;
    bits.trg = 3;
    bits.wrdvalue = [4:11];
    
    s.inputSingleScan; % first call is slowest
end
waitfordigin = 0; % wait for digital input

%when working with the PTB it is a good idea to enclose the whole body of your program
%in a try ... catch ... end construct. This will often prevent you from getting stuck
%in the PTB full screen mode
try,
    
    AssertOpenGL; % Make sure the script is running on Psychtoolbox-3
    
    if 0,
        dum=Screen('Screens');
        for i=1:length(dum),
            [width, height]=Screen('DisplaySize',dum(i));
            rect=Screen('Rect',dum(i));
            fprintf('Screen %d,rect=[%d %d %d %d],w=%4d,h=%4d\n',dum(i),rect(1),rect(2),rect(3),rect(4),width,height);
        end
    end
    
    % Enable unified mode of KbName, so KbName accepts identical key names on
    % all operating systems (not absolutely necessary, but good practice):
    KbName('UnifyKeyNames');
    
    KbCheck; % first call to KbCheck takes itself some time - after this it is in the cache and very fast
    olddebuglevel=Screen('Preference', 'VisualDebuglevel', 3); % set higher DebugLevel, so not all kinds of messages flashed each time you start the experiment:
    %HideCursor; % edit HideCursor
    escapeKey = KbName('ESCAPE');

    STM.lumgray   = calib20130403_gammacon(0.5,'rgb2lum');
    STM.lumblack  = calib20130403_gammacon(0,'rgb2lum');
    STM.lumwhite  = STM.lumgray+(STM.lumgray-STM.lumblack);
    STM.rgbgray   = round(255*calib20130403_gammacon(STM.lumgray,'lum2rgb'));
    STM.rgbblack  = round(255*calib20130403_gammacon(STM.lumblack,'lum2rgb'));
    STM.rgbwhite  = round(255*calib20130403_gammacon(STM.lumwhite,'lum2rgb'));
    
    % initialize screen
    screens=Screen('Screens');
    screenNumber=max(screens);
    
    % Open double-buffered onscreen window with the requested stereo mode:
    screenNumber=1;
    stereoMode=4;
    [expWin,screenRect]=Screen('OpenWindow',screenNumber,STM.rgbgray,[],[],[],stereoMode);
    
%     [gammatable, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable',expWin);
%     %Screen('LoadNormalizedGammaTable', windowPtrOrScreenNumber, table [, loadOnNextFlip] [, physicalDisplay]);
%     figure;plot(gammatable)
    ifi=Screen('GetFlipInterval',expWin); % Screen('GetFlipInterval?')
    
    % We choose a text size of 24 pixels - Well readable on most screens:
    Screen('TextSize', expWin, 24);
    Screen('TextColor',expWin,[255 0 0]);
    if 0,
        % Select left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer',expWin,EyeLeft);
        % Draw left stim:
        DrawFormattedText(expWin,sprintf('Left\nEye'), 'center', 'center'); % help DrawFormattedText
        
        % Select right-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer',expWin,EyeRight);
        % Draw right stim:
        DrawFormattedText(expWin,sprintf('Right\nEye'), 'center', 'center'); % help DrawFormattedText
        vbl = Screen('Flip', expWin);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % general settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %photodiode settings
    STM.use_pd   = 1;                        % 0 disables photodiode square
    STM.diodesz  = 100; % size of photodiode detection square in pixels
    STM.diodesz  = 120; % size of photodiode detection square in pixels
    STM.diodecol = 255;
    
    %STM.diodepos = [screenRect(1) screenRect(4)-STM.diodesz STM.diodesz screenRect(4)]; % left bottom
    %STM.diodepos = [screenRect(3)-STM.diodesz screenRect(4)-STM.diodesz screenRect(3) screenRect(4)]; % right bottom
    STM.diodepos = [screenRect(1) screenRect(2) STM.diodesz STM.diodesz]; % left top
    
    % times in ms
    %if PASSIVEMODE,
        TIMING.EVENT1_TIME = 2000; % time of event 1        
        % 25-11-2013 changed from 2000 to 3000
        TIMING.EVENT1_TIME = 3000; % time of event 1        
        TIMING.EVENT2_TIME = 1500;        
        TIMING.ITI         = 0;
%     else
%         TIMING.EVENT1_TIME = 1000; % time of event 1
%         TIMING.EVENT2_TIME = 20000;
%         TIMING.ITI         = 200;
%     end
    
    TIMING.EVENT1_FRAMES = round( (TIMING.EVENT1_TIME/1000)./ifi ); % time of event 1 in frames
    TIMING.EVENT2_FRAMES = round( (TIMING.EVENT2_TIME/1000)./ifi ); % time of event 1 in frames
    TIMING.waitframes = 1;
    
    % Screen parameters:
    scrset.ifi              = ifi; % refresh rate
    scrset.disp             = [screenRect(3),screenRect(4)];
    scrset.cntr             = [scrset.disp(1)/2,scrset.disp(2)/2];
    scrset.fp               = scrset.cntr;
    
    scrset.monitor_distance = 20; % distance of monitor (cm)
    scrset.monitor_width    = 47.5; % Dell P2210: monitor width (cm) 47.5 x 30 cm
    
    scrset.ppd = (( 0.5*scrset.disp(1)) / (atand((0.5*scrset.monitor_width)./scrset.monitor_distance))); % number of pixels per degree Elmain2.cpp Line 880
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %EXPERIMENT SPECIFIC CODING STARTS HERE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %-----------------------------------
    % stimulus parameters
    
    EyeLeft  = 0;
    EyeRight = 1;
    EyeDiode = 0;
    
    FreqSpatial  = [0.04]; % cyc/deg
    FreqTemporal = [2]; % Hz
    % length(FreqSpatial)*length(FreqTemporal)
    clear GAB;
    for i=1:length(FreqSpatial),
        GAB{i}.SF       = FreqSpatial(i);
        GAB{i}.Period   = round(scrset.ppd./GAB{i}.SF);
        GAB{i}.Contrast = 100;
        
        orientind = [0]; % use single orientation (and rotate later)
        ori = 1;
        GAB{i}.Orient = orientind(ori);
        T = 1
        GAB{i}.Phase = 0; %phasesteps(T); phasesteps = pi:(2.*pi.*Steps):3*pi; % use single phase (and translate later)
        
        for j=1:length(FreqTemporal),
            GAB{i}.Cycpersec(j)    = FreqTemporal(j);
            GAB{i}.Pixpersec(j)    = GAB{i}.Cycpersec(j)*GAB{i}.Period;
            
            %We know the refresh rate, so we can work out
            %how many phase steps we need per refresh
            Refresh = 60;
            GAB{i}.shiftperframe(j) = GAB{i}.Pixpersec(j)./Refresh;
        end % for j=1:length(FreqTemporal),
    end % for i=1:length(FreqSpatial),
    
    % compute max xoffset
    maxoffset = zeros([1,length(GAB)])
    for i=1:length(GAB),
        maxoffset(i)=GAB{i}.Period;
    end
    maxoffset=max(maxoffset); % if mod(maxoffset,2)==1, maxoffset=maxoffset+1; end
    brd = 2*maxoffset;
    GSIZ = max([scrset.disp(1)/2,scrset.disp(2)])+2*brd; % size of texture
    TSIZ = length(-ceil(GSIZ/2):ceil(GSIZ/2));
    % make gratings
    for i=1:length(FreqSpatial),
        GAB{i}.hsiz = ceil(GSIZ/2);
        %GAB{i}.hsiz = max(scrset.disp)/2;
        
        % create 2D sine grating
        [x,y]=meshgrid(-GAB{i}.hsiz:GAB{i}.hsiz);
        X=x*cosd(GAB{i}.Orient)+y*sind(GAB{i}.Orient); %rotate axes
        Y=-x*sind(GAB{i}.Orient)+y*cosd(GAB{i}.Orient);
        snw=sin(2*pi*(1/GAB{i}.Period)*X+GAB{i}.Phase);
        %
        %         gb = 255*snw; % figure;imagesc(gb);colorbar;
        %         gb = uint8(gb); %
        %
        %         gratingtex{i} = Screen('MakeTexture',expWin,gb); % Screen('MakeTexture?')
        GAB{i}.tsiz = size(x,1);
        
        GAB{i}.Contrast = 100;
        L = (GAB{i}.Contrast./100).*(STM.lumgray-STM.lumblack);
        gb=(snw.*L)+STM.lumgray;
        
        ac = (max(max(gb))-min(min(gb)))./(max(max(gb))+min(min(gb))); % actual contrast
        
        gbc = 255*calib20130403_gammacon(gb,'lum2rgb'); % figure('Units','centimeters','Position',[98 10 14 9]);imagesc(gbc);colorbar;
        % min(min(gbc)),mean(mean(gbc)),max(max(gbc));
        
        gratingtex{i} = Screen('MakeTexture',expWin,gbc); % Screen('MakeTexture?')
    end % for i=1:length(FreqSpatial),
    
    %-----------------------------------
    % testing
    
    if 0,
        cur.frqs = 1;
        cur.ori  = 1;
        cur.frqt = 1;
        RotAngle = STM.orient(cur.ori,1);
        z = 0;
        xoffset = mod(z*GAB{cur.frqs}.shiftperframe(cur.frqt),GAB{cur.frqs}.Period);
        z=z+1;
        srcRect=[1-1+brd,1-1+brd,scrset.disp(1)/2+brd,scrset.disp(2)+brd]
        srcRect=[xoffset 0 xoffset+TSIZ TSIZ];
        %dstRect=[xoffset 0 (xoffset + scrset.disp(1)/2) GAB{cur.frqs}.hsiz];
        
        % Select left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer',expWin,EyeLeft);
        RotAngle=0
        Screen('DrawTexture',expWin, gratingtex{cur.frqs}, srcRect, [], RotAngle);
        DrawFormattedText(expWin,sprintf('Left\nEye'), 'center', 'center'); % help DrawFormattedText
        
        % Select right-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer',expWin,EyeRight);
        RotAngle=90
        Screen('DrawTexture',expWin, gratingtex{cur.frqs}, srcRect, [], RotAngle);
        DrawFormattedText(expWin,sprintf('Right\nEye'), 'center', 'center'); % help DrawFormattedText
        
        vbl = Screen('Flip', expWin);
    end
    
    
    %--------------------------------------------------------------------------
    STM.orient = [0 45 90 135 180 225 270 315];
    
    STM.C = []; z = 0;
    for i=1:length(STM.orient),
        for j=1:length(STM.orient),
            z = z+1;
            STM.C(z,:)=[i,j];            
        end
    end
    
    % all autocombinations
    %STM.C = [[1:length(STM.orient)]',[1:length(STM.orient)]']
    
    % experiment design matrix: all combis of orientations
    %STM.C=[STM.C; nchoosek([1:length(STM.orient)],2) ];
    
    % also include conditions with one orientation on each side
    STM.C=[STM.C; [[1:length(STM.orient)]',repmat(0,[length(STM.orient),1])];  [repmat(0,[length(STM.orient),1]),[1:length(STM.orient)]']]
    
    if EYESEL==1,
        STM.C=[[1:length(STM.orient)]',repmat(0,[length(STM.orient),1])]; % left eye only
    elseif EYESEL==2,
        STM.C=[[repmat(0,[length(STM.orient),1]),[1:length(STM.orient)]']]; % right eye only
    elseif EYESEL==3,
        STM.C=[[[1:length(STM.orient)]',repmat(0,[length(STM.orient),1])];  [repmat(0,[length(STM.orient),1]),[1:length(STM.orient)]']];
    end
    
    ncnd = size(STM.C,1);
    
    z = 0;
    clear RANDTAB;
    for a = 1:ncnd,
        z = z+1;
        word = a; % word bit
        RANDTAB(z,:) = [word,a]; %[word,pos,ori,frqs,frqt]
    end
    
    if 0,
        % test: select single conditions
        RANDTAB=RANDTAB(1,:);
    end
    
    SAVETAB = RANDTAB;
    ntrials = z;
    
    % save relevant settings in logfile
    LOG = [];
    LOG.PASSIVEMODE = PASSIVEMODE;
    LOG.runstim      = 'rs_2eyes_orientmap';    
    [ST,I]=dbstack('-completenames');    
    if ~strcmp(ST(I).name,LOG.runstim), error('check runstim name!'); end
    LOG.runstim_code = textread(LOG.runstim, '%s', 'delimiter', '\n', 'whitespace', ''); % just in case: save copy of code runstim
    LOG.filename = filename;
    LOG.TAB      = SAVETAB;
    LOG.STM      = STM;
    LOG.TIMING   = TIMING;
    LOG.scrset        = scrset;
    
    %////YOUR STIMULATION CONTROL LOOP /////////////////////////////////
    
    bitlookup = dec2bin([1:255]); % The easy way to do the wordbit is to make an index containg all 8-bit transformations and then index into this
    
    %First flip-screen
    Screen('Flip', expWin);
    
    % Trial counter
    TZ = 0;
    
    if 0, % test stimuli
        tmpdir = 'C:\Jasper\temp\rs_2eyes_orientmap\';
        if ~isdir(tmpdir), mkdir(tmpdir); end
        % LEFT EYE
        %  0  = right to left of screen
        %  90 = bottom to top of screen
        % 180 = left to right of screen
        
        % RIGHT EYE
        %  0  = left to right
        %  90 = bottom to top
        % 180 = bottom to top
        for i=1:length(STM.orient),
            RotAngle1=STM.orient(i);
            % Select left-eye image buffer for drawing:
            Screen('SelectStereoDrawBuffer',expWin,EyeLeft);
            cur.frqs=1;
            cur.frqt=1;
            z1=0;
            for j=1:10,
                Screen('SelectStereoDrawBuffer',expWin,EyeLeft);
                xoffset = mod(z1*GAB{cur.frqs}.shiftperframe(cur.frqt),GAB{cur.frqs}.Period);
                z1=z1+1;
                srcRect=[xoffset 0 xoffset+TSIZ TSIZ];
                Screen('DrawTexture',expWin,gratingtex{cur.frqs}, srcRect, [], RotAngle1);
                DrawFormattedText(expWin,sprintf('ori1=%d,xoffset=%1.2f',RotAngle1,xoffset), 'center', 'center'); % help DrawFormattedText
                vbl = Screen('Flip', expWin);
                imageArray = Screen('GetImage',expWin);
                imwrite(imageArray,sprintf('%scnd%d_%d.bmp',tmpdir,i,j));
                pause;
            end
            pause;
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % STIMULATION CONTROL LOOP
    
    % reset all bits
    if USBCONNECT
        s.outputSingleScan(zeros([1,3+8]));
        %s.outputSingleScan(ones([1,3+8]));
    end
    
    clear MAT TIM;
    Par.ESC = false; %escape has not been pressed
    while ~Par.ESC,
        
        [rows,cols] = size(RANDTAB);
        R = ceil(rand(1).*rows);
        
        cur.word = RANDTAB(R,1);
        cur.cnd  = RANDTAB(R,2);
        
        if STM.C(cur.cnd,1)==0,
            RotAngle1 = NaN;
        else
            RotAngle1 = STM.orient(STM.C(cur.cnd,1));
        end
        
        if STM.C(cur.cnd,2)==0,
            RotAngle2 = NaN;
        else
            RotAngle2 = STM.orient(STM.C(cur.cnd,2));
        end
        
        fprintf('%3d: word = %3d, cnd = %3d, ori1=%3d,ori2=%3d\n',TZ,cur.word,cur.cnd,RotAngle1,RotAngle2);
        
        if USBCONNECT,
            %SEND WORD BIT HERE
            wb   = bitlookup(cur.word,:);
            wb   = fliplr([str2double(wb(1)) str2double(wb(2)) str2double(wb(3)) str2double(wb(4)) ...
                str2double(wb(5)) str2double(wb(6)) str2double(wb(7)) str2double(wb(8))]);
            allbits = [1 0 0, wb];
            s.outputSingleScan(allbits);
        end
        
        if waitfordigin, % wait for digital input
            while ~getvalue(dio.Line(end))
                if KbCheck
                    return
                end
            end
            fprintf('triggered\n');
        end
        
        %/////////////////////////////////////////////////////////////////////
        %START THE TRIAL
                
        %Start of trial
        TZ = TZ+1;
        CURMAT = RANDTAB(R,:);
        CURTIM = NaN([1,5]);      
        % CURTIM1 start pre-stimulus period
        % CURTIM2 last frame pre-stimulus period
        % CURTIM3 first frame stimulus period
        % CURTIM4 last frame stimulus period
        % CURTIM5 first frame target period
        CURFRM=NaN([TIMING.EVENT2_FRAMES,2]);
        
        %--------------------------------------------------------------
        %EVENT 1
        %--------
             
        %DrawFormattedText(expWin,sprintf('Event 1\nPre-Stimulus'), 'center', 'center'); % help DrawFormattedText
        if STM.use_pd,
            if (EyeLeft==EyeDiode),
                Screen('SelectStereoDrawBuffer',expWin,EyeLeft);
            else
                Screen('SelectStereoDrawBuffer',expWin,EyeRight);
            end
            Screen('FillRect',expWin,0,STM.diodepos);
        end
        vbl = Screen('Flip', expWin);
        
        CURTIM(1) = vbl; % CURTIM1 start pre-stimulus period     
        
        if ~DEMO
            if STM.use_pd,
                if (EyeLeft==EyeDiode),
                    Screen('SelectStereoDrawBuffer',expWin,EyeLeft);
                else
                    Screen('SelectStereoDrawBuffer',expWin,EyeRight);
                end
                Screen('FillRect',expWin,0,STM.diodepos);
            end
            vbl = Screen('Flip',expWin, vbl + ((TIMING.EVENT1_FRAMES-1) - 0.5) * ifi);            
            CURTIM(2) = vbl; % CURTIM2 last frame pre-stimulus period
        else
            pause(TIMING.EVENT1_TIME./1000);
        end
        
        %--------------------------------------------------------------
        %EVENT 2: stimulus on
        %--------
        
        % 1st frame        
        s1 = 1; % allspeed(cur.cnd,1);
        s2 = 1; % allspeed(cur.cnd,2);
        d1 = 1; % alldir(cur.cnd,1);
        d2 = 1; % alldir(cur.cnd,2);
        z1 = 0;
        z2 = 0;
        
        cur.frqs=1;
        cur.frqt=1;

        fixedspeed = GAB{cur.frqs}.shiftperframe(1);
        
        xoffset1 = mod(z1*GAB{cur.frqs}.shiftperframe(cur.frqt),GAB{cur.frqs}.Period);
        z1=z1+1;
        srcRect=[xoffset1 0 xoffset1+TSIZ TSIZ];
        
        % Select left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer',expWin,EyeLeft);
        if ~isnan(RotAngle1),
            Screen('DrawTexture',expWin,gratingtex{cur.frqs}, srcRect, [], RotAngle1);
        end
        if SHOWTEXT,
            DrawFormattedText(expWin,sprintf('cnd=%d,ori1=%d,ori2=%d',cur.cnd,RotAngle1,RotAngle2), 'center', 'center'); % help DrawFormattedText
        end
        
        if (EyeLeft==EyeDiode)&STM.use_pd,
            Screen('FillRect',expWin,255,STM.diodepos);
        end
              
        xoffset2 = mod(z2*GAB{cur.frqs}.shiftperframe(cur.frqt),GAB{cur.frqs}.Period);
        z2=z2+1;
        srcRect=[xoffset2 0 xoffset2+TSIZ TSIZ];
        
        % Select right-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer',expWin,EyeRight);
        if ~isnan(RotAngle2),
            Screen('DrawTexture',expWin,gratingtex{cur.frqs}, srcRect, [], RotAngle2);
        end
        if SHOWTEXT,
            %DrawFormattedText(expWin,sprintf('cnd=%d',cur.cnd), 'center', 'center'); % help DrawFormattedText
            DrawFormattedText(expWin,sprintf('cnd=%d,ori1=%d,ori2=%d',cur.cnd,RotAngle1,RotAngle2), 'center', 'center'); % help DrawFormattedText
        end
        
        if (EyeRight==EyeDiode)&STM.use_pd,
            Screen('FillRect',expWin,255,STM.diodepos);
        end
        
        vbl = Screen('Flip', expWin);
        CURTIM(3) = vbl; % CURTIM3 first frame stimulus period        
        % send stimulus onset bit
        if USBCONNECT
            allbits(2)=1;
            s.outputSingleScan(allbits);
        end
        
        for i=2:TIMING.EVENT2_FRAMES,
            if ~PASSIVEMODE
                if s.inputSingleScan,
                    xoffset1 = mod(z1*GAB{cur.frqs}.shiftperframe(cur.frqt),GAB{cur.frqs}.Period);
                    z1=z1+1;
                    xoffset2 = mod(z2*GAB{cur.frqs}.shiftperframe(cur.frqt),GAB{cur.frqs}.Period);
                    z2=z2+1;
                    motionnow=1;                    
                else
                    motionnow=0;
                end
            else
                xoffset1 = mod(z1*GAB{cur.frqs}.shiftperframe(cur.frqt),GAB{cur.frqs}.Period);
                z1=z1+1;
                xoffset2 = mod(z2*GAB{cur.frqs}.shiftperframe(cur.frqt),GAB{cur.frqs}.Period);
                z2=z2+1;
                motionnow=NaN;
            end
            srcRect=[xoffset1 0 xoffset1+TSIZ TSIZ];
            
            % Select left-eye image buffer for drawing:
            Screen('SelectStereoDrawBuffer',expWin,EyeLeft);
            if ~isnan(RotAngle1),
                Screen('DrawTexture',expWin,gratingtex{cur.frqs}, srcRect, [], RotAngle1);
            end
            if SHOWTEXT,
                %DrawFormattedText(expWin,sprintf('LFT:cnd=%d,xoffset1=%1.2f',cur.cnd,xoffset1), 'center', 'center'); % help DrawFormattedText
                DrawFormattedText(expWin,sprintf('LFT:wrd=%d,cnd=%d,xoffset1=%1.2f,ori1=%d',cur.word,cur.cnd,xoffset1,RotAngle1), 'center', 'center'); % help DrawFormattedText
            end
            
            if (EyeLeft==EyeDiode)&STM.use_pd,
                Screen('FillRect',expWin,255,STM.diodepos);
            end
            

            srcRect=[xoffset2 0 xoffset2+TSIZ TSIZ];
            
            % Select right-eye image buffer for drawing:
            Screen('SelectStereoDrawBuffer',expWin,EyeRight);
            if ~isnan(RotAngle2),
                Screen('DrawTexture',expWin,gratingtex{cur.frqs}, srcRect, [], RotAngle2);
            end
            if SHOWTEXT,
                %DrawFormattedText(expWin,sprintf('RGT:cnd=%d,xoffset2=%1.2f',cur.cnd,xoffset2), 'center', 'center'); % help DrawFormattedText
                DrawFormattedText(expWin,sprintf('RGT:cnd=%d,xoffset2=%1.2f,ori2=%d',cur.cnd,xoffset2,RotAngle2), 'center', 'center'); % help DrawFormattedText
            end
            
            if (EyeRight==EyeDiode)&STM.use_pd,
                Screen('FillRect',expWin,255,STM.diodepos);
            end
            
            % NEW: We only flip every 'TIMING.waitframes' monitor refresh intervals:
            % For this, we calculate a point in time after which Flip should flip
            % at the next possible VBL.
            % This should happen TIMING.waitframes * ifi seconds after the last flip
            % has happened (=vbl). ifi is the monitor refresh interval
            % duration. We subtract 0.5 frame durations, so we have some
            % headroom to take possible timing jitter or roundoff-errors into
            % account.
            % This is basically the old Screen('WaitBlanking', w, TIMING.waitframes)
            % as known from the old PTB...
            vbl = Screen('Flip',expWin, vbl + (TIMING.waitframes - 0.5) * ifi); 
            CURFRM(i,:)=[vbl,motionnow];
            CURTIM(4) = vbl; % CURTIM4 last frame stimulus period
        end
        
        % pause; % for testing: uncomment when doing real experiment!
        
        % turn off grating
        Screen('SelectStereoDrawBuffer',expWin,EyeLeft);
        vbl = Screen('Flip', expWin);
        if ~DEMO
            CURTIM(5) = vbl;
            % send target onset bit
            if USBCONNECT
                allbits(3)=1;
                s.outputSingleScan(allbits);
            end
        end
                    
        %remove this trial from
        %the randomisation grid
        RANDTAB(R,:) = [];
        if isempty(RANDTAB)
            RANDTAB = SAVETAB;
        end
        
        %Clear all bits
        if USBCONNECT
            s.outputSingleScan(zeros([1,3+8]));
        end
        
        %Pause for inter-trial interval
        pause(TIMING.ITI/1000);
        
        if ~DEMO,
            MAT(TZ,:)=CURMAT;
            TIM(TZ,:)=CURTIM;
            FRM(TZ,:,:)=CURFRM;
            save(filename,'MAT','TIM','LOG','FRM'); %Save on each trial for safety
        end
        
        % Abort if ESCAPE key is pressed (see edit KbDemo)
        % can also abort at any time using @ key
        [ keyIsDown, timeSecs, keyCode ] = KbCheck;
        if keyIsDown
            fprintf('"%s" typed\n', KbName(keyCode));
            if keyCode(escapeKey)
                Par.ESC=1; % break;
            end
        end
    end % while ~Par.ESC,
    
    disp('Completed')
    Par.ESC = 1;
    
    ShowCursor;
    Priority(0); % Restore normal priority scheduling in case something else was set before
    Screen('CloseAll'); %The same commands wich close onscreen and offscreen windows also close textures.
    
catch
    % This section is executed only in case an error happens in the
    % experiment code implemented between try and catch...
    ShowCursor;
    Screen('CloseAll');
    Screen('Preference', 'VisualDebuglevel', olddebuglevel);
    psychrethrow(psychlasterror); %output the error message
end
