
function rs_2eyes_retinotopy_flicker

% (15*2*10*1.3)./60
screenNumber=2;

clear scrset TIMING STM;

DEMO       = 0; % if DEMO set to 1, show stimulus, leave out saving of logfiles/writing triggers etc.
USBCONNECT = 1; % if USBCONNECT is 1, then bits sent to USBport
SHOWSTIM   = 0;
SHOWTEXT   = 0;
TOKEN      = 1; % ask user to specify token

FINEGRID = 0; % 10 degrees grid

if ~DEMO
    %FILENAME%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    n = 1;
    %Concatenation to make filename
    rootdir = 'C:\Data\AuxRec\';
    stem    = 'rs_2eyes_retinotopy';
    
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
    s.addDigitalChannel('Dev1', 'Port0/Line4', 'OutputOnly'); % stimulus bits to auxiliary computer
%     s.addDigitalChannel('Dev1', 'Port0/Line3:5', 'OutputOnly'); % stimulus bits to auxiliary computer
%     s.addDigitalChannel('Dev1', 'Port1/Line0:7', 'OutputOnly'); % word bit to auxiliary computer
%     s.addDigitalChannel('Dev1', 'Port2/Line0',   'InputOnly'); % word bit to auxiliary computer
    
    % outputs
    % 1(P0.0 AuxRec) word bit > changed to P0.3
    % 2(P0.1 AuxRec) stim bit > changed to P0.4
    % 3(P0.2 AuxRec) targ bit > changed to P0.5
    % 9:16(P1.1:P1.7,P2.0=PFI1:PFI8 AuxRec) value of word bit
    % inputs to StimComp
    % 1(P0.0 StimComp) word bit
    % 2(P0.1 StimComp) stim bit
    % 3(P0.2 StimComp) targ bit
    % 3(P0.8:P1.5 StimComp) value of word bit
