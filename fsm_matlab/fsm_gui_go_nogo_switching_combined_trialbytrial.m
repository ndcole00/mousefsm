% FSMteensy
% Adil Khan, Basel 2016

% 20160912 switches from go nogo task to odr discrim
% 20161102 used binary format for digiout
% 20170819 uses teensy digital line 12 for trial end instead of serial
% 20161103 PWM for control of laser power, extra column on stm
%          This one can present optogenetic laser (PWM) at any time wrt
%          stim on EXCEPT starting after stim has started (to do)
% 20200210 Modified to make it perfrom the cued trial by trial switching task
%          Odr1 and Odr2 double up as cue1 and cue2

function fsm_gui_go_nogo_switching_combined_trialbytrial()

close all
clearvars -global fsm
global fsm

% Decide which version to run based on which PC it is (USBcom vs non USBcom)
if strcmp(getenv('computername'),'DESKTOP-QRQHH0K') % 2p rig1
    fsm.version = 'DAQcom';
    fsm.USBcomFlag = 0;
    fsm.savedir = 'C:\Data\FSM_log\';
else % behaviour boxes
    fsm.version = 'USBcom';
    fsm.USBcomFlag = 1;
    fsm.savedir = 'C:\Behavioural_data\FSM_log\';
end

fsm.TeensyCode = 'fsm_gng_switching_combined.ino'; % This works for both USB and DAQcom
fsm.PCname = getenv('computername');

% Initialise
try fsm.comport = num2str(GetComPort ('USB Serial Device'));
catch; fprintf('Trying Teensy USB Serial\n'); fsm.comport = num2str(GetComPort ('Teensy USB Serial'));end


fsm.token = 'M99_B1';
fsm.fname = '';
fsm.spdrnghigh = 220;
fsm.spdrnglow = 5;
fsm.spdavgbin = .05;
fsm.spdylim = 110;
fsm.spdxrng = 5;
fsm.Tspeedmaintainmin = 2.8;
fsm.Tspeedmaintainmeanadd = .8;
fsm.Tstimdurationmin = 1.5;
fsm.Tstimdurationmeanadd = .2;
fsm.Trewdavailable = 1;
fsm.Titi = .1;
fsm.contrast = 1;
fsm.orientation = [];
fsm.spatialfreq = .1;
fsm.temporalfreq = 2;
fsm.stimtype = [];
fsm.prewd = .5;
fsm.rewd = .1;
fsm.trialnum = 0;
fsm.triallog = {};
fsm.lickthreshold = 0.5;
% fsm.RT = [];
fsm.blockchangetrial = 1;
fsm.grayscreen = 0;
fsm.extrawait = .5;
fsm.state = 0;
fsm.ntrialswithcue = 100;
fsm.iscuetrial = 0;
fsm.punishT = 4;
fsm.instspeed = 0;
fsm.VISorODR = [];
fsm.vbl = 0;
fsm.pirrel = 0;
fsm.Tirrelgrating = 1.8;
fsm.Tirreldelay = 1.8;
fsm.odour = [];
fsm.plaser = 0;
fsm.oridifflist = [30 20 10];
fsm.stimPosOffset = 0; %Determines stimulus position on the x-axis of the screen. +560 max forwards to -560 max backwards
fsm.nTrialsPerBlock = 40;
fsm.blockchangetrial = 1;
fsm.laserpower = [];
fsm.laserpoweroptions = '4,20,33,100';
powers = str2num(fsm.laserpoweroptions);
fsm.plist = randperm(length(powers));
fsm.laserRange = '-.1,1.5'; % wrt stim om
fsm.outcome = [];
fsm.FAirrelOutcome = [];
fsm.pAttendVis = 0.5;
fsm.cueDuration = 1;
fsm.cueDelay = 1;
fsm.cueDelayMeanAdd = .4;

fsm.TspeedMaintainMinByTrial = [];
fsm.TspeedMaintainMeanAddbyTrial = [];
fsm.spdRngLowByTrial = [];
fsm.punishTByTrial = [];
fsm.pirrelByTrial = [];
fsm.prewdByTrial = [];
%--------------------------------------------------------------------------
% make GUI
for i = 1 % IF statement just to enable folding of this chunk of code
fsm.handles.f = figure('Units','normalized','Position',[0.05 0.4 0.5 0.5],...
    'Toolbar','figure');
set(fsm.handles.f,'CloseRequestFcn',@my_closefcn);

% plot image
fsm.handles.ax(1)=axes('Parent',fsm.handles.f,'Units','normalized','Position',[0.65 0.55 0.33 0.4],'xticklabel',[]);
title('Speed (cm/s)');ylim([-10 fsm.spdylim]);
Xrng_speed_plot

fsm.handles.ax(2)=axes('Parent',fsm.handles.f,'Units','normalized','Position',[0.65 0.05 0.33 0.4]);
title('Performance');
hold(fsm.handles.ax(2),'on');

fsm.handles.ax(3)=axes('Parent',fsm.handles.f,'Units','normalized','Visible','off','Position',[0.35 .03 0.27 0.24]);
title('Performance by Ori');
hold(fsm.handles.ax(3),'on');

fsm.handles.ax(4)=axes('Parent',fsm.handles.f,'Units','normalized','Position',[0.38 0.05 0.22 0.18]);
title('Overall performance');

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
fsm.handles.Tspeedmaintainmin_label = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
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

% Orientation difference list
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.3 0.2 0.04],...
    'String','Orientation difference list','FontSize',10);
