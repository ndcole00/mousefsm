% FSMteensy
% Adil Khan, Basel 2016

% 20160912 switches from go nogo task to odr discrim
% 20161102 used binary format for digiout
% 20170819 uses teensy digital line 12 for trial end instead of serial
% 20161103 PWM for control of laser power, extra column on stm
%          This one can present optogenetic laser (PWM) at any time wrt
%          stim on EXCEPT starting after stim has started (to do)

function fsm_gui_go_nogo_switching_combined()

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
% try fsm.comport = num2str(GetComPort ('USB Serial Device'));
% catch; fprintf('Trying Teensy USB Serial\n'); fsm.comport = num2str(GetComPort ('Teensy USB Serial'));end
fsm.comport = 'COM3';%helper.fetchScreensAndComport('com');

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
fsm.pIrrelRwd = .5;
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
fsm.pirrelodr = 0;
fsm.Tirrelgrating = 1.8;
fsm.Tirreldelay = 1.8;
fsm.Tirreldelaymeanadd = 0;
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
fsm.NtrialsAutoSwitch = 40;
fsm.accuracyThresholdAutoSwitch = 75;
fsm.nIrrelTrials = 10; % number of trials over which to look for irrel FA before switching
fsm.consecutiveCorrect = 3; % number of correct consecutive responses needed to end transition conditions

fsm.lickThreshByTrial = [];
fsm.TspeedMaintainMinByTrial = [];
fsm.TspeedMaintainMeanAddbyTrial = [];
fsm.spdRngLowByTrial = [];
fsm.punishTByTrial = [];
fsm.pirrelByTrial = [];
fsm.pirrelodrByTrial = [];
fsm.prewdByTrial = [];
fsm.contrastByTrial = [];
fsm.itiLaser = [];
fsm.transitionState = 0; % 1 if in transition conditions, 0 if in normal conditions

fsm.maxBlockSize = 0; % 0 = no maximum block size
fsm.laserOffsetOn = 0; % whether to set laser to off in first visual trials following auto-switch
fsm.constantLaser = 0; % whether to have laser signal on constantly, if ITI is checked

fsm.switchCount = 0; % for monitoring number of switchs visual to odour, for alternating laser
fsm.includeBlankOrimapTrials = true;

