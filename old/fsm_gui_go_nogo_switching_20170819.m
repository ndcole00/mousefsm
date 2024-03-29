% FSMteensy 
% Adil Khan, Basel 2016

% 20160912 switches from go nogo task to odr discrim
% 20161102 used binary format for digiout

function fsm_gui_go_nogo_switching()

close all
clearvars -global fsm
global fsm

% Initialise
fsm.comport = num2str(GetComPort ('Teensy USB Serial'));
fsm.savedir = 'D:\Adil\FSM\';
fsm.token = 'MS99_B1';
fsm.fname = '';
fsm.spdrnghigh = 220;
fsm.spdrnglow = 10;
fsm.spdavgbin = .05;
fsm.spdylim = 120;
fsm.spdxrng = 5;
% fsm.Tcuedelay = .1;
% fsm.Tcue = 0;
fsm.Tspeedmaintainmin = 2.5;
fsm.Tspeedmaintainmeanadd = .2;
fsm.Tstimdurationmin = 1.5;
fsm.Tstimdurationmeanadd = .2;
% fsm.Tminorientationview = .25;
fsm.Trewdavailable = 1;
fsm.Titi = .1;
fsm.contrast = 1;
% fsm.orientationchange = [];
% fsm.orientationchangelist = '45,12';
fsm.orientation = [];
fsm.spatialfreq = .1;
fsm.temporalfreq = 2;
% fsm.attentionlocationlist = {'left','right','front','back'};
% fsm.attentionlocation = {};
% fsm.orientationchangelocation = {};
fsm.stimtype = [];
fsm.prewd = .5;
% fsm.ntrialsperblock = 900;
fsm.rewd = .08;
fsm.trialnum = 0;
fsm.triallog = {};
fsm.lickthreshold = 1.5;
% fsm.RT = [];
% fsm.FAT = {};
% fsm.refractoryLT = {};
% fsm.changelist = {};% each change in ori is either refractory lick, miss or correct
% fsm.changelist_ori = [];% orientation change of each change
fsm.blockchangetrial = 1;
fsm.grayscreen = 0;
fsm.extrawait = .5;
fsm.state = 0;
fsm.ntrialswithcue = 100;
fsm.iscuetrial = 0;
fsm.punishT = 0.5;
fsm.instspeed = 0;
fsm.blocktype = [];
fsm.vbl = 0;
fsm.pirrel = 0;
fsm.Tirrelgrating = 1.5;
fsm.Tirreldelay = 1;
fsm.odour = [];
fsm.plaser = 0;
fsm.stim1ori = 180-10;
fsm.stim2ori = 180+10;
%--------------------------------------------------------------------------
% make GUI

fsm.handles.f = figure('Units','normalized','Position',[0.1 0.1 0.7 0.7],...
    'Toolbar','figure');
set(fsm.handles.f,'CloseRequestFcn',@my_closefcn);

% plot image
fsm.handles.ax(1)=axes('Parent',fsm.handles.f,'Units','normalized','Position',[0.65 0.55 0.33 0.4],'xticklabel',[]);
title('Speed (cm/s)');ylim([-10 fsm.spdylim]);
Xrng_speed_plot

fsm.handles.ax(2)=axes('Parent',fsm.handles.f,'Units','normalized','Position',[0.65 0.05 0.33 0.4]);
title('Reaction Times (s)');
hold(fsm.handles.ax(2),'on');

fsm.handles.ax(3)=axes('Parent',fsm.handles.f,'Units','normalized','Position',[0.35 .03 0.27 0.24]);
%try imshow ('M:\Adil\FSM\contrast change task schematic.jpg');end
hold(fsm.handles.ax(3),'on');

% savedir
fsm.handles.savedir = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.9 0.2 0.04],...
    'String',['savedir: ' fsm.savedir],'FontSize',10);
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.23 0.9 0.1 0.04],...
    'String','Change','Callback', @call_change_savedir);

% token
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.85 0.2 0.04],...
    'String','Token','FontSize',10);
fsm.handles.token = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.85 0.1 0.04],...
    'String',fsm.token,'FontSize',10);

% spd rng high
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.8 0.2 0.04],...
    'String','Speed range high','FontSize',10);
fsm.handles.spdrnghigh = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.8 0.1 0.04],...
    'String',fsm.spdrnghigh,'FontSize',10,'Callback', @call_change_spdrnghigh);

% spd rng low
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.75 0.2 0.04],...
    'String','Speed range low','FontSize',10);
fsm.handles.spdrnglow = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.75 0.1 0.04],...
    'String',fsm.spdrnglow,'FontSize',10,'Callback', @call_change_spdrnglow);

% spd ylim
fsm.handles.spdylim = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.63 0.96 0.02 0.02],...
    'String',fsm.spdylim,'FontSize',10,'Callback', @call_change_spdylim);