fsm.handles.oridifflist = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.3 0.1 0.04],...
    'String',num2str(fsm.oridifflist),'FontSize',10);
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
    'String','Prob Irrelevant Stim','FontSize',10);
fsm.handles.pirrel = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.1 0.1 0.04],...
    'String',fsm.pirrel,'FontSize',10);

% Prob cue is for Attend Visual trial
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.05 0.155 0.04],...
    'String','Prob Attend Vis Trial ','FontSize',10);
fsm.handles.pAttendVis = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.18 0.05 0.04 0.04],...
    'String',fsm.pAttendVis,'FontSize',10);

% Stimulus position (horizontal)
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.005 0.155 0.04],...
    'String','Stim Pos (-560 to 560)','FontSize',10);
fsm.handles.stimPosOffset = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.18 0.005 0.04 0.04],...
    'String',fsm.stimPosOffset,'FontSize',10);

% Prob laser
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.8 0.07 0.04],...
    'String','Prob laser','FontSize',10);
fsm.handles.plaser = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.43 0.8 0.04 0.04],...
    'String',fsm.plaser,'FontSize',10);


% Lick threshold
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.6 0.17 0.04],...
    'String','Lick Threshold','FontSize',10);
fsm.handles.lickthreshold = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.53 0.6 0.08 0.04],...
    'String',fsm.lickthreshold,'FontSize',10);

% Cue duration
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.55 0.17 0.04],...
    'String','Cue duration','FontSize',10);
fsm.handles.cueDuration = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.53 0.55 0.08 0.04],...
    'String',fsm.cueDuration,'FontSize',10);

% Cue Delay
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.5 0.17 0.04],...
    'String','Cue delay','FontSize',10);
fsm.handles.cueDelay = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.53 0.5 0.08 0.04],...
    'String',fsm.cueDelay,'FontSize',10);

% Cue Delay mean added
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.45 0.17 0.04],...
    'String','Cue delay mean added','FontSize',10);
fsm.handles.cueDelayMeanAdd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.53 0.45 0.08 0.04],...
    'String',fsm.cueDelayMeanAdd,'FontSize',10);

% Extra wait time
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.85 0.07 0.04],...
    'String','Extra wait time','FontSize',10);
fsm.handles.Textrawait = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.43 0.85 0.04 0.04],...
    'String',fsm.extrawait,'FontSize',10);

% Blocks or Trial by trial changes in ori diff
fsm.handles.blockORtbt = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','popupmenu',...
    'Position', [0.35 0.4 0.12 0.04],'String',{'Blocks (ori)','Trial By Trial (ori)'},...
    'Value',1,'FontSize',10);

uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.48 0.4 0.07 0.04],...
    'String','Ntrl/block','FontSize',10);
fsm.handles.nTrialsPerBlock = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.56 0.4 0.05 0.04],...
    'String',fsm.nTrialsPerBlock,'FontSize',10);

% Punish time
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.48 0.70 0.07 0.04],...
    'String','Punish T','FontSize',10);
fsm.handles.punishT = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.56 0.70 0.05 0.04],...
    'String',fsm.punishT,'FontSize',10);

% % Vis or odr block
% fsm.handles.VISorODR = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','popupmenu',...
%     'Position', [0.35 0.40 0.12 0.04],'String',{'Visual','Odour'},...
%     'Value',1,'FontSize',10);

% Laser power options
fsm.handles.laserpoweroptions_label = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.65 0.17 0.04],...
    'String','Laser powers (%):0','FontSize',10);
fsm.handles.laserpoweroptions = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.53 0.65 0.08 0.04],...
    'String',fsm.laserpoweroptions,'FontSize',10);
 

%%% Indicators %%%

% Filename
fsm.handles.fname = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.8 0.31 0.04],...
    'String',['Filename: ' fsm.fname],'FontSize',10,'HorizontalAlignment','left');

% Trial number
fsm.handles.trialnum = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.9 0.12 0.04],...
    'String',['Trial Number: ' num2str(fsm.trialnum)],'FontSize',10,'HorizontalAlignment','left');

% Odour
fsm.handles.odour = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.7 0.12 0.04],...
    'String',['Odour: '],'FontSize',10,'HorizontalAlignment','left');

% Grating orientation
fsm.handles.orientation = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.75 0.12 0.04],...
    'String',['Orientation: ' num2str(fsm.orientation)],'FontSize',10,'HorizontalAlignment','left');

%%% Checkboxes %%%

% Auto reward
fsm.handles.autorewd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','checkbox',...
    'Position', [0.48 0.9 0.13 0.04],'String','Auto Reward',...
    'Value',1,'FontSize',10);

% Only laser
fsm.handles.onlylaser = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','checkbox',...
    'Position', [0.48 0.85 0.13 0.04],'String','Only laser', ...
    'Value',0,'FontSize',10);

% Speed monitor
fsm.handles.speedMonitorFlag = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','checkbox',...
    'Position', [0.48 0.75 0.13 0.04],'String','Speed Monitor',...
    'Value',0,'FontSize',10);

% Single or double monitor
fsm.handles.twomonitors = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','checkbox',...
    'Position', [0.48 0.8 0.13 0.04],'String','Two Monitors','Callback', @twoMonitor_callback, ...
    'Value',1,'FontSize',10);


% 
% % Auto Switch
% fsm.handles.autoSwitch = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','checkbox',...
%     'Position', [0.23 0.005 0.12 0.04],'String','AutoSwitch', ...
%     'Value',0,'FontSize',10);