%--------------------------------------------------------------------------
% make GUI
for i = 1 % IF statement just to enable folding of this chunk of code
    fsm.handles.f = figure('Units','normalized','Position',[0.05 0.4 0.5 0.5],...
        'Toolbar','figure');
    set(fsm.handles.f,'CloseRequestFcn',@my_closefcn);
    
    % plot image
    
    fsm.handles.ax(2)=axes('Parent',fsm.handles.f,'Units','normalized','Position',[0.65 0.05 0.33 0.4]);
    title('Performance');
    hold(fsm.handles.ax(2),'on');
    
    fsm.handles.ax(3)=axes('Parent',fsm.handles.f,'Units','normalized','Visible','off','Position',[0.35 .03 0.27 0.24]);
    title('Performance by Ori');
    hold(fsm.handles.ax(3),'on');
    
    fsm.handles.ax(4)=axes('Parent',fsm.handles.f,'Units','normalized','Position',[0.38 0.05 0.22 0.18]);
    title('Performance by orientation');
    
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
        'String',fsm.token,'FontSize',10,...
        'TooltipString','Mouse token - must by in format: ABC123_BX, where X is the block number');
    
    % spd rng low
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.75 0.2 0.04],...
        'String','Speed range low','FontSize',10);
    fsm.handles.spdrnglow = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.23 0.75 0.1 0.04],...
        'String',fsm.spdrnglow,'FontSize',10,'Callback', @call_change_spdrnglow,...
        'TooltipString','Low speed threshold for running');
    
    % t irrel grating
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.7 0.2 0.04],...
        'String','T irrel grating','FontSize',10);
    fsm.handles.Tirrelgrating = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.23 0.7 0.1 0.04],...
        'String',fsm.Tirrelgrating,'FontSize',10,...
        'TooltipString','Duration of irrelevant visual gratings, in s');
    
    % T delay after irrel grating
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.65 0.2 0.04],...
        'String','T irrel delay','FontSize',10);
    fsm.handles.Tirreldelay = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.23 0.65 0.1 0.04],...
        'String',fsm.Tirreldelay,'FontSize',10,...
        'TooltipString','Time between irrelevant visual grating offset and odour onset');
    
    % T speed maintain min
    fsm.handles.Tspeedmaintainmin_label = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.6 0.2 0.04],...
        'String','T speed maintain min','FontSize',10);
    fsm.handles.Tspeedmaintainmin = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.23 0.6 0.1 0.04],...
        'String',fsm.Tspeedmaintainmin,'FontSize',10,...
        'TooltipString','Minimum time for which mouse must sustain running to trigger a trial');
    
    % T speed maintain mean additional
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.55 0.2 0.04],...
        'String','T speed maintain mean added','FontSize',10);
    fsm.handles.Tspeedmaintainmeanadd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.23 0.55 0.1 0.04],...
        'String',fsm.Tspeedmaintainmeanadd,'FontSize',10,...
        'TooltipString','Mean added random jitter to time for which mouse must sustain running');
    %
    % T Stim duration min
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.5 0.2 0.04],...
        'String','T stim duration min','FontSize',10);
    fsm.handles.Tstimdurationmin = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.23 0.5 0.1 0.04],...
        'String',fsm.Tstimdurationmin,'FontSize',10,...
        'TooltipString','Minimum duration of relevant stimuli');
    %
    % T stim duration mean additional
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.45 0.2 0.04],...
        'String','T stim duration mean added','FontSize',10);
    fsm.handles.Tstimdurationmeanadd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.23 0.45 0.1 0.04],...
        'String',fsm.Tstimdurationmeanadd,'FontSize',10,...
        'TooltipString','Mean added random jitter to duration of relevant stimuli');
    %
    % T reward available
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.4 0.2 0.04],...
        'String','T reward available','FontSize',10);
    fsm.handles.Trewdavailable = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.23 0.4 0.1 0.04],...
        'String',fsm.Trewdavailable,'FontSize',10,...
        'TooltipString','Time during relevant rewarded stimuli in which mouse licking will trigger a hit and reward');
    
    % inter trial interval
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.35 0.2 0.04],...
        'String','Inter trial interval','FontSize',10);
    fsm.handles.Titi = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.23 0.35 0.1 0.04],...
        'String',fsm.Titi,'FontSize',10,...
        'TooltipString','Delay between end of trial and start of next');
    
    % Orientation difference list
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.3 0.2 0.04],...
        'String','Orientation difference list','FontSize',10);
    fsm.handles.oridifflist = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.23 0.3 0.1 0.04],...
        'String',num2str(fsm.oridifflist),'FontSize',10,...
        'TooltipString','Orientation differences to be used in session - can be presented pseudorandomly or in blocks');
    %
    % Prob reward trials
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.25 0.2 0.04],...
        'String','Prob. reward trials','FontSize',10);
    fsm.handles.prewd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.23 0.25 0.1 0.04],...
        'String',fsm.prewd,'FontSize',10,...
        'TooltipString','Probability that upcoming relevant stimulus will be rewarded');
    
    % Rewd valve duration
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.2 0.2 0.04],...
        'String','Reward valve duration','FontSize',10);
    fsm.handles.rewd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.23 0.2 0.1 0.04],...
        'String',fsm.rewd,'FontSize',10,...
        'TooltipString','Duration for which reward valve opens - determines size of reward');
    %{
    % Starting Contrast
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.15 0.2 0.04],...
        'String','Starting contrast','FontSize',10);
    fsm.handles.contrast = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.23 0.15 0.1 0.04],...
        'String',fsm.contrast,'FontSize',10,...
        'TooltipString','Starting contrast of visual gratings'); 
     %}
    
   % Starting Contrast -> made half size 
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.15 0.095 0.04],...
        'String','Starting contrast','FontSize',10);
    fsm.handles.contrast = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.12 0.15 0.05 0.04],...
        'String',fsm.contrast,'FontSize',10,...
        'TooltipString','Starting contrast of visual gratings'); 

    % prob irrel stim rewarded
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.18 0.15 0.095 0.04],...
        'String','Prob Irrel Rewarded','FontSize',10);
    fsm.handles.pIrrelRwd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.28 0.15 0.05 0.04],...
        'String',fsm.pIrrelRwd,'FontSize',10,...
        'TooltipString','Probability that the irrelevent stimulus will be rewarded');
    
    % Prob irrel gratings %
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.1 0.095 0.04],...
        'String','Prob Irrel Vis','FontSize',10);
    fsm.handles.pirrel = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.12 0.1 0.05 0.04],...
        'String',fsm.pirrel,'FontSize',10,...
        'TooltipString','Probability of irrelevant grating in upcoming trial in an odour block');
    
    % Prob irrel odours %
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.18 0.1 0.095 0.04],...
        'String','Prob Irrel Odr','FontSize',10);
    fsm.handles.pirrelodr = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.28 0.1 0.05 0.04],...
        'String',fsm.pirrelodr,'FontSize',10,...
        'TooltipString','Probability of irrelevant odour in upcoming trial in a visual block (only if symmetric task checked)');
    
    % Accuracy threshold for auto switch
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.05 0.155 0.04],...
        'String','Accuracy threshold Auto switch ','FontSize',10);
    fsm.handles.accuracyThresholdAutoSwitch = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.18 0.05 0.04 0.04],...
        'String',fsm.accuracyThresholdAutoSwitch,'FontSize',10,...
        'TooltipString','Percentage of correct responses to relevant stimuli required over selected window to trigger auto-switch of block');
    
    % Auto Switch after N trials above criteria (default 75%)
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.02 0.005 0.155 0.04],...
        'String','Ntrls autoswitch window','FontSize',10);
    fsm.handles.NtrialsAutoSwitch = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.18 0.005 0.04 0.04],...
        'String',fsm.NtrialsAutoSwitch,'FontSize',10,...
        'TooltipString','Number of previous trials over which performance is measured to trigger auto-switch');
    
    % Prob laser
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.35 0.8 0.07 0.04],...
        'String','Prob laser','FontSize',10);
    fsm.handles.plaser = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.43 0.8 0.04 0.04],...
        'String',fsm.plaser,'FontSize',10,...
        'TooltipString','Probability of optogenetic laser turning on in upcoming trial');
    
    % Laser range wrt stim. inf means end with stim
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.35 0.55 0.17 0.04],...
        'String','OP laser range wrt stim','FontSize',10);
    fsm.handles.laserRange = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.53 0.55 0.08 0.04],...
        'String',fsm.laserRange,'FontSize',10,...
        'TooltipString',['Timing of laser relative to visual stimuli',char(10),...
        'Make second value = inf to have laser end at the same time as grating']);
    
    % Lick threshold
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.35 0.6 0.17 0.04],...
        'String','Lick Threshold','FontSize',10);
    fsm.handles.lickthreshold = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.53 0.6 0.08 0.04],...
        'String',fsm.lickthreshold,'FontSize',10,...
        'TooltipString','Minimum threshold for lick detector amplitude to register a lick');
    %
    % Extra wait time
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.35 0.85 0.07 0.04],...
        'String','Extra wait time','FontSize',10);
    fsm.handles.Textrawait = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.43 0.85 0.04 0.04],...
        'String',fsm.extrawait,'FontSize',10,...
        'TooltipString','Extra time for which rewarded stimulus is presented after reward has been delivered');
    
    % Horizontal position of patch
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.35 0.5 0.17 0.04],...
        'String','Stim Pos (-560 to 560)','FontSize',10);
    fsm.handles.stimPosOffset = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.53 0.5 0.08 0.04],...
        'String',fsm.stimPosOffset,'FontSize',10,...
        'TooltipString','Horizontal position of visual stimuli on screens: 0 = centre of each');
    
    % Blocks or Trial by trial changes in ori diff
    fsm.handles.blockORtbt = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','popupmenu',...
        'Position', [0.35 0.45 0.12 0.04],'String',{'Blocks (ori)','Trial By Trial (ori)'},...
        'Value',1,'FontSize',10,...
        'TooltipString','Cycle through visual stimuli orientation differences either blockwise or trial-by-trial');
    
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.48 0.45 0.07 0.04],...
        'String','Ntrl/block','FontSize',10);
    fsm.handles.nTrialsPerBlock = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.56 0.45 0.05 0.04],...
        'String',fsm.nTrialsPerBlock,'FontSize',10,...
        'TooltipString','If blockwise selected above, number of trials in each orientation block before moving to the next');
    
    % Punish time
    uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.48 0.40 0.07 0.04],...
        'String','Punish T','FontSize',10);
    fsm.handles.punishT = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.56 0.40 0.05 0.04],...
        'String',fsm.punishT,'FontSize',10,...
        'TooltipString','Time for which unrewarded stimulus continues to be presented after a false alarm');
    
    % Vis or odr block
    fsm.handles.VISorODR = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','popupmenu',...
        'Position', [0.35 0.40 0.12 0.04],'String',{'Visual','Odour'},...
        'Value',1,'FontSize',10,...
        'TooltipString','Whether upcoming trial will be an odour block or visual block');
    
    % Laser power options
    fsm.handles.laserpoweroptions_label = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.35 0.65 0.17 0.04],...
        'String','Laser powers (%):0','FontSize',10);
    fsm.handles.laserpoweroptions = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.53 0.65 0.08 0.04],...
        'String',fsm.laserpoweroptions,'FontSize',10,...
        'TooltipString',['Laser powers to use:',char(10),'If more than one power entered, will cycle through pseudorandomly']);
    
    % Number of correct visual grating responses in a row required to leave transition state
    fsm.handles.consecutiveCorrect_label = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.64 0.9 0.17 0.04],...
        'String','N transition trials','FontSize',10);
    fsm.handles.consecutiveCorrect = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.82 0.9 0.05 0.04],...
        'String',fsm.consecutiveCorrect,'FontSize',10,...
        'TooltipString',['During transition states:',char(10),'Number of correct responses to visual gratings in a row required to leave transition state']);
    
    % Number of correctly rejected irrelevant gratings required to
    % auto-switch
    fsm.handles.nIrrelTrials_label = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.64 0.85 0.17 0.04],...
        'String','N irrel trials auto-switch','FontSize',10);
    fsm.handles.nIrrelTrials = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.82 0.85 0.05 0.04],...
        'String',fsm.nIrrelTrials,'FontSize',10,...
        'TooltipString',['For auto-switching blocks:',char(10),'Number of previous trials in which all previous irrelevant grating must have been correctly rejected to trigger auto-switch']);
    
    % Mean added jitter to gap between irrel grating and odour
    fsm.handles.Tirreldelaymeanadd_label = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.64 0.80 0.17 0.04],...
        'String','T irrel delay mean added','FontSize',10);
    fsm.handles.Tirreldelaymeanadd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.82 0.80 0.05 0.04],...
        'String',fsm.Tirreldelaymeanadd,'FontSize',10,...
        'TooltipString','Mean added random jitter to delay between irrel grating and odour');
    
    % Maximum block size before auto-switching (only applies during
    % auto-switch)
    fsm.handles.maxBlockSize_label = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.64 0.75 0.17 0.04],...
        'String','Maximum block size','FontSize',10);
    fsm.handles.maxBlockSize = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.82 0.75 0.05 0.04],...
        'String',fsm.maxBlockSize,'FontSize',10,...
        'TooltipString',['If auto-switch is enabled, maximum size of block before block switch occurs automatically',char(10),'0 = no maximum block size']);
    
    
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
        'Value',1,'FontSize',10,...
        'TooltipString','Rewarded trials that mice miss will still trigger a reward');
    
    % Transition states
    fsm.handles.transition = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','checkbox',...
        'Position', [0.48 0.75 0.13 0.04],'String','Transition states',...
        'Value',0,'FontSize',10,...
        'TooltipString','After switching block, mouse will be presented with rewarded visual stimuli only until correct responses have been given');
    
    % Only laser
    fsm.handles.onlylaser = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','checkbox',...
        'Position', [0.48 0.7 0.1 0.04],'String','Only laser',...
        'Value',0,'FontSize',10,...
        'TooltipString','Disable visual/odour stimuli, only present laser during trials');
    
    % Single or double monitor
    fsm.handles.twomonitors = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','checkbox',...
        'Position', [0.48 0.8 0.13 0.04],'String','Two Monitors','Callback', @twoMonitor_callback, ...
        'Value',1,'FontSize',10,...
        'TooltipString','Use two monitors / only use left monitor');
    
    % Symmetric version of task
    fsm.handles.symmetricTask = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','checkbox',...
        'Position', [0.48 0.85 0.13 0.04],'String','Symmetric', ...
        'Value',0,'FontSize',10,...
        'TooltipString','Use symmetrical version of task, with irrelevant odours in visual block');
    
    % Auto Switch
    fsm.handles.autoSwitch = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','checkbox',...
        'Position', [0.23 0.005 0.12 0.04],'String','AutoSwitch', ...
        'Value',0,'FontSize',10,...
        'TooltipString','Enable auto-switching between blocks');
    
    % Laser on during inter-trial-interval
    fsm.handles.itiLaser = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','checkbox',...
        'Position', [0.88 0.9 0.12 0.04],'String','ITI laser','TooltipString','Laser on only in inter-trial-interval', ...
        'Value',0,'FontSize',10);
    
    % Laser on outside of visual stimuli
    fsm.handles.nonVisualLaser = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','checkbox',...
        'Position', [0.88 0.85 0.12 0.04],'String','Non-vis laser','TooltipString','Laser on during all non-visual portions of a trial.', ...
        'Value',0,'FontSize',10);
    
    % Constant laser
    fsm.handles.constantLaser = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','checkbox',...
        'Position', [0.88 0.8 0.12 0.04],'String','Constant laser','TooltipString','Laser on throughout trial', ...
        'Value',0,'FontSize',10);
    
    
    
    %%%% Drop-down menus %%%%
    
    % Laser offsets relative to switch
    
    fsm.handles.laserOffset_label = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.64 0.685 0.10 0.04],...
        'String','Laser offset','FontSize',10);
    fsm.handles.laserOffset = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','popupmenu',...
        'Position', [0.75 0.65 0.12 0.08],'String',{'Off','0','1','3'},'TooltipString',['Number of trials for which to delay laser onset, following auto-switch to visual',char(10),'0 = wait for one trial, 1 = wait for one hit, 3 = wait for 3 consecutive hits'], ...
        'Value',1,'FontSize',10);
    
    % Alternating blocks of laser/no laser
    
    fsm.handles.alternateLaser_label = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
        'Position', [0.64 0.635 0.10 0.04],...
        'String','Alternate laser','FontSize',10);
    fsm.handles.alternateLaser = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','popupmenu',...
        'Position', [0.75 0.6 0.12 0.08],'String',{'Off','No laser','Laser'},'TooltipString',['Whether to alternate laser for pairs of olfactory/visual blocks',char(10),'No laser = first odour block laser off, Laser = first odour block laser on'], ...
        'Value',1,'FontSize',10);
    
    
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
        'String','OriMap params', 'BackgroundColor', 'cyan','Callback', @call_setOrimapParams,...
        'TooltipString','Enable orientation mapping parameters');
    
    % Re-throw trial button
    fsm.handles.rethrowTrial = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','pushbutton',...
        'Position', [0.23 0.05 0.13 0.04],...
        'String','Re-throw trial', 'BackgroundColor', 'blue','ForegroundColor','white','Callback', @call_rethrowTrial,...
        'TooltipString','Re-start current trial with current parameters');
    
    % Speed monitor
    fsm.handles.speedMonitorFlag = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','togglebutton',...
        'Position', [0.75 0.95 0.13 0.04],'String','SPEED MONITOR','FontWeight','bold',...
        'Value',0,'FontSize',10,'BackgroundColor', 'white','Callback',@call_speedMonitor,...
        'TooltipString','Show and run speed monitor trace');
    
    %--------------------------------------------------------------------------
    % End make GUI