% spd xrange
fsm.handles.spdxrng = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.97 0.52 0.02 0.02],...
    'String',fsm.spdxrng,'FontSize',10,'Callback', @call_change_spdxrng);

% t irrel grating
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.7 0.2 0.04],...
    'String','T irrel grating','FontSize',10);
fsm.handles.Tirrelgrating = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.7 0.1 0.04],...
    'String',fsm.Tirrelgrating,'FontSize',10);

% T delay after irrel grating
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.65 0.2 0.04],...
    'String','T irrel delay','FontSize',10);
fsm.handles.Tirreldelay = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.65 0.1 0.04],...
    'String',fsm.Tirreldelay,'FontSize',10);

% T speed maintain min
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.6 0.2 0.04],...
    'String','T speed maintain min','FontSize',10);
fsm.handles.Tspeedmaintainmin = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.6 0.1 0.04],...
    'String',fsm.Tspeedmaintainmin,'FontSize',10);

% T speed maintain mean additional
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.55 0.2 0.04],...
    'String','T speed maintain mean added','FontSize',10);
fsm.handles.Tspeedmaintainmeanadd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.55 0.1 0.04],...
    'String',fsm.Tspeedmaintainmeanadd,'FontSize',10);
%
% T Stim duration min
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.5 0.2 0.04],...
    'String','T stim duration min','FontSize',10);
fsm.handles.Tstimdurationmin = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.5 0.1 0.04],...
    'String',fsm.Tstimdurationmin,'FontSize',10);
%
% T stim duration mean additional
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.45 0.2 0.04],...
    'String','T stim duration mean added','FontSize',10);
fsm.handles.Tstimdurationmeanadd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.45 0.1 0.04],...
    'String',fsm.Tstimdurationmeanadd,'FontSize',10);
%
% T reward available
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.4 0.2 0.04],...
    'String','T reward available','FontSize',10);
fsm.handles.Trewdavailable = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.4 0.1 0.04],...
    'String',fsm.Trewdavailable,'FontSize',10);

% inter trial interval
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.35 0.2 0.04],...
    'String','Inter trial interval','FontSize',10);
fsm.handles.Titi = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.35 0.1 0.04],...
    'String',fsm.Titi,'FontSize',10);

% Speed averaging bin
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.3 0.2 0.04],...
    'String','Speed averaging bin','FontSize',10);
fsm.handles.spdavgbin = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.3 0.1 0.04],...
    'String',fsm.spdavgbin,'FontSize',10);
%
% Prob reward trials
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.25 0.2 0.04],...
    'String','Prob. reward trials','FontSize',10);
fsm.handles.prewd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.25 0.1 0.04],...
    'String',fsm.prewd,'FontSize',10);

% Rewd valve duration
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.2 0.2 0.04],...
    'String','Reward valve duration','FontSize',10);
fsm.handles.rewd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.2 0.1 0.04],...
    'String',fsm.rewd,'FontSize',10);

% Starting Contrast
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.15 0.2 0.04],...
    'String','Starting contrast','FontSize',10);
fsm.handles.contrast = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.15 0.1 0.04],...
    'String',fsm.contrast,'FontSize',10);

% Prob irrel gratings %
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.1 0.2 0.04],...
    'String','Prob Irrelevant gratings','FontSize',10);
fsm.handles.pirrel = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.1 0.1 0.04],...
    'String',fsm.pirrel,'FontSize',10);

% Spatial freq
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.05 0.2 0.04],...
    'String','Spatial frequency','FontSize',10);
fsm.handles.spatialfreq = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.05 0.1 0.04],...
    'String',fsm.spatialfreq,'FontSize',10);

% Temporal freq
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.005 0.2 0.04],...
    'String','Temporal frequency','FontSize',10);
fsm.handles.temporalfreq = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.005 0.1 0.04],...
    'String',fsm.temporalfreq,'FontSize',10);

% Prob laser 
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.65 0.17 0.04],...
    'String','Prob laser','FontSize',10);
fsm.handles.plaser = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.53 0.65 0.08 0.04],...
    'String',fsm.plaser,'FontSize',10);

% Lick threshold
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.6 0.17 0.04],...
    'String','Lick Threshold','FontSize',10);
fsm.handles.lickthreshold = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.53 0.6 0.08 0.04],...
    'String',fsm.lickthreshold,'FontSize',10);
%
% Extra wait time
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.55 0.17 0.04],...
    'String','Extra wait time','FontSize',10);
fsm.handles.Textrawait = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.53 0.55 0.08 0.04],...
    'String',fsm.extrawait,'FontSize',10);