%%%%% Buttons%%%%
% Start button
fsm.handles.start = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.35 0.31 0.13 0.08],...
    'String','Start','BackgroundColor', 'green','Callback', @call_start);

% Stop button
fsm.handles.stop = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.49 0.31 0.12 0.08],...
    'String','Stop','BackgroundColor', 'red','enable','off','Callback', @call_stop);

% Toggle valve button
fsm.handles.toggleRewdValve = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.49 0.265 0.12 0.04],...
    'String','Toggle Rewd Valve','BackgroundColor', 'cyan','Callback', @call_toggleRewdValve);

% Set parameters for orimap
fsm.handles.setOrimapParams = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.35 0.265 0.13 0.04],...
    'String','OriMap params', 'BackgroundColor', 'cyan','Callback', @call_setOrimapParams);


%--------------------------------------------------------------------------
% End make GUI
end

% start serial port
fsm.ard=serial(fsm.comport,'BaudRate',9600); % create serial communication object on port COM7
set(fsm.ard,'Timeout',.01);
fopen(fsm.ard); % initiate arduino communication
fprintf('serial port opened\n')

% check if correct teensy code is loaded
fprintf(fsm.ard,'%s','T');
while ~fsm.ard.BytesAvailable;end
rcvd = fscanf(fsm.ard,'%s');
rcvdsplit = strsplit(rcvd, '\');
if strcmp(rcvdsplit{end},fsm.TeensyCode)
    fprintf('Teensy code is correct: %s',rcvdsplit{end});
else
    error(sprintf('Teensy code is wrong: %s\n Load correct Teensy code and restart',rcvdsplit{end}));
end

% initiate the stim machine;
if strmatch (fsm.version,'DAQcom')
    stim_machine_init_go_nogo_switching
elseif strmatch (fsm.version,'USBcom')
    stim_machine_init_go_nogo_switching_USBcom
end
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
set(fsm.handles.toggleRewdValve,'enable','off')
set(fsm.handles.stop,'enable','on')
cla(fsm.handles.ax(2));
cla(fsm.handles.ax(3));
powers = str2num(get(fsm.handles.laserpoweroptions,'string'));
fsm.plist = randperm(length(powers));
Xrng_speed_plot;
drawnow;pause(0.00000001)

make_state_matrix


function make_state_matrix
%try
global fsm
keeprunning = 1;fsm.stop = 0;
while keeprunning
    
    choose_stim % decide which stimlus to give
    fsm.stimPosOffset = str2num(get(fsm.handles.stimPosOffset,'string'));
    
    igT  = str2num(get(fsm.handles.Tirrelgrating,'string'));
    iwT  = str2num(get(fsm.handles.Tirreldelay,'string')) + exprnd(.2);
    spdT = str2num(get(fsm.handles.Tspeedmaintainmin,'string')) + exprnd(str2num(get(fsm.handles.Tspeedmaintainmeanadd,'string')));
    stmT = str2num(get(fsm.handles.Tstimdurationmin,'string')) + rand*str2num(get(fsm.handles.Tstimdurationmeanadd,'string'));
    fsm.stmT = stmT;
    %     %if stimT>5;stimT=rand*5;end
    waitT = str2num(get(fsm.handles.Trewdavailable,'string'));
    rewT  = str2num(get(fsm.handles.rewd,'string'));
    iti   = str2num(get(fsm.handles.Titi,'string'));
    extraT= str2num(get(fsm.handles.Textrawait,'string'));
    %     mcvT  = str2num(get(fsm.handles.Tminorientationview,'string'));
    pT    = str2num(get(fsm.handles.punishT,'string'));
    fsm.contrast = str2num(get(fsm.handles.contrast,'string'));
    pL    = str2num(get(fsm.handles.plaser,'string'));
    % put current values in textboxes
    set(fsm.handles.Tspeedmaintainmin_label,'string',['T speed maintain min (' sprintf('%.2f',spdT) ')'])
    
    CueT = str2num(get(fsm.handles.cueDuration,'string'));
    CueD = str2num(get(fsm.handles.cueDelay,'string')) + exprnd(str2num(get(fsm.handles.cueDelayMeanAdd,'string')));
    
    % digiOut mapping
    R   =  2^0; %teensy pin 2, reward
    Vis1 = 2^1; %teensy pin 3, visual stim 1 rewarded
    Vis2 = 2^2; %teensy pin 4, visual stim 2 non rewarded
    Odr1 = 2^3; %teensy pin 5, odour1 rewarded
    Odr2 = 2^4; %teensy pin 6, odour2 non rewarded
    Bln  = 2^5; %teensy pin 7, blank odour
    Irr  = 2^6; %teensy pin 8, Irrelevant vis, should be on with the vis bit
    L    = 2^7; %teensy pin 9, trigger for optogenetic laser
    
    Rew = R;
    iStim = 0;
    
    switch fsm.stimtype(fsm.trialnum+1)% 1 = vis rewarded, 2 = vis not rewarded, 3 = Odr rewarded, 4 = odr not rewarded
        case 1 % vis rewarded
            Cue = Odr2; % cue for attend vis condition is odour 2
            Stim = Vis1+Bln;% rewarded grating (+45 degrees)
            lok1 = 5;% rewd
            fa = 3;% refractory period

            IR = 3; % no irrel grating

            % auto reward or not
            if get(fsm.handles.autorewd ,'Value')==1
                AR = 7;
            else
                AR = 13;
            end
            Rew = Rew+Vis1+Bln;
        case 2 % vis non rewarded
            Cue = Odr2; % cue for attend vis condition is odour 2
            Stim = Vis2+Bln;% non rewarded grating (-45 degrees)
            lok1 = 8;% punish
            fa = 8;% punish
            AR = 9; % no auto reward
            waitT = 1;% hard-coded! 05-09-17, to make non rew stim not stay on too long if you need to increase Trewdavailable

            IR = 3; % no irrel grating


        case 3 % odour rewarded
            Cue = Odr1; % cue for attend vis condition is odour 1
            Stim = Odr1;% Odr1
            lok1 = 5;% rewd
            fa = 3;% refractory period
            if fsm.irrelgrating(fsm.trialnum+1) == 1
                IR = 10;  %Irrel grating on

                if fsm.orientation(fsm.trialnum+1) == fsm.stim1ori
                    iStim = Vis1+Irr+Bln;% +45 degrees
                else
                    iStim = Vis2+Irr+Bln;% -45 degrees
                end
            else
                IR = 3; % no irrel grating
            end
            
            % auto reward or not
            if get(fsm.handles.autorewd ,'Value')==1
                AR = 7;
            else
                AR = 13;
            end
            Rew = Rew+Odr1;
        case 4 % odour non rewarded
            Cue = Odr1; % cue for attend vis condition is odour 1
            Stim = Odr2;% Odr2
            lok1 = 8;% punish
            fa = 8;% punish
            if fsm.irrelgrating(fsm.trialnum+1) == 1
                IR = 10;  %Irrel grating on
                if fsm.orientation(fsm.trialnum+1) == fsm.stim1ori
                    iStim = Vis1+Irr+Bln;% +45 degrees
                else
                    iStim = Vis2+Irr+Bln;% -45 degrees
                end
            else
                IR = 3; % no irrel grating
            end
            AR = 9; % no auto reward
            
    end
    pwr = 0;

    
    % if only laser trials (OP)
    if get(fsm.handles.onlylaser,'Value')
        Stim = Bln;Rew = Bln; iStim = Bln; % no stim signals
        pL = 1; %Force laser trials
        set(fsm.handles.autorewd, 'Value',0)
        IR = 3; % force Attend Vis trial
        %set(fsm.handles.laserRange,'string','-1.5,0')
        fa = 3;
        lok1=5;
        waitT = 0;rewT=0;extraT=0;
    end
 
    % if laser trial
    if rand < pL && (get(fsm.handles.VISorODR,'Value')==1 || fsm.irrelgrating(fsm.trialnum+1) == 1) 
        Lon = L + Bln;
        
        % choose laser power (PWM)
        powers = str2num(get(fsm.handles.laserpoweroptions,'string'));
        if rem(fsm.trialnum,length(powers)) == 0
            fsm.plist = randperm(length(powers));
        end
        pwr = powers(fsm.plist(rem(fsm.trialnum,length(powers))+1));
        
        fsm.laserpower(fsm.trialnum+1) = pwr;
        set (fsm.handles.laserpoweroptions_label,'String',['Laser powers (%):' num2str(pwr)]);
        pwr = round(pwr*4095/100); % 0-4095, 12 bit resolution for analog out
  
    else % if not a laser trial
        Lon = Bln;
        set (fsm.handles.laserpoweroptions_label,'String',['Laser power: 0' ]);
    end
    
    stm = [... % remember zero indexing; units are seconds, multiplied later to ms
        
%  spd in   spd out     lick    Tup       Timer         digiOut   AnalogOut
    0           0        0       1         0.01           Bln        0      ;...% state 0 init
    12          1        1       1         100            Bln        0      ;...% state 1 wait for speed in
    2           1        2       14        spdT           Bln        0      ;...% state 2 maintain speed
    3           3        fa      4         stmT           Stim       0      ;...% state 3 Stim on, refractory period
    4           4        lok1    AR        waitT          Stim       0      ;...% state 4 Stim on, reward zone, wait for lick
    5           5        5       6         rewT           Rew        0      ;...% state 5 Stim on, reward on
    6           6        6       9         extraT         Stim       0      ;...% state 6 Stim on, extra view
    7           7        7       6         rewT           Rew        0      ;...% state 7 auto reward
    8           8        8       4         pT             Stim       0      ;...% state 8 punish time
    9           9        9       99        iti            Bln        0      ;...% state 9 ITI
    10          10       25      21        igT/5          iStim      0      ;...% state 10 irrel grating
    11          11       11      3         iwT            Bln        0      ;...% state 11 delay after irrel grating
    12          12       12      2         .2             Bln        0      ;...% state 12 to prevent fast transitions
    13          13       13      9         .01            Bln        0      ;...% state 13 Miss 
    14          14       14      15        CueT           Cue        0      ;...% state 14 Cue indicating trial type
    15          15       15      IR        CueD           Lon        pwr    ;...% state 15 Working memory delay
    0           0        0       0         0              0          0      ;...% state 16 blank for future use    
    0           0        0       0         0              0          0      ;...% state 17 blank for future use
    0           0        0       0         0              0          0      ;...% state 18 blank for future use
    0           0        0       0         0              0          0      ;...% state 19 blank for future use
    0           0        0       0         0              0          0      ;...% state 20 blank for future use

                                                                                % coming from iStim licks here will lead to catch states 
    21          21       26      22        igT/5          iStim      0      ;...% state 21 istim (1/5th to allow recording FA on irrels)
    22          22       27      23        igT/5          iStim      0      ;...% state 22 istim (1/5th to allow recording FA on irrels)
    23          23       28      24        igT/5          iStim      0      ;...% state 23 istim (1/5th to allow recording FA on irrels)
    24          24       29      11        igT/5          iStim      0      ;...% state 24 istim (1/5th to allow recording FA on irrels)
    
                                                                                % catch states
    25          25       25      26        igT/5          iStim      0      ;...% state 25 istim (1/5th to allow recording FA on irrels)
    26          26       26      27        igT/5          iStim      0      ;...% state 26 istim (1/5th to allow recording FA on irrels)
    27          27       27      28        igT/5          iStim      0      ;...% state 27 istim (1/5th to allow recording FA on irrels)
    28          28       28      29        igT/5          iStim      0      ;...% state 28 istim (1/5th to allow recording FA on irrels)
    29          29       29      11        igT/5          iStim      0      ;...% state 29 istim (1/5th to allow recording FA on irrels)
    
      ];

stm (:,5) = round(stm(:,5)*1000); % sec to ms
rcvd = '';
% send an 'A' and receive a 'B'
while ~strcmp(rcvd,'B')
    fprintf(fsm.ard,'%s','A');
    fprintf('Handshake: A');
    rcvd = fscanf(fsm.ard,'%s');
    fprintf('%s',rcvd);
end

% send [nRows nCols]
[row, col] = size(stm);
fprintf(fsm.ard,'%s\n',num2str([row col]));

% send speed averaging bin size
spdbin = fsm.spdavgbin*1000;
fprintf(fsm.ard,'%s\n',num2str(spdbin));

% send upper and lower limit for speed range
fprintf(fsm.ard,'%s\n',num2str(fsm.spdrnghigh));
fprintf(fsm.ard,'%s\n',num2str(fsm.spdrnglow));

% send lick threshold; 3.3V is 1024
threshold = round((1024/3.3)*str2num(get(fsm.handles.lickthreshold,'string')));
fprintf(fsm.ard,'%s\n',num2str(threshold));

% send flag for speed monitor (may cause dropped frames, switch off for
% real recordings)
speedMonitorFlag = get(fsm.handles.speedMonitorFlag,'Value');
fprintf(fsm.ard,'%s\n',num2str(speedMonitorFlag));

% Send flag to indicate if it is USBcom (behaviour boxes running on NI USB6008)
fprintf(fsm.ard,'%s',num2str(fsm.USBcomFlag));

% Remember last one without \n

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
        fsm.orientation = [];
        Xrng_speed_plot;
    case 'startingFSM'
        fsm.trialnum = fsm.trialnum + 1;
        set(fsm.handles.trialnum,'String',['Trial Number: ' num2str(fsm.trialnum)])
        fprintf('Trial number %d\n',fsm.trialnum);
        trialend = 0;
        fsm.stimStartFlag = 1;
        while trialend == 0
            % check stop button
            if fsm.stop == 1
                keeprunning = 0;
                break
            end
            % check for stimulus change
            if strmatch(fsm.version,'DAQcom')
                stim_machine_go_nogo_switching
            elseif strmatch(fsm.version,'USBcom')
                stim_machine_go_nogo_switching_USBcom
            end

            if fsm.trialend == 1 % set by stim machine
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
                findoutcome(triallog)
                fsm.trialend = 0;
            
                % get speed only if SpeedMonitor checkbox is on
            elseif speedMonitorFlag
                if strmatch(fsm.version,'DAQcom')
                    if fsm.ard.BytesAvailable
                        rcvd2 = fscanf(fsm.ard,'%s');
                        olddat = get(fsm.handles.spdplot,'ydata');
                        newdat = cat(2,olddat(2:end),str2num(rcvd2));
                        set(fsm.handles.spdplot,'ydata',newdat);
                        set(fsm.handles.ax(1),'ylim',[-10 fsm.spdylim]);
                        drawnow
                        fsm.instspeed = str2num(rcvd2);
                    end
                elseif strmatch(fsm.version,'USBcom')
                    if fsm.spdAvailable
                        rcvd2 = fsm.spd;
                        olddat = get(fsm.handles.spdplot,'ydata');
                        newdat = cat(2,olddat(2:end),str2num(rcvd2));
                        set(fsm.handles.spdplot,'ydata',newdat);
                        set(fsm.handles.ax(1),'ylim',[-10 fsm.spdylim]);
                        drawnow
                        fsm.instspeed = str2num(rcvd2);
                    end
                end %if strmatch(fsm.version,'DAQcom')
            end %if fsm.trialend == 1 % set by stim machine
            
            
        end % while trialend == 0
end %switch rcvd

end %while keeprunning

% catch
%     save([fsm.fname '-autosave'],'fsm');
%     fprintf('crash\n')

%end

fprintf('make state matrix ended\n')

function call_stop(src,eventdata)
global fsm
fsm.stop = 1;

%Update all the preset variables that may have been changed in the GUI. 
fsm.token = get(fsm.handles.token,'string');
%fsm.accuracyThresholdAutoSwitch = str2num(get(fsm.handles.accuracyThresholdAutoSwitch,'string'));
fsm.Tspeedmaintainmeanadd = str2num(get(fsm.handles.Tspeedmaintainmeanadd,'string'));
fsm.Tstimdurationmeanadd = str2num(get(fsm.handles.Tstimdurationmeanadd,'string'));
fsm.Tspeedmaintainmin = str2num(get(fsm.handles.Tspeedmaintainmin,'string'));
%fsm.NtrialsAutoSwitch = str2num(get(fsm.handles.NtrialsAutoSwitch,'string'));
fsm.Tstimdurationmin = str2num(get(fsm.handles.Tstimdurationmin,'string'));
fsm.nTrialsPerBlock = str2num(get(fsm.handles.nTrialsPerBlock,'string'));
fsm.Trewdavailable = str2num(get(fsm.handles.Trewdavailable,'string'));
fsm.lickthreshold = str2num(get(fsm.handles.lickthreshold,'string'));
fsm.Tirrelgrating = str2num(get(fsm.handles.Tirrelgrating,'string'));
fsm.stimPosOffset = str2num(get(fsm.handles.stimPosOffset,'string'));
%fsm.temporalfreq = str2num(get(fsm.handles.temporalfreq,'string'));
%fsm.spatialfreq = str2num(get(fsm.handles.spatialfreq,'string'));
fsm.Tirreldelay = str2num(get(fsm.handles.Tirreldelay,'string'));
fsm.oridifflist = str2num(get(fsm.handles.oridifflist,'string'));
%fsm.spdrnghigh = str2num(get(fsm.handles.spdrnghigh,'string'));
fsm.spdrnglow = str2num(get(fsm.handles.spdrnglow,'string'));
fsm.extrawait = str2num(get(fsm.handles.Textrawait,'string'));
fsm.contrast = str2num(get(fsm.handles.contrast,'string'));
fsm.punishT = str2num(get(fsm.handles.punishT,'string'));
fsm.pirrel = str2num(get(fsm.handles.pirrel,'string'));
fsm.prewd = str2num(get(fsm.handles.prewd,'string'));
fsm.rewd = str2num(get(fsm.handles.rewd,'string'));
fsm.Titi = str2num(get(fsm.handles.Titi,'string'));

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
    fsm_temp = fsm;
    fsm = rmfield(fsm,'handles');% to avoid saving figure
    save(fsm.fname,'fsm');
    fprintf('Logfile saved\n')
    fsm = fsm_temp; clear fsm_temp;
end

% reset
fsm.trialnum = 0;
fsm.triallog = {};
fsm.orientation = [];
fsm.VISorODR = [];
fsm.blockORtbt = [];
fsm.stimtype = [];
fsm.odour = [];
fsm.laserpower = [];
fsm.outcome = [];
fsm.FAirrelOutcome = [];
fsm.trialend = 0;
fsm.oridiff = [];
fsm.irrelgrating = [];
fsm.TspeedMaintainMinByTrial = [];
fsm.TspeedMaintainMeanAddbyTrial = [];
fsm.spdRngLowByTrial = [];
fsm.punishTByTrial = [];
fsm.pirrelByTrial = [];
fsm.prewdByTrial = [];
fsm.visOutcome = [];
fsm.odrOutcome = [];

set(fsm.handles.start,'enable','on')
set(fsm.handles.toggleRewdValve,'enable','on')



function my_closefcn(src,eventdata)
global fsm
%try call_stop;
%catch; fprintf('Did not stop and save cleanly\n');end
%Screen('Preference', 'SkipSyncTests', fsm.oldSyncLevel);
try Screen('CloseAll');
catch; fprintf('Did not stop PTB cleanly\n');end
try fclose(fsm.ard); fprintf('serial port closed\n')% end communication with arduino
catch; fprintf('Did not stop teensy cleanly, should reboot\n');end
try delete(fsm.s);
catch; fprintf('Did not stop NI DAQ cleanly\n');end
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

function findoutcome(triallog)
global fsm
% hit: 4 to 5, CR 4 to 9, miss 4 to 13 or 4 to 7  , FA 4 to 8 or 3 to 8
% 1:hit  2:CR   3:miss   4:FA
if ~isempty(strfind(triallog, '4to7'))||~isempty(strfind(triallog, '4to13')); fsm.outcome(fsm.trialnum) = 3;fprintf('Miss\n');% miss
elseif ~isempty(strfind(triallog, '4to5')); fsm.outcome(fsm.trialnum) = 1; fprintf('Hit\n');% hit
elseif ~isempty(strfind(triallog, '4to8'))||~isempty(strfind(triallog, '3to8')); fsm.outcome(fsm.trialnum) = 4;fprintf('FA\n');% FA
elseif ~isempty(strfind(triallog, '4to9')); fsm.outcome(fsm.trialnum) = 2;fprintf('CR\n');% CR
else error ('here');
end

if fsm.attend == 1
    fsm.visOutcome(fsm.trialnum) = fsm.outcome(fsm.trialnum); fsm.odrOutcome(fsm.trialnum) = NaN;
elseif fsm.attend == 2
    fsm.visOutcome(fsm.trialnum) = NaN; fsm.odrOutcome(fsm.trialnum) = fsm.outcome(fsm.trialnum);
end

% Also find FAs to Irrel stims (FAirrel)
% FAirrel:  Irrel 10 to 25, 21 to 26, 22 to 27, 23 to 28, 24 to 29
if ~isempty(strfind(triallog, '10to25'))||~isempty(strfind(triallog, '21to26'))||~isempty(strfind(triallog, '22to27'))||~isempty(strfind(triallog, '23to28'))...
        ||~isempty(strfind(triallog, '24to29'))
    fsm.FAirrelOutcome(fsm.trialnum) = 1;fprintf('FA Irrel\n');% FA irrel
elseif fsm.irrelgrating(fsm.trialnum) == 1 % if its an irrel grating trial & no FA
    fsm.FAirrelOutcome(fsm.trialnum) = 0;fprintf('CR Irrel\n');% CR irrel
else
    fsm.FAirrelOutcome(fsm.trialnum) = NaN; % Not an irrel trial
end

% update performance plot
% 20 trial window
mrks = {'ro','k*','b^'};
VISorODR = fsm.attend;
visCorrecttrials = (fsm.visOutcome == 1) + (fsm.visOutcome == 2);
odrCorrecttrials = (fsm.odrOutcome == 1) + (fsm.odrOutcome == 2);
yplot = [];
for i = 1:length(visCorrecttrials)
    visYPlot(i) = nanmean(visCorrecttrials(max([1 i-20]):i))*100;
    odrYPlot(i) = nanmean(odrCorrecttrials(max([1 i-20]):i))*100;
    yplotFAirrel(i) = nanmean(fsm.FAirrelOutcome(max([1 i-20]):i))*100;
end
if length(visCorrecttrials)>=5 % to split into 2 cued
    if VISorODR == 1
    plot(fsm.handles.ax(2),length(visCorrecttrials),visYPlot(end),mrks{1});
    elseif VISorODR == 2
        hold on;
        plot(fsm.handles.ax(2),length(odrCorrecttrials),odrYPlot(end),mrks{2})
        plot(fsm.handles.ax(2),length(odrCorrecttrials),yplotFAirrel(end),mrks{3});
    end
end
set(fsm.handles.ax(2),'ylim',[0 100],'xlim',[0 length(visCorrecttrials)]);


% Summary plot of performances
    percentCorrect = [nanmean(visCorrecttrials)*100 nanmean(odrCorrecttrials)*100 nanmean(fsm.FAirrelOutcome)*100];
    cla(fsm.handles.ax(4));
    bar(fsm.handles.ax(4),[1 2 3],percentCorrect); hold on;
    xticks([1 2 3]);xticklabels({'Vis Rel','Odour','Vis Irrel'});
    xlabel('Stim type'); ylabel('% Correct');


function choose_stim
global fsm

% Decide which trial type, attend vis or ignore vis
if rand < str2num(get(fsm.handles.pAttendVis,'String')) 
    VISorODR = 1;% Attend Visual trial
else
    VISorODR = 2;% Ignore Visual, Attend Odour trial
end
fsm.attend = VISorODR;
fsm.oridifflist =  str2num(get(fsm.handles.oridifflist,'String'));

fsm.TspeedMaintainMinByTrial(fsm.trialnum+1) = str2num(get(fsm.handles.Tspeedmaintainmin,'String'));
fsm.TspeedMaintainMeanAddbyTrial(fsm.trialnum+1) = str2num(get(fsm.handles.Tspeedmaintainmeanadd,'String'));
fsm.spdRngLowByTrial(fsm.trialnum+1) = str2num(get(fsm.handles.spdrnglow,'String'));
fsm.punishTByTrial(fsm.trialnum+1) = str2num(get(fsm.handles.punishT,'String'));
fsm.pirrelByTrial(fsm.trialnum+1) = str2num(get(fsm.handles.pirrel,'String'));
fsm.prewdByTrial(fsm.trialnum+1) = str2num(get(fsm.handles.prewd,'String'));

switch VISorODR
    case 1 % visual block
        fsm.VISorODR(fsm.trialnum+1) = 1;
        % find out if blockwise or trial by trial for different difficulties% trialnum is not yet incremented
        fsm.blockORtbt(fsm.trialnum+1) = get(fsm.handles.blockORtbt,'Value');
        blockORtbt = fsm.blockORtbt(fsm.trialnum+1);
        fsm.irrelgrating(fsm.trialnum+1) = 0;
        switch blockORtbt
            case 1 % blocks
                if isempty(fsm.orientation) || fsm.VISorODR(fsm.trialnum)==2 || fsm.blockORtbt(fsm.trialnum)==2% first trial or change to blockwise after odr block/ vis trial by trial
                    fsm.oridiff(fsm.trialnum+1) = fsm.oridifflist(1);
                    fsm.blockchangetrial = fsm.trialnum+1;
                else
                    % is it time to change blocks?
                    if fsm.trialnum+1 - fsm.blockchangetrial >= str2num(get(fsm.handles.nTrialsPerBlock,'String'))
                        fsm.blockchangetrial = fsm.trialnum+1;
                        oridifflistind = find(fsm.oridifflist==fsm.oridiff(fsm.trialnum));
                        if oridifflistind<length(fsm.oridifflist)
                            fsm.oridiff(fsm.trialnum+1) = fsm.oridifflist(oridifflistind+1);
                        else
                            fsm.oridiff(fsm.trialnum+1) = fsm.oridifflist(oridifflistind);% keep last difficulty if finished all others
                        end
                        
                    else % continue same block
                        fsm.oridiff(fsm.trialnum+1) = fsm.oridiff(fsm.trialnum);% keep last difficulty if finished all others
                    end
                end
                
            case 2 % trial by trial
                rr = randi([1, length(fsm.oridifflist)]);
                fsm.oridiff(fsm.trialnum+1) = fsm.oridifflist(rr);
        end
        
        
        fsm.stim1ori = 180-fsm.oridiff(fsm.trialnum+1)/2;
        fsm.stim2ori = 180+fsm.oridiff(fsm.trialnum+1)/2;
        
        % choose rewarded or non rewarded stim
        if rand < str2num(get(fsm.handles.prewd,'String')) % if rewarded trial
            fsm.stimtype(fsm.trialnum+1) = 1; % rewarded vis
            fsm.orientation(fsm.trialnum+1) = fsm.stim1ori;
        else
            fsm.stimtype(fsm.trialnum+1) = 2; % non rewarded vis
            fsm.orientation(fsm.trialnum+1) = fsm.stim2ori;
        end
        
        set(fsm.handles.orientation, 'String',['Orientation: ' num2str(fsm.orientation(fsm.trialnum+1))]);
  
        set(fsm.handles.odour, 'String',['Odour: ']);
        fsm.odour(fsm.trialnum+1) = NaN;

  
    case 2 % odour block
        fsm.VISorODR(fsm.trialnum+1) = 2;
        fsm.blockORtbt(fsm.trialnum+1) = 0;
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
            rr = randi([1, length(fsm.oridifflist)]);
            fsm.oridiff(fsm.trialnum+1) = fsm.oridifflist(rr);
            fsm.stim1ori = 180-fsm.oridiff(fsm.trialnum+1)/2;
            fsm.stim2ori = 180+fsm.oridiff(fsm.trialnum+1)/2;
            if rand < .5; fsm.orientation(fsm.trialnum+1) = fsm.stim1ori;
            else fsm.orientation(fsm.trialnum+1) = fsm.stim2ori; end
            
            set(fsm.handles.orientation, 'String',['Orientation: Irr ' num2str(fsm.orientation(fsm.trialnum+1))]);
        else
            fsm.irrelgrating(fsm.trialnum+1) = 2; % no irrel grating
            set(fsm.handles.orientation, 'String',['Orientation: Irr ']);
            fsm.orientation(fsm.trialnum+1) = 0;
        end
end


function call_toggleRewdValve(src,eventdata)
global fsm
if isequal(fsm.handles.toggleRewdValve.BackgroundColor, [0 1 1])
    set(fsm.handles.toggleRewdValve,'BackgroundColor','red')
    fprintf(fsm.ard,'%s','V');
else
    set(fsm.handles.toggleRewdValve,'BackgroundColor','cyan')
    fprintf(fsm.ard,'%s','W');
end

function call_setOrimapParams(src,eventdata)
global fsm
if isequal(fsm.handles.setOrimapParams.BackgroundColor, [0 1 1])
    set(fsm.handles.setOrimapParams,'BackgroundColor','red')
    set(fsm.handles.Tspeedmaintainmin,'String','3');
    set(fsm.handles.Tspeedmaintainmeanadd,'String','0');
    set(fsm.handles.Tstimdurationmin,'String','2');
    set(fsm.handles.Tstimdurationmeanadd,'String','0');
    set(fsm.handles.Trewdavailable,'String','0');
    set(fsm.handles.oridifflist,'String','90 180 270 360 450 540 630 720');
    set(fsm.handles.spdrnglow,'String','-5');
    set(fsm.handles.Textrawait,'String','0');
    set(fsm.handles.prewd,'String','1');
    set(fsm.handles.autorewd, 'Value',0)
    set(fsm.handles.blockORtbt, 'Value',2)
    fsm.twomonitors = 0;
    
    for f = 1:2 % doing it twice prevents strange behaviour
                %Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [560+fsm.stimPosOffset,0,2000+fsm.stimPosOffset,1440], orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
                %if fsm.twomonitors;Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [560-fsm.stimPosOffset,0,2000-fsm.stimPosOffset,1440], 180-orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);end
                Screen('FillRect',fsm.winL,255/2);
                Screen('FillRect',fsm.winR,255/2);
                Screen('Flip', fsm.winL, [],[],[],1);
    end
            