%     bits.wrd = 1;
%     bits.stm = 2;
%     bits.trg = 3;
%     bits.wrdvalue = [4:11];
    %s.inputSingleScan; % first call is slowest
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
    
    % to change when luminance correction done (Adil 05/11/2018)
    STM.lumgray   = temp_gammacon_r303(0.5,'rgb2lum');
    STM.lumblack  = temp_gammacon_r303(0,'rgb2lum');
    STM.lumwhite  = STM.lumgray+(STM.lumgray-STM.lumblack);
    STM.rgbgray   = round(255*temp_gammacon_r303(STM.lumgray,'lum2rgb'));
    STM.rgbblack  = round(255*temp_gammacon_r303(STM.lumblack,'lum2rgb'));
    STM.rgbwhite  = round(255*temp_gammacon_r303(STM.lumwhite,'lum2rgb'));
    
    % initialize screen
    screens=Screen('Screens');

    % Open double-buffered onscreen window with the requested stereo mode:
    
    stereoMode=0;
    [expWin,screenRect]=Screen('OpenWindow',screenNumber,STM.rgbgray,[],[],[],stereoMode);
    
    ifi=Screen('GetFlipInterval',expWin); % Screen('GetFlipInterval?')
    
    % We choose a text size of 24 pixels - Well readable on most screens:
    Screen('TextSize', expWin, 24);
    Screen('TextColor',expWin,[255 0 0]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % general settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %photodiode settings
    STM.use_pd   = 1;   % 0 disables photodiode square
    STM.diodesz  = 100; % size of photodiode detection square in pixels
    STM.diodesz  = 120; % size of photodiode detection square in pixels
    STM.diodecol = [0 255 0]; % diode color
    
    STM.diodepos = [screenRect(1) screenRect(4)-STM.diodesz STM.diodesz screenRect(4)]; % left bottom
    %STM.diodepos = [screenRect(3)-STM.diodesz screenRect(4)-STM.diodesz screenRect(3) screenRect(4)]; % right bottom
    STM.diodepos = [screenRect(1) screenRect(2) STM.diodesz STM.diodesz]; % left top
    
%     % times in ms
%     TIMING.EVENT1_TIME = 2000; % pre-stimulus period
%     TIMING.FLICKFRQ    = 1;     % Hz;
%     TIMING.EVENT2_TIME = 4000; % stimulus on period
%     TIMING.ITI         = 0;    % inter trial interval
%     
%     
%     if FINEGRID,
%         TIMING.EVENT1_TIME = 0;    % pre-stimulus period
%         TIMING.EVENT2_TIME = 500; % stimulus on period
%         TIMING.ITI         = 0;    % inter trial interval
%     end
%     
%     TIMING.EVENT1_FRAMES = round( (TIMING.EVENT1_TIME/1000)./ifi ); % time of event 1 in frames
%     HALFCYCLE = ((1/TIMING.FLICKFRQ)/2); % period of halfcycle (seconds)
%     
%     TIMING.FLICKFRQ_FRAMES = round( HALFCYCLE./ifi ); % time of halfcycle in frames
%     NCYCLES = round( 2*(TIMING.EVENT2_TIME./1000).*TIMING.FLICKFRQ ); % requested number of half cycles 
%     TIMING.EVENT2_FRAMES = round( (TIMING.EVENT2_TIME/1000)./ifi ); % time of event 2 in frames
%     

   % times in ms
    TIMING.EVENT1_TIME = 1000; % pre-stimulus period    
    TIMING.EVENT2_TIME = 1000; % stimulus on period
    TIMING.FLICK_TIME   = 200;  % time between flicks
    TIMING.ITI         = 0;    % inter trial interval
        
    if FINEGRID,
        TIMING.EVENT1_TIME = 0;    % pre-stimulus period
        TIMING.EVENT2_TIME = 500; % stimulus on period
        TIMING.ITI         = 0;    % inter trial interval
    end
    
    TIMING.EVENT1_FRAMES = round( (TIMING.EVENT1_TIME/1000)./ifi ); % time of event 1 in frames        
    TIMING.FLICK_FRAMES = round( (TIMING.FLICK_TIME/1000)./ifi ); % time of halfcycle in frames    
    TIMING.EVENT2_FRAMES = round( (TIMING.EVENT2_TIME/1000)./ifi ); % time of event 2 in frames
    
    TIMING.waitframes = 1;
    
    % Screen parameters:
    scrset.ifi              = ifi; % refresh rate
    scrset.disp             = [screenRect(3),screenRect(4)];
    scrset.cntr             = [scrset.disp(1)/2,scrset.disp(2)/2];
    scrset.fp               = scrset.cntr;
    
    scrset.monitor_distance = 20; % distance of monitor (cm)
    scrset.monitor_width    = 47.5; % Dell P2210: monitor width (cm) 47.5 x 30 cm
    
    scrset.ppd = (( 0.5*scrset.disp(1)) / (atand((0.5*scrset.monitor_width)./scrset.monitor_distance))); % number of pixels per degree Elmain2.cpp Line 880
    % scrset.disp./scrset.ppd % 99.7982   62.3739
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %EXPERIMENT SPECIFIC CODING STARTS HERE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %-----------------------------------
    % stimulus parameters
    STM.eyediode = 0;
    STM.eye      = 0; % 0=Left Eye, 2=Right Eye % Screen('SelectStereoDrawBuffer',expWin,STM.eye);
    STM.colorseq = [STM.rgbblack,STM.rgbwhite];
    
    %-----------------------------------
    % stimulus position parameters
%     STM.Grid_xd = 15; % distance between grid points
%     STM.Grid_yd = 15;
%     STM.Grid_xc = -45+STM.Grid_xd/2:STM.Grid_xd:45;
%     STM.Grid_yc = -30+STM.Grid_yd/2:STM.Grid_yd:30;
%     STM.GridSz  = [length(STM.Grid_xc),length(STM.Grid_yc)];
%     
%     STM.Grid_xc_pix = scrset.cntr(1) + STM.Grid_xc.*scrset.ppd;
%     STM.Grid_yc_pix = scrset.cntr(2) + STM.Grid_yc.*scrset.ppd;
%     STM.Grid_xsiz = 15; % size of patch
%     STM.Grid_ysiz = 15;
%     STM.Grid_xsiz_pix = STM.Grid_xsiz.*scrset.ppd;
%     STM.Grid_ysiz_pix = STM.Grid_ysiz.*scrset.ppd;
    
% square patches
%     STM.Grid_xd = 20; % distance between grid points
%     STM.Grid_yd = 20;
%     STM.Grid_xc = -30+STM.Grid_xd/2:STM.Grid_xd:50;
%     STM.Grid_yc = -30+STM.Grid_yd/2:STM.Grid_yd:30;
%     STM.GridSz  = [length(STM.Grid_xc),length(STM.Grid_yc)];
%     
%     STM.Grid_xc_pix = scrset.cntr(1) + STM.Grid_xc.*scrset.ppd;
%     STM.Grid_yc_pix = scrset.cntr(2) + STM.Grid_yc.*scrset.ppd;
%     STM.Grid_xsiz = 20; % size of patch
%     STM.Grid_ysiz = 20;
%     STM.Grid_xsiz_pix = STM.Grid_xsiz.*scrset.ppd;
%     STM.Grid_ysiz_pix = STM.Grid_ysiz.*scrset.ppd;
%     

% Not square but filling full screen
    STM.Grid_xd = 25; % distance between grid points (in degrees, 1 degree is ~25 pixels)
    STM.Grid_yd = 20;
    STM.Grid_xc = -50+STM.Grid_xd/2:STM.Grid_xd:50;
    STM.Grid_yc = -30+STM.Grid_yd/2:STM.Grid_yd:30;
    STM.GridSz  = [length(STM.Grid_xc),length(STM.Grid_yc)];
    
    STM.Grid_xc_pix = scrset.cntr(1) + STM.Grid_xc.*scrset.ppd;
    STM.Grid_yc_pix = scrset.cntr(2) + STM.Grid_yc.*scrset.ppd;
    STM.Grid_xsiz = 25; % size of patch
    STM.Grid_ysiz = 20;
    STM.Grid_xsiz_pix = STM.Grid_xsiz.*scrset.ppd;
    STM.Grid_ysiz_pix = STM.Grid_ysiz.*scrset.ppd;
    
%         % crude mapping:
%         STM.Grid_xd = 30; % distance between grid points
%         STM.Grid_yd = 30;
%         STM.Grid_xc = -30:STM.Grid_xd:30;
%         STM.Grid_yc = -15:STM.Grid_xd:15;
%         STM.GridSz  = [length(STM.Grid_xc),length(STM.Grid_yc)];
%     
%         STM.Grid_xc_pix = scrset.cntr(1) + STM.Grid_xc.*scrset.ppd;
%         STM.Grid_yc_pix = scrset.cntr(2) + STM.Grid_yc.*scrset.ppd;
%         STM.Grid_xsiz = 30; % size of patch
%         STM.Grid_ysiz = 30;
%         STM.Grid_xsiz_pix = STM.Grid_xsiz.*scrset.ppd;
%         STM.Grid_ysiz_pix = STM.Grid_ysiz.*scrset.ppd;
%   
        
    if FINEGRID, % finer mapping
        STM.Grid_xd = 10; % distance between grid points
        STM.Grid_yd = 10;
        STM.Grid_xc = -30+STM.Grid_xd/2:STM.Grid_xd:50;
        STM.Grid_yc = -30+STM.Grid_yd/2:STM.Grid_yd:30;
        STM.GridSz  = [length(STM.Grid_xc),length(STM.Grid_yc)];
        
        STM.Grid_xc_pix = scrset.cntr(1) + STM.Grid_xc.*scrset.ppd;
        STM.Grid_yc_pix = scrset.cntr(2) + STM.Grid_yc.*scrset.ppd;
        STM.Grid_xsiz = 10; % size of patch
        STM.Grid_ysiz = 10;
        STM.Grid_xsiz_pix = STM.Grid_xsiz.*scrset.ppd;
        STM.Grid_ysiz_pix = STM.Grid_ysiz.*scrset.ppd;
    end
    
    clear posxy;pix = 1;
    for i=1:length(STM.Grid_xc_pix),
        for j=1:length(STM.Grid_yc_pix),
            posxy(pix,:) = [STM.Grid_xc_pix(i),STM.Grid_yc_pix(j)];
            pix = pix + 1;
        end
    end
    STM.posxy=posxy;
    
    STM.FLIPXEYE=1; % flip around center screen for this eye so left of screen 1 becomes right of screen 2 so that stimuli have comparable position when looking at them
    
    if 0, % test show stimuli positions
        % plot screen with stimuli
        ps = [12,12*scrset.disp(2)./scrset.disp(1)];
        brd = 1;
        %figure('Units','centimeters','Position',[2,2,ps(1)+2*brd,ps(2)+2*brd]);
        hf=figure('Units','centimeters','Position',[98 10 14 9]);
        ha=axes('Units','centimeters','Position',[brd,brd,ps(1),ps(2)]);
        patch([1,scrset.disp(1),scrset.disp(1),1],[1,1,scrset.disp(2),scrset.disp(2)],[1 1 1],'FaceColor','None','EdgeColor',[0 0 0]);
        hold on;plot(scrset.cntr(1),scrset.cntr(2),'o');
        for i=1:size(STM.posxy,1),
            patch([STM.posxy(i,1)-STM.Grid_xsiz_pix/2,STM.posxy(i,1)+STM.Grid_xsiz_pix/2,STM.posxy(i,1)+STM.Grid_xsiz_pix/2,STM.posxy(i,1)-STM.Grid_xsiz_pix/2],...
                [STM.posxy(i,2)-STM.Grid_ysiz_pix/2,STM.posxy(i,2)-STM.Grid_ysiz_pix/2,STM.posxy(i,2)+STM.Grid_ysiz_pix/2,STM.posxy(i,2)+STM.Grid_ysiz_pix/2],...
                [1 1 1],'FaceColor',[0.2 0.2 0.2],'EdgeColor',[0.8 0.8 0.8]);
            text(STM.posxy(i,1),STM.posxy(i,2),num2str(i),'HorizontalAlignment','center','VerticalAlignment','middle');
        end
        set(gca,'XLim',[1,scrset.disp(1)],'YLim',[1,scrset.disp(2)]);
        set(gca,'YDir','reverse');
    end
    
    if SHOWSTIM == 1,
        % plot screen with stimuli
        ps = [12,12*scrset.disp(2)./scrset.disp(1)];
        brd = 1;
        %figure('Units','centimeters','Position',[2,2,ps(1)+2*brd,ps(2)+2*brd]);
        hf=figure('Units','centimeters','Position',[98 10 14 9]);
        
        ha=axes('Units','centimeters','Position',[brd,brd,ps(1),ps(2)]);
        
        patch([1,scrset.disp(1),scrset.disp(1),1],[1,1,scrset.disp(2),scrset.disp(2)],[1 1 1],'FaceColor','None','EdgeColor',[0 0 0]);
        hold on;plot(scrset.cntr(1),scrset.cntr(2),'o');
        %         for i=1:size(STM.posxy,1),
        %             patch([STM.posxy(i,1)-STM.Grid_xsiz_pix/2,STM.posxy(i,1)+STM.Grid_xsiz_pix/2,STM.posxy(i,1)+STM.Grid_xsiz_pix/2,STM.posxy(i,1)-STM.Grid_xsiz_pix/2],...
        %                 [STM.posxy(i,2)-STM.Grid_ysiz_pix/2,STM.posxy(i,2)-STM.Grid_ysiz_pix/2,STM.posxy(i,2)+STM.Grid_ysiz_pix/2,STM.posxy(i,2)+STM.Grid_ysiz_pix/2],...
        %                 [1 1 1],'FaceColor',[0.2 0.2 0.2],'EdgeColor',[0.8 0.8 0.8]);
        %             text(STM.posxy(i,1),STM.posxy(i,2),num2str(i),'HorizontalAlignment','center','VerticalAlignment','middle');
        %         end
        set(gca,'XLim',[1,scrset.disp(1)],'YLim',[1,scrset.disp(2)]);
        set(gca,'YDir','reverse');
        
        %         [TestWin,TestRect]=Screen('OpenWindow',2,STM.rgbgray,[10 20 768 384]); % Screen('OpenWindow?')
        %         vbl = Screen('Flip', expWin);
    end
    
    %-----------------------------------
    % testing
    
    if 0,
        tmpdir = 'C:\temp\rs_2eyes_retinotopy_flicker\';
        if ~isdir(tmpdir), mkdir(tmpdir); end
        dbstop if error
        STM.FLIPXEYE=1;
        testcol=jet(size(STM.posxy,1));
        for STMeye=0:1,
            Screen('SelectStereoDrawBuffer',expWin,STMeye);
            for i=1:size(STM.posxy,1),
                cur.pos = i;
                patchpos = round([STM.posxy(cur.pos,1)-STM.Grid_xsiz_pix/2,STM.posxy(cur.pos,2)-STM.Grid_ysiz_pix/2,...
                    STM.posxy(cur.pos,1)+STM.Grid_xsiz_pix/2,STM.posxy(cur.pos,2)+STM.Grid_ysiz_pix/2]);
                patchcnt = [STM.posxy(i,1),STM.posxy(i,2)];
                
                if STMeye==STM.FLIPXEYE,
                    patchpos([1,3])=scrset.disp(1)-patchpos([3,1]);
                    patchcnt(1) = scrset.disp(1)-patchcnt(1);
                end
                fprintf('stm %d,[%4d %4d %4d %4d]\n',i,patchpos(1),patchpos(2),patchpos(3),patchpos(4));
                Screen('FillRect',expWin,255.*testcol(i,:),patchpos);
                DrawFormattedText(expWin,sprintf('%d',i),patchcnt(1),patchcnt(2)); % help DrawFormattedText
            end
        end
        vbl = Screen('Flip', expWin);
        imageArray = Screen('GetImage',expWin);
        imwrite(imageArray,sprintf('%scnd%d_%d.bmp',tmpdir,i,j));
    end
    
    % Stimulus randomisation
    stmeye = [1,2];
    stmeye = 1;
    stmeye = 2; % right screen
    if FINEGRID,
        stmeye = [1]; % just left eye
    end
    col  = [1]; % black and white are flickered
    pos  = [1:size(STM.posxy,1)]; % position of patch
    
    %Used for wordbit construction
    m1 = length(stmeye);
    m2 = length(col);
    m3 = length(pos);
    
    z = 0;
    clear RANDTAB;
    for a = stmeye,
        for b = col,
            for c = pos,
                z = z+1;
                word = ((a-1).*(m2*m3)) +  (b-1).*(m3) + c; % word bit
                RANDTAB(z,:) = [word,a,b,c]; %[word,stmeye,col,pos]
            end
        end
    end
    
    SAVETAB = RANDTAB;
    ntrials = z;
    
    % save relevant settings in logfile
    LOG = [];    
    LOG.runstim  = 'KCL_retinotopy_flicker';
    [ST,I]=dbstack('-completenames');    
    if ~strcmp(ST(I).name,LOG.runstim), error('check runstim name!'); end
    LOG.runstim_code = textread(LOG.runstim, '%s', 'delimiter', '\n', 'whitespace', ''); % just in case: save copy of code runstim
    LOG.filename = filename;
    LOG.TAB      = SAVETAB;
    LOG.STM      = STM;
    LOG.TIMING   = TIMING;
    LOG.scrset   = scrset;
    
    %////YOUR STIMULATION CONTROL LOOP /////////////////////////////////
    
    bitlookup = dec2bin([1:255]); % The easy way to do the wordbit is to make an index containg all 8-bit transformations and then index into this
    
    %First flip-screen
    Screen('SelectStereoDrawBuffer',expWin,STM.eye);
    Screen('Flip', expWin);
    
    % Trial counter
    TZ = 0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % STIMULATION CONTROL LOOP
    
    % reset all bits
    if USBCONNECT
        %s.outputSingleScan(zeros([1,3+8]));
        s.outputSingleScan(0);
    end
    
    clear MAT TIM;
    Par.ESC = false; %escape has not been pressed
    while ~Par.ESC,
        
        [rows,cols] = size(RANDTAB);
        R = ceil(rand(1).*rows);
        
        cur.word = RANDTAB(R,1);
        cur.eye  = RANDTAB(R,2);
        cur.col  = RANDTAB(R,3);
        cur.pos  = RANDTAB(R,4);
        
        STM.eye = cur.eye-1; % left eye = 0, right eye = 1
        
        patchpos = round([STM.posxy(cur.pos,1)-STM.Grid_xsiz_pix/2,STM.posxy(cur.pos,2)-STM.Grid_ysiz_pix/2,...
            STM.posxy(cur.pos,1)+STM.Grid_xsiz_pix/2,STM.posxy(cur.pos,2)+STM.Grid_ysiz_pix/2]);
        patchcnt = [STM.posxy(cur.pos,1),STM.posxy(cur.pos,2)];
        
        if STM.eye==STM.FLIPXEYE,
            patchpos([1,3])=scrset.disp(1)-patchpos([3,1]);
            patchcnt(1) = scrset.disp(1)-patchcnt(1);
        end
        
        fprintf('%3d: word = %3d, eye=%3d, col = %3d, pos = %3d\n',TZ,cur.word,cur.eye,cur.col,cur.pos);
        if SHOWSTIM == 1,
            figure(hf);
            axes(ha);
            try,delete(htmp1);delete(htmp2);end
            i=cur.pos;
            htmp1=patch(patchpos([1,3,3,1]),patchpos([2,2,4,4]),...
                [1 1 1],'FaceColor',repmat(STM.colorseq(cur.col),[1 3])./255,'EdgeColor',repmat(STM.colorseq(cur.col),[1 3])./255);
            htmp2=text(patchcnt(1),patchcnt(2),num2str(i),'HorizontalAlignment','center','VerticalAlignment','middle','Color',repmat(STM.colorseq(2-cur.col+1),[1 3])./255);
        end
        
%        if USBCONNECT,
%             %SEND WORD BIT HERE
%             wb   = bitlookup(cur.word,:);
%             wb   = fliplr([str2double(wb(1)) str2double(wb(2)) str2double(wb(3)) str2double(wb(4)) ...
%                 str2double(wb(5)) str2double(wb(6)) str2double(wb(7)) str2double(wb(8))]);
%             allbits = [1 0 0, wb];
%             s.outputSingleScan(allbits);
%        end
        
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
        
        %--------------------------------------------------------------
        %EVENT 1 pre-stimulus
        %--------
        
        Screen('SelectStereoDrawBuffer',expWin,STM.eye);
        if STM.use_pd,
            if (STM.eyediode~=STM.eye),
                Screen('SelectStereoDrawBuffer',expWin,STM.eyediode);
            end
            Screen('FillRect',expWin,STM.diodecol(1),STM.diodepos);
        end
        vbl = Screen('Flip', expWin);
        
        CURTIM(1) = vbl; % CURTIM1 start pre-stimulus period
        if ~DEMO, % keep track of time:
            % flip again after given time
            Screen('SelectStereoDrawBuffer',expWin,STM.eye);
            if STM.use_pd,
                if (STM.eyediode~=STM.eye),
                    Screen('SelectStereoDrawBuffer',expWin,STM.eyediode);
                end
                Screen('FillRect',expWin,STM.diodecol(1),STM.diodepos);
            end
            vbl = Screen('Flip',expWin, vbl + ((TIMING.EVENT1_FRAMES-1) - 0.5) * ifi);
            CURTIM(2) = vbl; % CURTIM2 last frame pre-stimulus period
        else
            pause(TIMING.EVENT1_TIME./1000);
        end
        
        %--------------------------------------------------------------
        %EVENT 2: stimulus on
        %--------
        if 0,
            clc
            for i=1:TIMING.EVENT2_FRAMES,
                fprintf('frm%d:%1.2d\n',i,mod(i-1,TIMING.FLICK_FRAMES));
            end
        end
        
        cur.col = 1; % start at black (will be switched to white in first frame)
        for i=1:TIMING.EVENT2_FRAMES,       
            if mod(i-1,TIMING.FLICK_FRAMES)==0, % switch color patch
                cur.col = 2-cur.col+1;
            end
            Screen('SelectStereoDrawBuffer',expWin,STM.eye);
            if SHOWTEXT,
                DrawFormattedText(expWin,sprintf('word=%d,eye=%d,col=%d,pos=%d\n',cur.word,cur.eye,cur.col,cur.pos), 'center', 'center');
            end            
            Screen('FillRect',expWin,STM.colorseq(cur.col),patchpos);
            if STM.use_pd,
                if (STM.eyediode~=STM.eye),
                    Screen('SelectStereoDrawBuffer',expWin,STM.eyediode);
                end
                Screen('FillRect',expWin,STM.diodecol(2),STM.diodepos);
            end
            vbl = Screen('Flip', expWin);
            if i==1,                
                CURTIM(3) = vbl; % CURTIM3 first frame stimulus period
                % send stimulus onset bit
                if USBCONNECT
                    allbits=1;
                    s.outputSingleScan(allbits);
                end
            elseif i==length(TIMING.EVENT2_FRAMES),                                             
                CURTIM(4) = vbl; % CURTIM4 last frame stimulus period            
            end
        end %  for i=1:length(TIMING.EVENT2_FRAMES),
  
        % turn off patch
        Screen('SelectStereoDrawBuffer',expWin,STM.eye);
        if SHOWTEXT,
            DrawFormattedText(expWin,sprintf('word=%d,eye=%d,col=%d,pos=%d\n',cur.word,cur.eye,cur.col,cur.pos), 'center', 'center');
        end
        % Screen('FillRect',expWin,STM.colorseq(cur.col),patchpos);
        vbl = Screen('Flip', expWin);
        if ~DEMO
            CURTIM(5) = vbl; % CURTIM5 first frame target period
            % send target onset bit
            if USBCONNECT
                allbits=1;
                s.outputSingleScan(allbits);
            end
        end
        
        %pause; % for testing: uncomment when doing real experiment!
        
        %remove this trial from
        %the randomisation grid
        RANDTAB(R,:) = [];
        if isempty(RANDTAB)
            RANDTAB = SAVETAB;
        end
        
        %Clear all bits
        if USBCONNECT
            %s.outputSingleScan(zeros([1,3+8]));
            s.outputSingleScan(0);
        end
        
        %Pause for inter-trial interval
        pause(TIMING.ITI/1000);
        
        if ~DEMO,
            MAT(TZ,:)=CURMAT;
            TIM(TZ,:)=CURTIM;
            save(filename,'MAT','TIM','LOG') %Save on each trial for safety
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