%
% % Ntrials with cue
% uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
%     'Position', [0.42 0.5 0.1 0.04],...%[0.35 0.5 0.08 0.04]
%     'String','Ntrials with cue','FontSize',10);
% fsm.handles.ntrialswithcue = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
%     'Position', [0.53 0.5 0.08 0.04],...
%     'String',fsm.ntrialswithcue,'FontSize',10);
%
% % Min orientation view time
% uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
%     'Position', [0.35 0.45 0.17 0.04],...
%     'String','Min orientation view T','FontSize',10);
% fsm.handles.Tminorientationview = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
%     'Position', [0.53 0.45 0.08 0.04],...
%     'String',fsm.Tminorientationview,'FontSize',10);
%
% % Type of session: left/right OR front/back
% fsm.handles.lrORfb = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','popupmenu',...
%     'Position', [0.35 0.40 0.13 0.04],'String',{'Left/Right','Front/Back'},...
%     'Value',1,'FontSize',10);
%
% Vis or odr block
fsm.handles.blocktype = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','popupmenu',...
    'Position', [0.49 0.40 0.12 0.04],'String',{'Visual','Odour'},...
    'Value',1,'FontSize',10);
%
% % Both sides Ori change?
% fsm.handles.bothsides = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','checkbox',...
%     'Position', [0.35 0.25 0.12 0.04],'String','Both sides change?',...
%     'Value',1,'FontSize',10);
%
% Punish time
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.45 0.25 0.1 0.04],...
    'String','Punish T','FontSize',10);
fsm.handles.punishT = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.56 0.25 0.05 0.04],...
    'String',fsm.punishT,'FontSize',10);

%%% Indicators %%%

% Filename
fsm.handles.fname = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.9 0.26 0.04],...
    'String',['Filename: ' fsm.fname],'FontSize',10,'HorizontalAlignment','left');

% Trial number
fsm.handles.trialnum = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.85 0.26 0.04],...
    'String',['Trial Number: ' num2str(fsm.trialnum)],'FontSize',10,'HorizontalAlignment','left');

% Odour
fsm.handles.odour = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.8 0.26 0.04],...
    'String',['Odour: '],'FontSize',10,'HorizontalAlignment','left');

% Auto reward
fsm.handles.autorewd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','checkbox',...
    'Position', [0.35 0.75 0.26 0.04],'String','Auto Reward?',...
    'Value',1,'FontSize',10);

% Grating orientation
fsm.handles.orientation = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.7 0.26 0.04],...
    'String',['Orientation: ' num2str(fsm.orientation)],'FontSize',10,'HorizontalAlignment','left');

% State
fsm.handles.state = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.5 0.06 0.04],...
    'String',['State: ' num2str(fsm.state)],'FontSize',10,'HorizontalAlignment','left');

%%%%% Buttons%%%%
% Start button
fsm.handles.start = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.35 0.3 0.13 0.10],...
    'String','Start','BackgroundColor', 'green','Callback', @call_start);

% Stop button
fsm.handles.stop = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.49 0.3 0.12 0.10],...
    'String','Stop','BackgroundColor', 'red','enable','off','Callback', @call_stop);

%--------------------------------------------------------------------------
% End make GUI


% start serial port
fsm.ard=serial(fsm.comport,'BaudRate',9600); % create serial communication object on port COM7
set(fsm.ard,'Timeout',.01);
fopen(fsm.ard); % initiate arduino communication
fprintf('serial port opened\n')

% initiate the stim machine;
stim_machine_init_go_nogo_switching
figure(fsm.handles.f)

% clear the buffer
while fsm.ard.BytesAvailable
    dump = fscanf(fsm.ard,'%s');
end

function call_start(src,eventdata)
global fsm
DateString = datestr(now,'yyyymmdd_HHMMSS');
fsm.fname = fullfile(fsm.savedir,[get(fsm.handles.token,'string') '_' DateString]);
set(fsm.handles.fname,'String',fsm.fname)
set(fsm.handles.start,'enable','off')
set(fsm.handles.stop,'enable','on')
cla(fsm.handles.ax(2));
cla(fsm.handles.ax(3));
drawnow;pause(0.00000001)

make_state_matrix


