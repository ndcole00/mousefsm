function [AI] = runAIrecorder(mouseName, block, taskTag)
%Simple function to save time when starting the AI recorder.
if ~exist('block','var'); block = 'B1'; end
if size(regexp(mouseName,'[_]','split'),2)>1
    error('You have likely included the block in the mouse name. This will lead to an incompatible file name.')
end
if ~exist('taskTag','var'); taskTag = 'SD'; end

hostName = getenv('computername');
selectedDir = uigetdir('C:\Data');


if strcmp(hostName, 'DESKTOP-PPJDC4N') %Two-photon
    AI = sitools.ai_recorder('C:\Users\KhanLab\Documents\MATLAB\ScanImageTools\code\+sitools\prefsAIrec.mat');
    AI.fname = sprintf('%s\\%s__%s_%s_%s_AI_001.bin', selectedDir, datestr(now, 'yyyymmdd_HHMMSS'), mouseName, block, taskTag);
    AI.start
elseif strcmp(hostName, 'DESKTOP-B3BBA2R') %Widefield
    AI = sitools.ai_recorder('W:\Code\Utils\widefieldAIsettings2.mat');
    AI.fname = sprintf('%s\\%s__%s_%s_%s_AI_001.bin', selectedDir, datestr(now, 'yyyymmdd_HHMMSS'), mouseName, block, taskTag);
    AI.start    
elseif contains(hostName, 'BEHAVIOUR-BOX') %All behaviour boxes
    AI = sitools.ai_recorder('W:\Code\prefsBehaviourBoxes.mat');
    AI.fname = sprintf('%s\\%s__%s_%s_%s_AI_001.bin', selectedDir, datestr(now, 'yyyymmdd_HHMMSS'), mouseName, block, taskTag);
    AI.connectAndStart
end
end

%     case 'r'
%         AI = sitools.ai_recorder('C:\Users\KhanLab\Documents\MATLAB\ScanImageTools\code\+sitools\prefsRetinotopic.mat');