end

% start serial port
fsm.comport = 'COM4'; % Overwrite in the case of some error
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
    iwT  = str2num(get(fsm.handles.Tirreldelay,'string')) + exprnd(str2num(get(fsm.handles.Tirreldelaymeanadd,'string')));
    spdT = str2num(get(fsm.handles.Tspeedmaintainmin,'string')) + exprnd(str2num(get(fsm.handles.Tspeedmaintainmeanadd,'string')));
    stmT = str2num(get(fsm.handles.Tstimdurationmin,'string')) + rand*str2num(get(fsm.handles.Tstimdurationmeanadd,'string'));
    fsm.stmT = stmT;
    %     %if stimT>5;stimT=rand*5;end
    waitT = str2num(get(fsm.handles.Trewdavailable,'string'));
    rewT  = str2num(get(fsm.handles.rewd,'string'));
    iti   = str2num(get(fsm.handles.Titi,'string'));
    extraT= str2num(get(fsm.handles.Textrawait,'string'));
    fsm.itiLaser = get(fsm.handles.itiLaser ,'Value'); % whether laser timing is confined to ITI window
    
    if get(fsm.handles.alternateLaser','value') == 0
        fsm.constantLaser = get(fsm.handles.constantLaser ,'Value'); % laser on throughout trial, but only if not using alternating laser
    end
    
    fsm.nonVisualLaser = get(fsm.handles.nonVisualLaser ,'Value'); % whether laser should be on in all non-visual sections of a trial.
    
    %     mcvT  = str2num(get(fsm.handles.Tminorientationview,'string'));
    pT    = str2num(get(fsm.handles.punishT,'string'));
    %     fsm.contrast = str2num(get(fsm.handles.contrast,'string'));
    pL    = str2num(get(fsm.handles.plaser,'string'));
    % put current values in textboxes
    set(fsm.handles.Tspeedmaintainmin_label,'string',['T speed maintain min (' sprintf('%.2f',spdT) ')'])
    %     fsm.orientationchange = str2num(get(fsm.handles.orientationchange,'String'));
    %     if ~fsm.iscuetrial ; cueT = 0; end
    %     fsm.difflist = str2num(get(fsm.handles.orientationchangelist,'String'));

    
    % digiOut mapping
    R   =  2^0; %teensy pin 2, reward
    Vis1 = 2^1; %teensy pin 3, visual stim 1 rewarded
    Vis2 = 2^2; %teensy pin 4, visual stim 2 non rewarded
    Odr1 = 2^3; %teensy pin 5, odour1 rewarded
    Odr2 = 2^4; %teensy pin 6, odour2 non rewarded
    Bln  = 2^5; %teensy pin 7, blank odour
    Irr  = 2^6; %teensy pin 8, Irrelevant vis, should be on with the vis bit
    L    = 2^7; %teensy pin 9, trigger for optogenetic laser
    
    
    if fsm.trialnum == 0 % only on first trial
        fsm.tempFName = sprintf('%s%s_%s_tempFSM.mat',fsm.savedir,datestr(datetime,'yyyymmdd_HHMMSS'),get(fsm.handles.token,'string'));
        starting_fsm_parameters = fsm;
        starting_fsm_parameters = rmfield(starting_fsm_parameters,'handles');
        save(fsm.tempFName,'starting_fsm_parameters'); % make temporary fsm file with starting parameters
        clear starting_fsm_parameters;
    end
    
    Rew = R;
    iStim = 0;
    irDelay = 11;
    
    switch fsm.stimtype(fsm.trialnum+1)% 1 = vis rewarded, 2 = vis not rewarded, 3 = Odr rewarded, 4 = odr not rewarded
        case 1 % vis rewarded
            %IR = 3;  % no irrel grating
            Stim = Vis1+Bln;% rewarded grating (+45 degrees)
            lok1 = 5;% rewd
            fa = 3;% refractory period
            
            if fsm.irrelodour(fsm.trialnum+1) == 1 % if symmetrical task
                IR = 10;  %Irrel odour on
                IR2 = 16;
                if fsm.odour(fsm.trialnum+1) == 1
                    iStim = Odr1+Irr;% Odour1
                else
                    iStim = Odr2+Irr;% Odour2
                end
            else
                
                IR = 3; % no irrel grating
                IR2 = 15;
            end
            
            % auto reward or not
            if get(fsm.handles.autorewd ,'Value')==1
                AR = 7;
            else
                AR = 13;
            end
            Rew = Rew+Vis1+Bln;
        case 2 % vis non rewarded
            %IR = 3;  %
            Stim = Vis2+Bln;% non rewarded grating (-45 degrees)
            lok1 = 8;% punish
            fa = 8;% punish
            
            waitT = 1;% hard-coded! 05-09-17, to make non rew stim not stay on too long if you need to increase Trewdavailable
            AR = 9; % no auto reward
            
            
            if fsm.irrelodour(fsm.trialnum+1) == 1 % if symmetrical task
                IR = 10;  %Irrel odour on
                IR2 = 16;
                if fsm.odour(fsm.trialnum+1) == 1
                    iStim = Odr1+Irr;% Odour1
                else
                    iStim = Odr2+Irr;% Odour2
                end
            else
                IR = 3; % no irrel grating
                IR2 = 15;
            end
            
        case 3 % odour rewarded
            Stim = Odr1;% Odr1
            lok1 = 5;% rewd
            fa = 3;% refractory period
            
            if fsm.irrelgrating(fsm.trialnum+1) == 1;
                IR = 10;  %Irrel grating on
                IR2 = 16;
                if fsm.orientation(fsm.trialnum+1) == fsm.stim1ori;
                    iStim = Vis1+Irr+Bln;% +45 degrees
                else
                    iStim = Vis2+Irr+Bln;% -45 degrees
                end
            else
                IR = 3; % no irrel grating
                IR2 = 15;
            end
            
            % auto reward or not
            if get(fsm.handles.autorewd ,'Value')==1
                AR = 7;
            else
                AR = 13;
            end
            Rew = Rew+Odr1;
        case 4 % odour non rewarded
            Stim = Odr2;% Odr2
            lok1 = 8;% punish
            fa = 8;% punish
            
            if fsm.irrelgrating(fsm.trialnum+1) == 1;
                IR = 10;  %Irrel grating on
                IR2 = 16;
                if fsm.orientation(fsm.trialnum+1) == fsm.stim1ori;
                    iStim = Vis1+Irr+Bln;% +45 degrees
                else
                    iStim = Vis2+Irr+Bln;% -45 degrees
                end
            else
                IR = 3; % no irrel grating
                IR2 = 15;
            end
            AR = 9; % no auto reward
            
    end
    pwr = 0; % analog output, just laser
    pwrRel = 0; % analog output, laser with rel stim
    pwrIrr = 0; % analog output, laser with irrel stim
    pwrITI = 0; % analog output, laser during inter-trial-interval
    
    % if only laser trials (OP)
    if get(fsm.handles.onlylaser,'Value')
        Stim = Bln;Rew = Bln; iStim = Bln; % no stim signals
        pL = 1; %Force laser trials
        set(fsm.handles.autorewd, 'Value',0)
        set(fsm.handles.VISorODR, 'Value',1)
        %set(fsm.handles.laserRange,'string','-1.5,0')
        fa = 3;
        lok1=5;
        waitT = 0;rewT=0;extraT=0;
    end
    
    irrL = 0; % laser during irrel stimuli
    relL = 0; % laser during rel stimuli
    itiL = 0; % laser during inter-trial-interval. Everything not stimulus.
    trueITIL = 0; % laser during the delay between one trial and the next specifically.
    
    Gap = 0; % gap between end of laser and end of stim
    
    IR3 = IR; % sequence of states dependent on laser timing
    
    if fsm.laserOffsetOn && ~fsm.constantLaser % if laser is offset at start of visual blocks
        pL = 0;
    elseif fsm.laserOffsetOn && fsm.constantLaser % if using constant laser suppression, want signal to = 0 during offset trials
        pL = 1;
    end
    % if using laser offset and constant suppression signal for 40Hz laser
    if get(fsm.handles.laserOffset','value') > 1 && ~fsm.laserOffsetOn
        pL = 0;
    end
    
    % if laser trial
    if rand < pL  && ~fsm.itiLaser && ~fsm.constantLaser && get(fsm.handles.alternateLaser','value') == 0
        LR = 12;
        
        % choose laser power (PWM)
        powers = str2num(get(fsm.handles.laserpoweroptions,'string'));
        if rem(fsm.trialnum,length(powers)) == 0
            fsm.plist = randperm(length(powers));
        end
        pwr = powers(fsm.plist(rem(fsm.trialnum,length(powers))+1));
        
        fsm.laserpower(fsm.trialnum+1) = pwr;
        set (fsm.handles.laserpoweroptions_label,'String',['Laser powers (%):' num2str(pwr)]);
        pwr = round(pwr*4095/100); % 0-4095, 12 bit resolution for analog out
        
        % set laser onset times
        laserRange = str2num(get(fsm.handles.laserRange,'string'));
        assert(laserRange(1)<=0,'Laser range first number must be 0 or negative')
        assert(laserRange(1)<laserRange(2),'Laser range first must be smaller')
        Lpre = -laserRange(1);
        Lpst = laserRange(2);
        
        if laserRange(2)<0
            IR3 = 17; % if laser needs to go off and then gap before stim comes on
            Lpre = laserRange(2)-laserRange(1);
            Gap = abs(laserRange(2));
        else
            IR3 = IR2;
        end
        
        if laserRange(2)>=0 % if laser continues into stim
            if Lpst>stmT % if laser goes on longer than min view time, it will stay on till end of stim
                Lpst = stmT;
                pwrIrr = pwr;
                irrL = L;% Make irrL = L if laser is staying on longer than min view time ie going on till end, && not an odour trial
                if Stim~=(Odr1)&& Stim~=(Odr2) % no laser on odor
                    relL = L; % Make relL also = L if in addition its not an odour trial
                    pwrRel = pwr;
                elseif IR == 3 % if an odour trial without irrel grating (should be no laser)
                    pwrIrr = 0;
                    irrL = 0;
                    pwr = 0;
                    Lpst = 0;
                    Lpre = 0;
                    relL = 0;
                    pwrRel = 0;
                end
            else
                pwrRel = 0;
                pwrIrr = 0;
                irrL = 0;
                relL = 0;
            end
        end
    elseif rand < pL &&  (fsm.itiLaser || fsm.constantLaser || fsm.nonVisualLaser) % laser on during inter-trial-interval / whole trial
        
        LR = IR;
        
        % choose laser power (PWM)
        powers = str2num(get(fsm.handles.laserpoweroptions,'string'));
        if rem(fsm.trialnum,length(powers)) == 0
            fsm.plist = randperm(length(powers));
        end
        pwr = powers(fsm.plist(rem(fsm.trialnum,length(powers))+1));
        
        fsm.laserpower(fsm.trialnum+1) = pwr;
        set (fsm.handles.laserpoweroptions_label,'String',['Laser powers (%):' num2str(pwr)]);
        pwr = round(pwr*4095/100); % 0-4095, 12 bit resolution for analog out
        
        pwrITI = pwr;
        
        % laser is on during ITI period in these two conditions
        if fsm.itiLaser || fsm.constantLaser
            trueITIL = L;
        end
        
        % laser is not on during visual stimuli in these two conditions
        if fsm.itiLaser || fsm.nonVisualLaser
            Lpre = 0; % start time of laser, relative to vis stim onset
            Lpst = 0; % end time of laser, relative to vis stim onset
        end
        
        if fsm.nonVisualLaser % if laser is on between visual stimuli
            % laser is on during odour stimuli
            if Stim==Odr1 || Stim==Odr2
                relL = L;
                pwrRel = pwr;
                pwrIrr = 0;
            end
        end
        
        if fsm.constantLaser % have laser on throughout stims and ITI
            pwrIrr = pwr;
            irrL = L;
            relL = L;
            pwrRel = pwr;
            Lpre = .5;
            Lpst = stmT;
        end
        
    else % if not a laser trial
        LR = IR;
        set (fsm.handles.laserpoweroptions_label,'String',['Laser power: 0' ]);
        Lpre = 0;
        Lpst = 0;
    end
    Lon = L+Bln;
    stm = [... % remember zero indexing; units are seconds, multiplied later to ms
        
    % spd in      spd out  lick    Tup       Timer          digiOut    AnalogOut
    0           0        0       1         0.01           Bln+itiL   pwrITI  ;...% state 0 init
    14          1        1       1         100            Bln+itiL   pwrITI  ;...% state 1 wait for speed in
    2           1        2       LR        spdT-Lpre      Bln+itiL   pwrITI  ;...% state 2 maintain speed
    3           3        fa      4         stmT-Lpst      Stim+relL  pwrRel  ;...% state 3 Stim on, refractory period
    4           4        lok1    AR        waitT          Stim+relL  pwrRel  ;...% state 4 Stim on, reward zone, wait for lick
    5           5        5       6         rewT           Rew+relL   pwrRel  ;...% state 5 Stim on, reward on
    6           6        6       9       extraT           Stim+relL  pwrRel  ;...% state 6 Stim on, extra view
    7           7        7       6         rewT           Rew+relL   pwrRel  ;...% state 7 auto reward
    8           8        8       4         pT             Stim+relL  pwrRel  ;...% state 8 punish time
    9           9        9       99        iti            Bln+trueITIL   pwrITI  ;...% state 9 ITI
    10          10       34      30        (igT-Lpst)/5   iStim+irrL pwrIrr  ;...% state 10 irrel grating
    11          11       11      3         iwT            Bln+itiL   pwrITI  ;...% state 11 delay after irrel grating
    12          12       12      IR3       Lpre           Lon        pwr     ;...% state 12 laser on pre stim
    13          13       13      9         .01            Bln+relL   pwr     ;...% state 13 Miss
    14          14       14      2         .2             Bln+itiL   pwrITI  ;...% state 14 to prevent fast transitions
    15          15       15      3         Lpst           Stim+L     pwr     ;...% state 15 stim on + laser on continuing into stim (used in case laser is on after stim but for less than min view time)
    16          16       25      21        Lpst/5         iStim+L    pwr     ;...% state 16 istim on + laser on continuing into istim, lick here will lead to catch state
    17          17       17      IR        Gap            Bln        0       ;...% state 17 In case gap after laser off and stim on
    0           0         0      0         0              0          0       ;...% state 18 blank for future use
    0           0        0       0         0              0          0       ;...% state 19 blank for future use
    0           0        0       0         0              0          0       ;...% state 20 blank for future use
    
    % (coming from laser+iStim) licks here will lead to catch states
    21          21       26      22        Lpst/5         iStim+L    pwr     ;...% state 21 istim on + laser on continuing into istim (1/5th to allow recording FA on irrels)
    22          22       27      23        Lpst/5         iStim+L    pwr     ;...% state 22 istim on + laser on continuing into istim (1/5th to allow recording FA on irrels)
    23          23       28      24        Lpst/5         iStim+L    pwr     ;...% state 23 istim on + laser on continuing into istim (1/5th to allow recording FA on irrels)
    24          24       29      10        Lpst/5         iStim+L    pwr     ;...% state 24 istim on + laser on continuing into istim (1/5th to allow recording FA on irrels)
    
    % catch states
    25          25       25      26        Lpst/5         iStim+L    pwr     ;...% state 25 istim on + laser on continuing into istim (1/5th to allow recording FA on irrels)
    26          26       26      27        Lpst/5         iStim+L    pwr     ;...% state 26 istim on + laser on continuing into istim (1/5th to allow recording FA on irrels)
    27          27       27      28        Lpst/5         iStim+L    pwr     ;...% state 27 istim on + laser on continuing into istim (1/5th to allow recording FA on irrels)
    28          28       28      29        Lpst/5         iStim+L    pwr     ;...% state 28 istim on + laser on continuing into istim (1/5th to allow recording FA on irrels)
    29          29       29      10        Lpst/5         iStim+L    pwr     ;...% state 29 istim on + laser on continuing into istim (1/5th to allow recording FA on irrels)
    
    % (coming from iStim) licks here will lead to catch states
    30          30       35      31        (igT-Lpst)/5   iStim+irrL   pwrIrr  ;...% state 30 istim on (1/5th to allow recording FA on irrels)
    31          31       36      32        (igT-Lpst)/5   iStim+irrL   pwrIrr  ;...% state 31 istim on (1/5th to allow recording FA on irrels)
    32          32       37      33        (igT-Lpst)/5   iStim+irrL   pwrIrr  ;...% state 32 istim on (1/5th to allow recording FA on irrels)
    33          33       38      11        (igT-Lpst)/5   iStim+irrL   pwrIrr  ;...% state 33 istim on (1/5th to allow recording FA on irrels)
    
    % catch states
    34          34       34      35        (igT-Lpst)/5   iStim+irrL   pwrIrr  ;...% state 34 istim on (1/5th to allow recording FA on irrels)
    35          35       35      36        (igT-Lpst)/5   iStim+irrL   pwrIrr  ;...% state 35 istim on (1/5th to allow recording FA on irrels)
    36          36       36      37        (igT-Lpst)/5   iStim+irrL   pwrIrr  ;...% state 36 istim on (1/5th to allow recording FA on irrels)
    37          37       37      38        (igT-Lpst)/5   iStim+irrL   pwrIrr  ;...% state 37 istim on (1/5th to allow recording FA on irrels)
    38          38       38      11        (igT-Lpst)/5   iStim+irrL   pwrIrr  ;...% state 38 istim on (1/5th to allow recording FA on irrels)
    
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
fsm.lickThreshByTrial(fsm.trialnum+1) = str2num(get(fsm.handles.lickthreshold,'string'));

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
                
                % save fsm structure to temporary fsm file, in case of crashes
                fsm_temp = fsm;
                fsm = rmfield(fsm,'handles');% to avoid saving figure
                save(fsm.tempFName,'fsm');
                fsm = fsm_temp; clear fsm_temp;
                
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
fsm.accuracyThresholdAutoSwitch = str2num(get(fsm.handles.accuracyThresholdAutoSwitch,'string'));
fsm.Tspeedmaintainmeanadd = str2num(get(fsm.handles.Tspeedmaintainmeanadd,'string'));
fsm.Tstimdurationmeanadd = str2num(get(fsm.handles.Tstimdurationmeanadd,'string'));
fsm.Tspeedmaintainmin = str2num(get(fsm.handles.Tspeedmaintainmin,'string'));
fsm.NtrialsAutoSwitch = str2num(get(fsm.handles.NtrialsAutoSwitch,'string'));
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
fsm.pIrrelRwd = str2num(get(fsm.handles.pIrrelRwd,'string'));
fsm.punishT = str2num(get(fsm.handles.punishT,'string'));
fsm.pirrel = str2num(get(fsm.handles.pirrel,'string'));
fsm.prewd = str2num(get(fsm.handles.prewd,'string'));
fsm.rewd = str2num(get(fsm.handles.rewd,'string'));
fsm.Titi = str2num(get(fsm.handles.Titi,'string'));
fsm.consecutiveCorrect = str2num(get(fsm.handles.consecutiveCorrect,'string'));
fsm.nIrrelTrials = str2num(get(fsm.handles.nIrrelTrials,'string'));

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
% delete the temporary fsm file
if isfile(fsm.tempFName)
    delete(fsm.tempFName);
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
fsm.irrelodour = [];
fsm.TspeedMaintainMinByTrial = [];
fsm.TspeedMaintainMeanAddbyTrial = [];
fsm.spdRngLowByTrial = [];
fsm.punishTByTrial = [];
fsm.pirrelByTrial = [];
fsm.pirrelodrByTrial = [];
fsm.prewdByTrial = [];

fsm.lickThreshByTrial = [];
fsm.transitionState = 0;
fsm.laserOffsetOn = 0;
fsm.contrastByTrial = [];

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
speedMonitorFlag = get(fsm.handles.speedMonitorFlag,'Value');
if speedMonitorFlag
    fsm.npointsX = round(fsm.spdxrng/fsm.spdavgbin);
    fsm.handles.spdplot = plot(fsm.handles.ax(1),1:fsm.npointsX,ones(fsm.npointsX,1),'k','linewidth',2);
    fsm.handles.spdRngHiLine = line([0 fsm.npointsX],[fsm.spdrnghigh fsm.spdrnghigh],'Linestyle','--','Linewidth',2,'Color','k','Parent',fsm.handles.ax(1));
    fsm.handles.spdRngLoLine = line([0 fsm.npointsX],[fsm.spdrnglow fsm.spdrnglow],'Linestyle','--','Linewidth',2,'Color','k','Parent',fsm.handles.ax(1));
    
    set(fsm.handles.ax(1),'xticklabel',[],'ylim',[-10,fsm.spdylim],'xlim',[0,fsm.npointsX])
end

function call_change_spdrnghigh(src,eventdata)
global fsm
fsm.spdrnghigh = str2num(get(fsm.handles.spdrnghigh,'string'));
speedMonitorFlag = get(fsm.handles.speedMonitorFlag,'Value');
if speedMonitorFlag
    set(fsm.handles.spdRngHiLine,'ydata',[fsm.spdrnghigh;fsm.spdrnghigh]);
end
%ylim([-10 fsm.spdylim]);

function call_change_spdrnglow(src,eventdata)
global fsm
speedMonitorFlag = get(fsm.handles.speedMonitorFlag,'Value');
fsm.spdrnglow = str2num(get(fsm.handles.spdrnglow,'string'));
if speedMonitorFlag
    set(fsm.handles.spdRngLoLine,'ydata',[fsm.spdrnglow;fsm.spdrnglow]);
end
%ylim([-10 fsm.spdylim]);

function call_change_spdylim(src,eventdata)
global fsm
speedMonitorFlag = get(fsm.handles.speedMonitorFlag,'Value');
if speedMonitorFlag
    fsm.spdylim = str2num(get(fsm.handles.spdylim,'string'));
    set(fsm.handles.ax(1),'ylim',[-10 fsm.spdylim]);
end

function call_change_spdxrng(src,eventdata)
global fsm
speedMonitorFlag = get(fsm.handles.speedMonitorFlag,'Value');
if speedMonitorFlag
    fsm.spdxrng = str2num(get(fsm.handles.spdxrng,'string'));
    Xrng_speed_plot
end

function findoutcome(triallog)
global fsm
% hit: 4 to 5, CR 4 to 9, miss 4 to 13 or 4 to 7  , FA 4 to 8 or 3 to 8
% 1:hit  2:CR   3:miss   4:FA
if ~isempty(strfind(triallog, '4to7'))||~isempty(strfind(triallog, '4to13')); fsm.outcome(fsm.trialnum) = 3;fprintf('Miss\n');% miss
elseif ~isempty(strfind(triallog, '4to5')); fsm.outcome(fsm.trialnum) = 1; fprintf('Hit\n');% hit
elseif ~isempty(strfind(triallog, '4to8'))||~isempty(strfind(triallog, '3to8')); fsm.outcome(fsm.trialnum) = 4;fprintf('FA\n');% FA
elseif ~isempty(strfind(triallog, '4to9')) || ~isempty(strfind(triallog, '4to39')); fsm.outcome(fsm.trialnum) = 2;fprintf('CR\n');% CR
else error ('here');
end

% Also find FAs to Irrel stims (FAirrel)
% FAirrel:  from laser on period 16 to 25, 21 to 26, 22 to 27, 23 to 28, 24 to 29, or not from laser on period 10 to 34, 30 to 35, 31 to 36, 32 to 37, 33 to 38
if ~isempty(strfind(triallog, '16to25'))||~isempty(strfind(triallog, '21to26'))||~isempty(strfind(triallog, '22to27'))||~isempty(strfind(triallog, '23to28'))...
        ||~isempty(strfind(triallog, '24to29'))||~isempty(strfind(triallog, '10to34'))||~isempty(strfind(triallog, '30to35'))||~isempty(strfind(triallog, '31to36'))...
        ||~isempty(strfind(triallog, '32to37'))||~isempty(strfind(triallog, '33to38'))
    fsm.FAirrelOutcome(fsm.trialnum) = 1;fprintf('FA Irrel\n');% FA irrel
elseif fsm.irrelgrating(fsm.trialnum) == 1 % if its an irrel grating trial & no FA
    fsm.FAirrelOutcome(fsm.trialnum) = 0;fprintf('CR Irrel\n');% CR irrel
else
    fsm.FAirrelOutcome(fsm.trialnum) = NaN; % Not an irrel trial
end

% update performance plot
% 20 trial window
mrks = {'ro','k*','b^'};
correcttrials = (fsm.outcome == 1) + (fsm.outcome == 2);
yplot = [];
for i = 1:length(correcttrials)
    yplot(i) = mean(correcttrials(max([1 i-20]):i))*100;
    yplotFAirrel(i) = nanmean(fsm.FAirrelOutcome(max([1 i-20]):i))*100;
end
if length(correcttrials)>=5
    VISorODR = get(fsm.handles.VISorODR,'Value');
    plot(fsm.handles.ax(2),length(correcttrials),yplot(end),mrks{VISorODR});
    if VISorODR == 2
        hold on;
        plot(fsm.handles.ax(2),length(correcttrials),yplotFAirrel(end),mrks{3});
    end
end
set(fsm.handles.ax(2),'ylim',[0 100],'xlim',[0 length(correcttrials)]);


transitionOn = get(fsm.handles.transition,'Value');

% Determine whether to leave transition state
if transitionOn
    if fsm.transitionState(fsm.trialnum) == 1 && fsm.consecutiveCorrect < fsm.trialnum % if in transition state
        if fsm.VISorODR(end) == 1 % if in visual block
            if all(fsm.outcome(end-fsm.consecutiveCorrect+1:end)==1) && all(fsm.transitionState(end-fsm.consecutiveCorrect+1:end))
                fsm.transitionState(fsm.trialnum+1) = 0;
                fprintf('END OF TRANSITION STATE\n');
            else
                fsm.transitionState(fsm.trialnum+1) = 1;
            end
        else % if in odour block
            if all(fsm.FAirrelOutcome(end-fsm.consecutiveCorrect+1:end)==0) && all(fsm.transitionState(end-fsm.consecutiveCorrect+1:end))
                fsm.transitionState(fsm.trialnum+1) = 0;
                fprintf('END OF TRANSITION STATE\n');
            else
                fsm.transitionState(fsm.trialnum+1) = 1;
            end
        end
    else
        fsm.transitionState(fsm.trialnum+1) = 0;
    end
else
    fsm.transitionState(fsm.trialnum+1) = 0;
end

maxBlockSize = str2num(get(fsm.handles.maxBlockSize,'String'));
forceSwitch = 0;

% Auto change the block type
if get(fsm.handles.autoSwitch,'Value')
    % Check which block, vis or odr
    VISorODR = fsm.VISorODR;
    nIrrelTrials = str2num(get(fsm.handles.nIrrelTrials,'String'));
    accuracyThresholdAutoSwitch = str2num(get(fsm.handles.accuracyThresholdAutoSwitch,'String'));
    % work out if block has passed maximum size limit
    if maxBlockSize ~= 0 && fsm.trialnum > maxBlockSize
        if range(fsm.VISorODR(end-maxBlockSize:end)) == 0 % if all trials in the range are the same
            forceSwitch = 1;
        end
    end
    % check how many trials of this block have been performed using fsm.VISorODR
    lastBlockChange = find(diff(VISorODR),1,'last');
    ntrlsSinceLastBlockChange = length(VISorODR)-lastBlockChange;
    if isempty(ntrlsSinceLastBlockChange); ntrlsSinceLastBlockChange = fsm.trialnum;end
    if forceSwitch % ignore auto-switch window if max block size has been reached
        NtrialsAutoSwitch = 0;
    else
        NtrialsAutoSwitch = str2num(get(fsm.handles.NtrialsAutoSwitch,'String'));
    end
    if (ntrlsSinceLastBlockChange >= NtrialsAutoSwitch && ntrlsSinceLastBlockChange >= nIrrelTrials)  || forceSwitch % if more than NtrialsAutoSwitch trials in this block
        if VISorODR(end) == 1 % if visual block then just check accuracy on visual
            if (mean(correcttrials(end-NtrialsAutoSwitch+1:end))*100 > accuracyThresholdAutoSwitch ... % if visual performance is above performance threshold
                    && ~any(fsm.transitionState(end-NtrialsAutoSwitch+1:end))) ... % and none of the trials in the window were transition trials
                    || forceSwitch
                set(fsm.handles.VISorODR,'Value',2)
                fprintf('AUTO SWITCHED TO ODOUR BLOCK!\n');
                if transitionOn; fsm.transitionState(fsm.trialnum+1) = 1; end
            end
        end
        if VISorODR(end) == 2 % if odr block then check accuracy on odour and also FAirrel
            if ((mean(correcttrials(end-NtrialsAutoSwitch+1:end))*100) > accuracyThresholdAutoSwitch ... % if odour performance is above performance threshold
                    && ~any(fsm.FAirrelOutcome(end-nIrrelTrials+1:end)==1) ... % and no irrelevant FAs in set window of trials
                    && ~any(fsm.transitionState(end-NtrialsAutoSwitch+1:end))) ... % and none of the trials in the window were transition trials
                    || forceSwitch
                set(fsm.handles.VISorODR,'Value',1)
                fprintf('AUTO SWITCHED TO VISUAL BLOCK!\n');
                if transitionOn
                    fsm.transitionState(fsm.trialnum+1) = 1;
                    if get(fsm.handles.laserOffset','value') > 1
                        fsm.laserOffsetOn = 1;
                    end
                end
            end
        end
    end
end


% Making a plot of the performance dependent on orientation.
% - Need to make it solely for visual block trials.
oriPerf= cell(720,1);
for j = 1:length(correcttrials)
    if fsm.VISorODR(j) == 1
        oriPerf{fsm.oridiff(j)}(end+1) = correcttrials(j);
    end
end
oriPerfIndex = find(~cellfun('isempty', oriPerf) & cellfun('length', oriPerf)>5);
oriPerfMean = cellfun(@mean, oriPerf, 'uni', 0);

scatter(fsm.handles.ax(4), oriPerfIndex, [oriPerfMean{oriPerfIndex, :}])
hold(fsm.handles.ax(4),'on');
plot(fsm.handles.ax(4), oriPerfIndex,  [oriPerfMean{oriPerfIndex, :}])
hold(fsm.handles.ax(4),'off');
set(fsm.handles.ax(4),'ylim',[0 1],'xlim',[0 50]);

function choose_stim
global fsm

% Check which block, vis or odr
VISorODR   = get(fsm.handles.VISorODR,'Value');

% if using laser offset on first visual block trials
if fsm.laserOffsetOn == 1
    laserOffsetTrials = get(fsm.handles.laserOffset','value');
    switch laserOffsetTrials
        case 1
            fsm.laserOffsetOn = 0;
        case 2 % after one miss/any outcome
            if fsm.transitionState(fsm.trialnum) == 1
                fsm.laserOffsetOn = 0; % return to normal p laser
            end
        case 3 % after one hit
            if fsm.outcome(fsm.trialnum) == 1 && fsm.transitionState(fsm.trialnum) == 1
                fsm.laserOffsetOn = 0;
            end
        case 4 % after three hits
            if all(fsm.outcome(fsm.trialnum-2:fsm.trialnum) == 1) && all(fsm.transitionState(fsm.trialnum-2:fsm.trialnum) == 1)
                fsm.laserOffsetOn = 0;
            end
    end
end

% if using alternating laser on switches v2o
if fsm.trialnum > 0
    if VISorODR == 2 && fsm.VISorODR(fsm.trialnum) == 1 % if switching v2o
        fsm.switchCount = fsm.switchCount + 1; % count number of switches
        % remember that constant laser is used as a suppression signal
        % so constantLaser = 1 means laser is off
        if rem(fsm.switchCount,2) == get(fsm.handles.alternateLaser','value') % if no laser on first switch, and on first switch
            fsm.constantLaser = 1;
        elseif rem(fsm.switchCount,2) == 0 && get(fsm.handles.alternateLaser','value') == 1 % if no laser on first switch, but on second switch
            fsm.constantLaser = 0;
        elseif rem(fsm.switchCount,2) == 1 && get(fsm.handles.alternateLaser','value') == 2 % if laser on first switch, and on first switch
            fsm.constantLaser = 0;
        elseif rem(fsm.switchCount,2) == 0 && get(fsm.handles.alternateLaser','value') == 2 % if laser on first switch, but on second switch
            fsm.constantLaser = 1;
        end
    end
end

fsm.oridifflist =  str2num(get(fsm.handles.oridifflist,'String'));

fsm.contrastlist = str2num(get(fsm.handles.contrast,'string'));
if all(fsm.handles.setOrimapParams.BackgroundColor == [1,0,0]) && rand < 1/((length(fsm.oridifflist)*length(fsm.contrastlist))+1) && fsm.includeBlankOrimapTrials
    fsm.contrast = 0;
else
    fsm.contrast = fsm.contrastlist(randi([1, length(fsm.contrastlist)]));
end
fsm.contrastByTrial(fsm.trialnum+1) = fsm.contrast;

fsm.TspeedMaintainMinByTrial(fsm.trialnum+1) = str2num(get(fsm.handles.Tspeedmaintainmin,'String'));
fsm.TspeedMaintainMeanAddbyTrial(fsm.trialnum+1) = str2num(get(fsm.handles.Tspeedmaintainmeanadd,'String'));
fsm.spdRngLowByTrial(fsm.trialnum+1) = str2num(get(fsm.handles.spdrnglow,'String'));
fsm.punishTByTrial(fsm.trialnum+1) = str2num(get(fsm.handles.punishT,'String'));
fsm.pirrelByTrial(fsm.trialnum+1) = str2num(get(fsm.handles.pirrel,'String'));
fsm.pirrelodrByTrial(fsm.trialnum+1) = str2num(get(fsm.handles.pirrelodr,'String'));
fsm.prewdByTrial(fsm.trialnum+1) = str2num(get(fsm.handles.prewd,'String'));


% if user has manually changed block type, force transition states
if fsm.trialnum > 2
    if fsm.VISorODR(fsm.trialnum) ~= VISorODR && get(fsm.handles.transition,'Value')
        fsm.transitionState(fsm.trialnum+1) = 1;
    end
end

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
        
        if fsm.transitionState(fsm.trialnum+1) == 1
            fsm.oridiff(fsm.trialnum+1) = max(fsm.oridifflist);
        end
        
        fsm.stim1ori = 180-fsm.oridiff(fsm.trialnum+1)/2;
        fsm.stim2ori = 180+fsm.oridiff(fsm.trialnum+1)/2;
        
        % choose rewarded or non rewarded stim
        if rand < str2num(get(fsm.handles.prewd,'String')) || fsm.transitionState(fsm.trialnum+1) == 1 % if rewarded trial
            fsm.stimtype(fsm.trialnum+1) = 1; % rewarded vis
            fsm.orientation(fsm.trialnum+1) = fsm.stim1ori;
        else
            fsm.stimtype(fsm.trialnum+1) = 2; % non rewarded vis
            fsm.orientation(fsm.trialnum+1) = fsm.stim2ori;
        end
        
        set(fsm.handles.orientation, 'String',['Orientation: ' num2str(fsm.orientation(fsm.trialnum+1))]);
        
        % select if irrelevant ODOUR presented
        if get(fsm.handles.symmetricTask,'Value') && (rand < str2num(get(fsm.handles.pirrelodr,'String'))) % Irrel odour
            fsm.irrelodour(fsm.trialnum+1) = 1;
            % select irrelevant odour
            if rand < .5
                fsm.odour(fsm.trialnum+1) = 1;
            else
                fsm.odour(fsm.trialnum+1) = 2;
            end
            set(fsm.handles.odour, 'String',['Odour: ' num2str(fsm.odour(fsm.trialnum+1))]);
        else
            fsm.irrelodour(fsm.trialnum+1) = 2; % no irrel odour
            set(fsm.handles.odour, 'String',['Odour: ']);
            fsm.odour(fsm.trialnum+1) = NaN;
        end
        
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
        if rand < str2num(get(fsm.handles.pirrel,'String')) || fsm.transitionState(fsm.trialnum+1) == 1 %
            fsm.irrelgrating(fsm.trialnum+1) = 1;
            % select irrelevant grating orientation
            if fsm.transitionState(fsm.trialnum+1) == 1
                fsm.oridiff(fsm.trialnum+1) = max(fsm.oridifflist);
            else
                rr = randi([1, length(fsm.oridifflist)]);
                fsm.oridiff(fsm.trialnum+1) = fsm.oridifflist(rr);
            end
            fsm.stim1ori = 180-fsm.oridiff(fsm.trialnum+1)/2;
            fsm.stim2ori = 180+fsm.oridiff(fsm.trialnum+1)/2;
            if rand < str2num(get(fsm.handles.pIrrelRwd,'String')) || fsm.transitionState(fsm.trialnum+1)
                fsm.orientation(fsm.trialnum+1) = fsm.stim1ori;
            else
                fsm.orientation(fsm.trialnum+1) = fsm.stim2ori;
            end
            
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

function call_rethrowTrial(~,~) % pressing re-throw trial button
global fsm
fsm.rethrowTrial = 1;
fsm.stop = 1;
fprintf(fsm.ard,'%s\n','X');
fprintf('Re-throwing trial number %d\n',fsm.trialnum);
if fsm.trialnum == 1 % in case re-throwing first trial
    fsm.orientation = [];
    fsm.trialnum = 1;
else
    fsm.trialnum = fsm.trialnum - 1;
end
make_state_matrix


function call_speedMonitor(hObject, ~, ~) % speed monitor button callback
global fsm;
button_state = get(hObject,'Value');
if button_state == get(hObject,'Max') % create speed monitor axes
    fsm.handles.ax(1)=axes('Parent',fsm.handles.f,'Units','normalized','Position',[0.65 0.55 0.33 0.4],'xticklabel',[]);
    title('Speed (cm/s)');ylim([-10 fsm.spdylim]);
    % spd ylim
    fsm.handles.spdylim = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.63 0.96 0.02 0.02],...
        'String',fsm.spdylim,'FontSize',10,'Callback', @call_change_spdylim);
    % spd xrange
    fsm.handles.spdxrng = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
        'Position', [0.97 0.52 0.02 0.02],...
        'String',fsm.spdxrng,'FontSize',10,'Callback', @call_change_spdxrng);
    Xrng_speed_plot
    set(fsm.handles.speedMonitorFlag','BackgroundColor',[0.75 0.75 0.75]);
    
    set(fsm.handles.itiLaser,'visible','off');
    set(fsm.handles.itiLaser,'visible','off');
    set(fsm.handles.consecutiveCorrect_label,'visible','off');
    set(fsm.handles.consecutiveCorrect,'visible','off');
    set(fsm.handles.nIrrelTrials_label,'visible','off');
    set(fsm.handles.nIrrelTrials,'visible','off');
    set(fsm.handles.Tirreldelaymeanadd_label,'visible','off');
    set(fsm.handles.Tirreldelaymeanadd,'visible','off');
    set(fsm.handles.maxBlockSize_label,'visible','off');
    set(fsm.handles.maxBlockSize,'visible','off');
    set(fsm.handles.laserOffset_label,'visible','off');
    set(fsm.handles.laserOffset,'visible','off');
    set(fsm.handles.constantLaser,'visible','off');
    set(fsm.handles.nonVisualLaser,'visible','off');
    set(fsm.handles.alternateLaser,'visible','off');
    set(fsm.handles.alternateLaser_label,'visible','off');
    
elseif button_state == get(hObject,'Min') % hide speed monitor axes
    set(fsm.handles.ax(1),'visible','off');
    set(fsm.handles.spdylim,'visible','off');
    set(fsm.handles.spdxrng,'visible','off');
    set(fsm.handles.speedMonitorFlag','BackgroundColor','white');
    
    set(fsm.handles.itiLaser,'visible','on');
    set(fsm.handles.consecutiveCorrect_label,'visible','on');
    set(fsm.handles.consecutiveCorrect,'visible','on');
    set(fsm.handles.nIrrelTrials_label,'visible','on');
    set(fsm.handles.nIrrelTrials,'visible','on');
    set(fsm.handles.Tirreldelaymeanadd_label,'visible','on');
    set(fsm.handles.Tirreldelaymeanadd,'visible','on');
    set(fsm.handles.maxBlockSize_label,'visible','on');
    set(fsm.handles.maxBlockSize,'visible','on');
    set(fsm.handles.laserOffset_label,'visible','on');
    set(fsm.handles.laserOffset,'visible','on');
    set(fsm.handles.constantLaser,'visible','on');
    set(fsm.handles.nonVisualLaser,'visible','on');
    set(fsm.handles.alternateLaser,'visible','on');
    set(fsm.handles.alternateLaser_label,'visible','on');
    try
        set(fsm.handles.spdplot,'visible','off');
        set(fsm.handles.spdRngHiLine,'visible','off');
        set(fsm.handles.spdRngLoLine,'visible','off');
    catch
    end
end