function make_state_matrix
%try
global fsm
keeprunning = 1;fsm.stop = 0;
while keeprunning
    
    choose_stim % decide which stimlus to give
    
    igT  = str2num(get(fsm.handles.Tirrelgrating,'string'));
    iwT  = str2num(get(fsm.handles.Tirreldelay,'string')) + exprnd(.2);
    spdT = str2num(get(fsm.handles.Tspeedmaintainmin,'string')) + exprnd(str2num(get(fsm.handles.Tspeedmaintainmeanadd,'string')));
    stmT = str2num(get(fsm.handles.Tstimdurationmin,'string')) + rand*str2num(get(fsm.handles.Tstimdurationmeanadd,'string'));
    %     %if stimT>5;stimT=rand*5;end
    waitT = str2num(get(fsm.handles.Trewdavailable,'string'));
    rewT  = str2num(get(fsm.handles.rewd,'string'));
    iti   = str2num(get(fsm.handles.Titi,'string'));
    extraT= str2num(get(fsm.handles.Textrawait,'string'));
    %     mcvT  = str2num(get(fsm.handles.Tminorientationview,'string'));
    pT    = str2num(get(fsm.handles.punishT,'string'));
    fsm.contrast = str2num(get(fsm.handles.contrast,'string'));
    pL    = str2num(get(fsm.handles.plaser,'string'));
    %     fsm.orientationchange = str2num(get(fsm.handles.orientationchange,'String'));
    %     if ~fsm.iscuetrial ; cueT = 0; end
    %     fsm.difflist = str2num(get(fsm.handles.orientationchangelist,'String'));
    
    
    % digiOut mapping
    R   =  2^0; %teensy pin 2, reward 
    Vis1 = 2^1; %teensy pin 3, visual stim 1 rewarded
    Vis2 = 2^2; %teensy pin 4, visual stim 2 non rewarded
    Odr1 = 2^3; %teensy pin 5, odour1 rewarded
    Odr2 = 2^4; %teensy pin 6, odour2 non rewarded
    S    = 2^5; %teensy pin 7, generic stim on signal
    Bln  = 2^6; %teensy pin 8, blank odour
    Irr  = 2^7; %teensy pin 9, Irrelevant vis, should be on with the vis bit
    L   = 2^8; %teensy pin 10, trigger for optogenetic laser
    
    Rew = R;
    iStim = 0;
    
    switch fsm.stimtype(fsm.trialnum+1)% 1 = vis rewarded, 2 = vis not rewarded, 3 = Odr rewarded, 4 = odr not rewarded
        case 1 % vis rewarded
            IR = 3;  % no irrel grating
            Stim = Vis1+Bln;% rewarded grating (+45 degrees)
            lok1 = 5;% rewd
            % auto reward or not
            if get(fsm.handles.autorewd ,'Value')==1
                AR = 7;
            else
                AR = 9;
            end
            Rew = Rew+Vis1;
        case 2 % vis non rewarded
            IR = 3;  %
            Stim = Vis2+Bln;% non rewarded grating (-45 degrees)
            lok1 = 8;% punish
            AR = 9; % no auto reward
        case 3 % odour rewarded
            Stim = Odr1;% Odr1
            lok1 = 5;% rewd
            if fsm.irrelgrating(fsm.trialnum+1) == 1;
                IR = 10;  %Irrel grating on
                if fsm.orientation(fsm.trialnum+1) == fsm.stim1ori; 
                    iStim = Vis1+Irr+Bln;% +45 degrees
                else
                    iStim = Vis2+Irr+Bln;% -45 degrees
                end
            else IR = 3; % no irrel grating
            end
            
            % auto reward or not
            if get(fsm.handles.autorewd ,'Value')==1
                AR = 7;
            else
                AR = 9;
            end
            Rew = Rew+Odr1;
        case 4 % odour non rewarded
            Stim = Odr2;% Odr2
            lok1 = 8;% punish
            if fsm.irrelgrating(fsm.trialnum+1) == 1;
                IR = 10;  %Irrel grating on
                if fsm.orientation(fsm.trialnum+1) == fsm.stim1ori; 
                    iStim = Vis1+Irr+Bln;% +45 degrees
                else
                    iStim = Vis2+Irr+Bln;% -45 degrees
                end
            else IR = 3; % no irrel grating
            end 
            AR = 9; % no auto reward
            
    end

    Stim = Stim + S; % Generic stim on signal added
    
    if rand < pL % laser trial
        LR = 12;
        Stim = Stim + L;
        Rew = Rew + L;
    else
        LR = IR;
    end
    Lon = L;
   
    stm = [... % remember zero indexing; units are seconds, multiplied later to ms
 
%  spd in   spd out     lick    Tup       Timer   digiOut
    0           0        0       1         0.01     Bln             ;...% state 0 init
    2           1        1       1         100      Bln             ;...% state 1 wait for speed in
    2           1        2       LR        spdT     Bln             ;...% state 2 maintain speed
    3           3        3       4         stmT     Stim            ;...% state 3 Stim on, refractory period
    4           4        lok1    AR        waitT    Stim            ;...% state 4 Stim on, reward zone, wait for lick
    5           5        5       6         rewT     Rew             ;...% state 5 Stim on, reward on
    6           6        6       9         extraT   Stim            ;...% state 6 Stim on, extra view
    7           7        7       6         rewT     Rew             ;...% state 7 auto reward
    8           8        8       4         pT       Stim            ;...% state 8 punish time
    9           9        9       99        iti      Bln             ;...% state 9 ITI
    10          10       10      11        igT      iStim           ;...% state 10 irrel grating
    11          11       11      3         iwT      Bln             ;...% state 11 delay after irrel grating
    12          12       12      IR        .1       Lon             ;...% state 12 laser on pre stim        
    
    ];