else
    set(fsm.handles.setOrimapParams,'BackgroundColor','cyan')
    set(fsm.handles.Tspeedmaintainmin,'String','2.8');
    set(fsm.handles.Tspeedmaintainmeanadd,'String','0.4');
    set(fsm.handles.Tstimdurationmin,'String','1.5');
    set(fsm.handles.Tstimdurationmeanadd,'String','0.2');
    set(fsm.handles.Trewdavailable,'String','1');
    set(fsm.handles.oridifflist,'String','30 20 10');
    set(fsm.handles.spdrnglow,'String','0');
    set(fsm.handles.Textrawait,'String','0.5');
    set(fsm.handles.prewd,'String','0.5');
    set(fsm.handles.autorewd, 'Value',1)
    set(fsm.handles.blockORtbt, 'Value',1)
    fsm.twomonitors = 1;
    
end

function twoMonitor_callback(src,eventdata)
global fsm
if get(fsm.handles.twomonitors, 'Value') == 1
    fsm.twomonitors = 1;
    fprintf('Two monitors\n')
else
    fsm.twomonitors = 0;
    fprintf('One monitor\n')
    for f = 1:2 % doing it twice prevents strange behaviour
        %Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [560+fsm.stimPosOffset,0,2000+fsm.stimPosOffset,1440], orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
        %if fsm.twomonitors;Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [560-fsm.stimPosOffset,0,2000-fsm.stimPosOffset,1440], 180-orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);end
        Screen('FillRect',fsm.winL,255/2);
        Screen('FillRect',fsm.winR,255/2);
        Screen('Flip', fsm.winL, [],[],[],1);
    end
end
