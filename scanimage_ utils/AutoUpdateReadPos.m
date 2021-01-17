% ScanImage user function that updates the position of the motors
% automatically every x ms, until the user presses Grab with Save on.

% This starts when SI starts, stops on Grab with Save On
% In SI user functions, set it to start on applicationOpen and also on
% acqAbort  and AcqModeStart

% Adil Khan, London 2020

function AutoUpdateReadPos(src,~)

hSICtl = evalin('base','hSICtl');

saveOn = hSICtl.hGUIData.mainControlsV4.cbAutoSave.Value;
grabButton = hSICtl.hGUIData.mainControlsV4.grabOneButton.Value;
gAbort = hSICtl.hGUIData.mainControlsV4.gAbort.Value;
focusButton = hSICtl.hGUIData.mainControlsV4.focusButton.Value;
fAbort = hSICtl.hGUIData.mainControlsV4.fAbort.Value;

if ~grabButton && ~gAbort && ~focusButton && ~fAbort % coming from startup of SI
    autoUpdateT = timer;
    autoUpdateT.Name = 'AutoUpdateTimer';
    autoUpdateT.StartDelay = 0;
    autoUpdateT.ExecutionMode = 'fixedSpacing';
    autoUpdateT.Period = .1; %Adjust to change how often the position is updated (in seconds)
    autoUpdateT.TimerFcn = @(src,evt) evalin('base','hSICtl.changedMotorPosition');
    
    start(autoUpdateT);
    fprintf('AutoUpdate motor position ON\n');

elseif grabButton && saveOn
    delete(timerfind('Name','AutoUpdateTimer'));
    clear ('autoUpdateT');
    fprintf('AutoUpdate motor position OFF\n');
elseif gAbort || fAbort 
    Tim = timerfind('Name','AutoUpdateTimer');
    if isempty(Tim) 
        autoUpdateT = timer;
        autoUpdateT.Name = 'AutoUpdateTimer';
        autoUpdateT.StartDelay = 0;
        autoUpdateT.ExecutionMode = 'fixedSpacing';
        autoUpdateT.Period = .1; %Adjust to change how often the position is updated (in seconds)
        autoUpdateT.TimerFcn = @(src,evt) evalin('base','hSICtl.changedMotorPosition');
        start(autoUpdateT);
        fprintf('AutoUpdate motor position ON\n');
    end
end