stm (:,5) = round(stm(:,5)*1000); % sec to ms
rcvd = '';
% send an 'A' and receive a 'B'
while ~strcmp(rcvd,'B');
    fprintf(fsm.ard,'%s','A');
    fprintf('Handshake: A');
    rcvd = fscanf(fsm.ard,'%s');
    fprintf('%s',rcvd);
end

% send [nRows nCols]
[row, col] = size(stm);
fprintf(fsm.ard,'%s\n',num2str([row col]));

% send speed averaging bin size
spdbin = str2num(get(fsm.handles.spdavgbin,'string'))*1000;
fprintf(fsm.ard,'%s\n',num2str(spdbin));

% send upper and lower limit for speed range
fprintf(fsm.ard,'%s\n',num2str(fsm.spdrnghigh));
fprintf(fsm.ard,'%s\n',num2str(fsm.spdrnglow));

% send lick threshold; 3.3V is 1024
threshold = round((1024/3.3)*str2num(get(fsm.handles.lickthreshold,'string')));
fprintf(fsm.ard,'%s',num2str(threshold));


% wait for signal that its been received
rcvd = '';
while ~strcmp(rcvd,'C');
    rcvd = fscanf(fsm.ard,'%s');
    fprintf('%s',rcvd);
end

% send stm row by row
for r = 1:row
    if r < row
        fprintf(fsm.ard,'%s\n',num2str(stm(r,:)));
    else
        fprintf(fsm.ard,'%s',num2str(stm(r,:)));
    end
end


rcvd = fscanf(fsm.ard,'%s');
fprintf('%s\n',rcvd);

% send signal to end
fprintf(fsm.ard,'%s\n','>');

rcvd = fscanf(fsm.ard,'%s');
fprintf('Received %s\n',rcvd);
switch rcvd
    case 'Error1'
        % start again
    case 'startingFSM'
        fsm.trialnum = fsm.trialnum + 1;
        set(fsm.handles.trialnum,'String',['Trial Number: ' num2str(fsm.trialnum)])
        fprintf('Trial number %d\n',fsm.trialnum);
        trialend = 0;
        while trialend == 0
            % check stop button
            if fsm.stop == 1
                keeprunning = 0;
                break
            end
            % check for stimulus change
            stim_machine_go_nogo_switching
            % check for end of trial
            if fsm.ard.BytesAvailable
                rcvd2 = fscanf(fsm.ard,'%s');%if rcvd2=='0';keyboard;end
                if rcvd2 == 'E';
                    trialend = 1;
                    % read trial log
                    while ~fsm.ard.BytesAvailable;end
                    stopsignal = '';triallog = '';
                    while ~strcmp(stopsignal,'d')% from 'End'
                        partialtriallog = fscanf(fsm.ard,'%s');
                        triallog = strcat(triallog,partialtriallog);
                        stopsignal = partialtriallog(end);
                    end
                    fsm.triallog{fsm.trialnum} = triallog;
                    fprintf('%s\n',fsm.triallog{fsm.trialnum});
                    %                         [fsm.RT(fsm.trialnum), fsm.FAT{fsm.trialnum}, fsm.refractoryLT{fsm.trialnum},changelist] = findrectiontime(fsm.triallog{fsm.trialnum});
                    %                         updateRTplot
                    %                         fsm.changelist = [fsm.changelist changelist];
                    %                         fsm.changelist_ori = [fsm.changelist_ori repmat(fsm.orientationchange(fsm.trialnum),1,length(changelist))];
                elseif rcvd2 == 'S'; % its sending the state
                    while ~fsm.ard.BytesAvailable;end
                    fsm.state = str2num(fscanf(fsm.ard,'%s'));
                    set(fsm.handles.state,'String',['State: ' num2str(fsm.state)]);
                    
                else % else its sending the speed
                    olddat = get(fsm.handles.spdplot,'ydata');
                    newdat = cat(2,olddat(2:end),str2num(rcvd2));
                    set(fsm.handles.spdplot,'ydata',newdat);
                    set(fsm.handles.ax(1),'ylim',[-10 fsm.spdylim]);
                    drawnow
                    fsm.instspeed = str2num(rcvd2);
                    
                end
                
            end
            
            drawnow
        end
end

end

% catch
%     save([fsm.fname '-autosave'],'fsm');
%     fprintf('crash\n')

%end

fprintf('make state matrix ended\n')

function call_stop(src,eventdata)
global fsm
fsm.stop = 1;
set(fsm.handles.start,'enable','on')
fprintf(fsm.ard,'%s\n','X');
fprintf('FSM stopped\n')
% read trial log
if ~isempty(fsm.triallog) % if its the first time you click stop
    tic;while ~fsm.ard.BytesAvailable;if toc>2;break;end;end % wait for data with 2s timeout
