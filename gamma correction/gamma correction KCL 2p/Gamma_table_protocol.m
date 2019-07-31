%% Protocol for monitor gamma calibration
%% Display different Gray values, take note of luminance meassured at
%% similar distance to that used to display the visual stimulus.
%% Luminometer should be in focus at the center of the monitor. 
calib20120903_psychtoolbox

%% Code to make gamma table, get relationship between luminance and RGB
%% values to make a correction to the monitor gamma table
%% enter these values in an m file named with the date and monitor model and brightness/contrast
%% eg calib20160831_DellU2715Hc_bright50_cont50

%% Check if gamma table works, use this code for testing that the gray is in the middle between white and black
test_luminance


%% Add these lines to the codes taht should apply the gamma table
load('C:\Users\Sonja\Documents\MATLAB\stimBruno\Flor\Monitor_Calibration\GammaTable_r604u2713.mat')
Screen('LoadNormalizedGammaTable', window, GammaTable'*[1 1 1]);

%% Add these lines to the end of the codes to go back to the normal gamma
%% table of the monitor
[window,screenRect,ifi,whichScreen]=initScreen;
Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
Screen('CloseAll');