try
    stopsignal = '';triallog = '';
    while ~strcmp(stopsignal,'d')% from 'stopped'
        partialtriallog = fscanf(fsm.ard,'%s');
        triallog = strcat(triallog,partialtriallog);
        stopsignal = partialtriallog(end);
    end
    fsm.triallog{fsm.trialnum} = triallog;
end
    % save fsm
    save(fsm.fname,'fsm');
    fprintf('Logfile saved\n')

    
end
% reset
fsm.trialnum = 0;
fsm.triallog = {};
% fsm.attentionlocation = {};
% fsm.orientationchangelocation = {};
fsm.orientation = [];
% fsm.orientationchange = [];
% fsm.RT = [];
% fsm.FAT = {};
% fsm.refractoryLT = {};
% fsm.blockchangetrial = 1;
% fsm.changelist = {};
% fsm.changelist_ori = [];
fsm.blocktype = [];
fsm.stimtype = [];
fsm.odour = [];



function my_closefcn(src,eventdata)
global fsm
%try call_stop;
%catch; fprintf('Did not stop and save cleanly\n');end
%Screen('Preference', 'SkipSyncTests', fsm.oldSyncLevel);
try Screen('CloseAll');
catch; fprintf('Did not stop PTB cleanly\n');end
try fclose(fsm.ard); fprintf('serial port closed\n')% end communication with arduino
catch; fprintf('Did not stop teensy cleanly, should reboot\n');end

delete(gcf);

function call_change_savedir(src,eventdata)
global fsm
folder_name = uigetdir;
fsm.savedir = folder_name;
set(fsm.handles.savedir, 'string',fsm.savedir);

function Xrng_speed_plot
global fsm
fsm.npointsX = round(fsm.spdxrng/fsm.spdavgbin);
fsm.handles.spdplot = plot(fsm.handles.ax(1),1:fsm.npointsX,ones(fsm.npointsX,1),'k','linewidth',2);
fsm.handles.spdRngHiLine = line([0 fsm.npointsX],[fsm.spdrnghigh fsm.spdrnghigh],'Linestyle','--','Linewidth',2,'Color','k','Parent',fsm.handles.ax(1));
fsm.handles.spdRngLoLine = line([0 fsm.npointsX],[fsm.spdrnglow fsm.spdrnglow],'Linestyle','--','Linewidth',2,'Color','k','Parent',fsm.handles.ax(1));

set(fsm.handles.ax(1),'xticklabel',[],'ylim',[-10,fsm.spdylim],'xlim',[0,fsm.npointsX])

function call_change_spdrnghigh(src,eventdata)
global fsm
fsm.spdrnghigh = str2num(get(fsm.handles.spdrnghigh,'string'));
set(fsm.handles.spdRngHiLine,'ydata',[fsm.spdrnghigh;fsm.spdrnghigh]);
%ylim([-10 fsm.spdylim]);

function call_change_spdrnglow(src,eventdata)
global fsm
fsm.spdrnglow = str2num(get(fsm.handles.spdrnglow,'string'));
set(fsm.handles.spdRngLoLine,'ydata',[fsm.spdrnglow;fsm.spdrnglow]);
%ylim([-10 fsm.spdylim]);

function call_change_spdylim(src,eventdata)
global fsm
fsm.spdylim = str2num(get(fsm.handles.spdylim,'string'));
set(fsm.handles.ax(1),'ylim',[-10 fsm.spdylim]);

function call_change_spdxrng(src,eventdata)
global fsm
fsm.spdxrng = str2num(get(fsm.handles.spdxrng,'string'));
Xrng_speed_plot

function [RT,FAT,refractoryLT,changelist] = findrectiontime(triallog)
% orientation change 5 to 10, lick 6 to 7
ct1 = strfind(triallog, '_5to10');
ct2 = strfind(triallog(1:ct1(end)-1),'_');
ct = str2num(triallog(ct2(end)+1:ct1(end)-1));

lt1 = strfind(triallog, '_6to7');
if ~isempty(lt1)
    lt2 = strfind(triallog(1:lt1(end)-1),'_');
    lt = str2num(triallog(lt2(end)+1:lt1(end)-1));
    RT = (lt-ct)/1000;
else
    RT = NaN;
end

%False Alarm Time
% stim on 4 to 5, lick 5 to lok2(11 or 1)
lstring = '_5to11';
lt1 = strfind(triallog, lstring);
FAT = zeros(length(lt1),1);
for f = 1:length(lt1)
    lt2 = strfind(triallog(1:lt1(f)-1),'_');
    lt = str2num(triallog(lt2(end)+1:lt1(f)-1));% early lick time
    
    st1 = strfind(triallog(1:lt1(f)-1), '_4to5');
    st2 = strfind(triallog(1:st1(end)-1),'_');
    st = str2num(triallog(st2(end)+1:st1(end)-1));
    FAT(f) = (lt-st)/1000;
end
if isempty(FAT); FAT = NaN;end

%refractory lick Time
% stim on 4 to 5, lick 10 to lok3 (11 or 1)
lstring = '_10to1';
lt1 = strfind(triallog, lstring);
refractoryLT = zeros(length(lt1),1);
for f = 1:length(lt1)
    lt2 = strfind(triallog(1:lt1(f)-1),'_');
    lt = str2num(triallog(lt2(end)+1:lt1(f)-1));% early lick time
    
    st1 = strfind(triallog(1:lt1(f)-1), '_4to5');
    st2 = strfind(triallog(1:st1(end)-1),'_');
    st = str2num(triallog(st2(end)+1:st1(end)-1));
    refractoryLT(f) = (lt-st)/1000;
end
if isempty(refractoryLT); refractoryLT = NaN;end
changelist = repmat({'refractorylick'},1,length(lt1));

if isnan(RT);
    changelist = [changelist 'miss'];
else
    changelist = [changelist 'correct'];
end


function updateRTplot
global fsm
if isnan(fsm.RT(end)); RT = str2num(get(fsm.handles.Trewdavailable,'string')); else RT = fsm.RT(end);end
%FAT = fsm.FAT(end);
%if ~isfield(fsm.handles,'RTplot')% if first call
%   fsm.handles.RTplot = plot(fsm.handles.ax(2),1,RT,'k.');
%   set(fsm.handles.ax(2),'ylim',[0 1]);
%else

curr = find(fsm.difflist==fsm.orientationchange(fsm.trialnum));
if ~isempty (curr)% put this bec was crashing here
    mrkr = '.';
    switch curr
        case 1
            cmrkr = 'b';
        case 2
            cmrkr = 'r';
        case 3
            cmrkr = 'k';
        case 4
            cmrkr = 'c';
        otherwise
            cmrkr = 'g';
    end
    
    
    if isnan(fsm.RT(end)); % miss
        mrkr = '^';
    end
    % reaction times
    plot(fsm.handles.ax(2),fsm.trialnum,RT,'color',cmrkr,'marker',mrkr);
    set(fsm.handles.ax(2),'ylim',[0 str2num(get(fsm.handles.Trewdavailable,'string'))]);
    c = jet(10);
    % false alarms
    if ~isnan(fsm.FAT{end})
        mrkr = '.';
        for f = 1:length(fsm.FAT{end})
            coll = c(min([f 10]),:);
            plot(fsm.handles.ax(3),fsm.trialnum,fsm.FAT{end}(f),'color',coll,'marker',mrkr);
        end
        
    end
    % refractory period licks
    if ~isnan(fsm.refractoryLT{end})
        mrkr = '*';
        plot(fsm.handles.ax(3),fsm.trialnum,fsm.refractoryLT{end},'color',cmrkr,'marker',mrkr,'markersize',.8);
    end
    
    if any(isnan(fsm.FAT{end})) && any(isnan(fsm.refractoryLT{end}))
        plot(fsm.handles.ax(3),fsm.trialnum,0,'go');
    end
end

function choose_stim
global fsm

% Check which block, vis or odr
blocktype = get(fsm.handles.blocktype,'Value');

switch blocktype
    case 1 % visual block
        
        % choose rewarded or non rewarded stim
        if rand < str2num(get(fsm.handles.prewd,'String')) % if rewarded trial
            fsm.stimtype(fsm.trialnum+1) = 1; % rewarded vis
            fsm.orientation(fsm.trialnum+1) = fsm.stim1ori;
        else
            fsm.stimtype(fsm.trialnum+1) = 2; % non rewarded vis
            fsm.orientation(fsm.trialnum+1) = fsm.stim2ori;
        end
        fsm.odour(fsm.trialnum+1) = NaN;
        set(fsm.handles.orientation, 'String',['Orientation: ' num2str(fsm.orientation(fsm.trialnum+1))]);
        set(fsm.handles.odour, 'String',['Odour: ']);
    case 2 % odour block
        if rand < str2num(get(fsm.handles.prewd,'String')) % if rewarded trial
            fsm.stimtype(fsm.trialnum+1) = 3; % rewarded odr
            fsm.odour(fsm.trialnum+1) = 1;
        else
            fsm.stimtype(fsm.trialnum+1) = 4; % non rewarded odr
            fsm.odour(fsm.trialnum+1) = 2;
        end
        set(fsm.handles.odour, 'String',['Odour: ' num2str(fsm.odour(fsm.trialnum+1))]);
        % select if irrelevant grating displayed
        if rand < str2num(get(fsm.handles.pirrel,'String')) %
            fsm.irrelgrating(fsm.trialnum+1) = 1;
            % select irrelevant grating orientation
            if rand < .5; fsm.orientation(fsm.trialnum+1) = fsm.stim1ori;else fsm.orientation(fsm.trialnum+1) = fsm.stim2ori;end
            set(fsm.handles.orientation, 'String',['Orientation: Irr ' num2str(fsm.orientation(fsm.trialnum+1))]);
        else
            fsm.irrelgrating(fsm.trialnum+1) = 2; % no irrel grating
            set(fsm.handles.orientation, 'String',['Orientation: Irr ']);
            fsm.orientation(fsm.trialnum+1) = 0;
        end
end


% % find out if blockwise or trial by trial% trialnum is not yet incremented
% fsm.difflist = str2num(get(fsm.handles.orientationchangelist,'String'));
% if isempty(fsm.orientationchange) % first trial
%     fsm.orientationchange(1) = fsm.difflist(1);
%     fsm.blocktype(1) = 1;
% end
% blockORtbt = get(fsm.handles.blockORtbt,'Value');
% switch blockORtbt
%     case 1 % blocks
%         % is it time to change blocks?
%         if fsm.trialnum+1 - fsm.blockchangetrial >= str2num(get(fsm.handles.ntrialsperblock,'String'))
%             fsm.blockchangetrial = fsm.trialnum+1;
%             %curr = find(fsm.difflist==fsm.orientationchange(fsm.trialnum));
%             if fsm.blocktype(fsm.trialnum) == length(fsm.difflist)
%                 fsm.orientationchange(fsm.trialnum+1) = fsm.difflist(1);
%                 fsm.blocktype(fsm.trialnum+1) = 1;
%             else
%                 fsm.orientationchange(fsm.trialnum+1) = fsm.difflist(fsm.blocktype(fsm.trialnum)+1);
%                 fsm.blocktype(fsm.trialnum+1) = fsm.blocktype(fsm.trialnum) + 1;
%             end
%
%         else
%             if fsm.trialnum>0
%                 if rand < str2num(get(fsm.handles.pprobe,'String')) % if probe trial
%                     if fsm.blocktype(fsm.trialnum) == length(fsm.difflist)
%                         fsm.orientationchange(fsm.trialnum+1) = fsm.difflist(1);%probe is first in list
%                     else
%                         fsm.orientationchange(fsm.trialnum+1) = fsm.difflist(fsm.blocktype(fsm.trialnum)+1);%probe is next in list
%                     end
%                 else % non probe normal trial
%                     fsm.orientationchange(fsm.trialnum+1) = fsm.difflist(fsm.blocktype(fsm.trialnum));
%                 end
%                 fsm.blocktype(fsm.trialnum+1) = fsm.blocktype(fsm.trialnum);
%             end
%         end
%         
%         
%     case 2 % trial by trial
%         rr = randi([1, length(fsm.difflist)]);
%         fsm.orientationchange(fsm.trialnum+1) = fsm.difflist(rr);
% end
% 
% set(fsm.handles.orientationchange,'String',['Orientation change: ' num2str(fsm.orientationchange(fsm.trialnum+1))])

% This decides where the attention is focused, and where the cue (if any) will come
% now choose orientation change location
% if rand < str2num(get(fsm.handles.pmismatch,'String')) % mismatch trial
%     fsm.mismatch(fsm.trialnum+1) = 1;
%     set(fsm.handles.mismatch,'String',['Mismatch trial: ' num2str(fsm.mismatch(fsm.trialnum+1))]);
%     if strcmp(fsm.attentionlocation{fsm.trialnum+1},fsm.attentionlocationlist{1})
%         fsm.orientationchangelocation{fsm.trialnum+1} = fsm.attentionlocationlist{2};
%     elseif strcmp(fsm.attentionlocation{fsm.trialnum+1},fsm.attentionlocationlist{2})
%         fsm.orientationchangelocation{fsm.trialnum+1} = fsm.attentionlocationlist{1};
%     elseif strcmp(fsm.attentionlocation{fsm.trialnum+1},fsm.attentionlocationlist{3})
%         fsm.orientationchangelocation{fsm.trialnum+1} = fsm.attentionlocationlist{4};
%     elseif strcmp(fsm.attentionlocation{fsm.trialnum+1},fsm.attentionlocationlist{4})
%         fsm.orientationchangelocation{fsm.trialnum+1} = fsm.attentionlocationlist{3};
%     end
% else % no mismatch
%     fsm.mismatch(fsm.trialnum+1) = 0;
%     set(fsm.handles.mismatch,'String',['Mismatch trial: ' num2str(fsm.mismatch(fsm.trialnum+1))]);
%     fsm.orientationchangelocation{fsm.trialnum+1} = fsm.attentionlocation{fsm.trialnum+1};
% end
%
% Now choose the orientation from 8 options, go through list without replacement
% if rem(fsm.trialnum,8) == 0
%     fsm.orilist = randperm(8);
% end
% fsm.orientation(fsm.trialnum+1) = (fsm.orilist(rem(fsm.trialnum,8)+1))*360/8;
% set(fsm.handles.orientation, 'String',['Orientation: ' num2str(fsm.orientation(fsm.trialnum+1))]);








