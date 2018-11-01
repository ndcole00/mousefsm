clear all 
clear MEX
%[window,screenRect,ifi,whichScreen]=initScreen;
[window,screenRect]=Screen('OpenWindow',1);

% clear gammaTable
%HideCursor;
Screen('Preference', 'VBLTimestampingMode', -1);
% % out = gammacon2(0:255,'rgb2lum');
% % lum2=lum./max(lum);
% lum2=(linspace(0,1,256));
% out = gammacon2(lum./max(lum),'lum2rgb')
% out = gammacon2(lum2,'lum2rgb')
% 
% % n=(linspace(0,255,64));
% % figure, plot(lum2,0:255), hold on, 
% % figure, plot(lum2,out,'r')
% % out=out./max(out);
% %% out(1:5)=0;
% gammaTable=(out./max(out))';
% load('C:\Documents and Settings\visstim\My Documents\MATLAB\stimBruno\current_stimuli\Flor\RFstimuli_Lee\gammatablesetup302.mat')
% gammaTable=gammaTable1;
% Screen('LoadNormalizedGammaTable', window, gammaTable*[1 1 1]);
% white=Whiteindex(window);
% black=blackindex(window);
% gray=(white+black)/2;
% inc=white-gray;

% white2 = gammacon2(1,'lum2rgb')
% black2=gammacon2(0,'lum2rgb')
%% gray2 is the gray value in the middle between white and black. Meassure
%% with luminometer 05/09/2012 in dell monitor room 302.
% rgbvalues=linspace(0,255,256);
% out=gammacon_r302(rgbvalues,'rgb2lum');
% out=out./max(out);
% out(1)=0;
% gammaTable=out';
% white=Whiteindex(window);
% black=blackindex(window);
% gray=(white+black)/2;
% inc=white-gray;
% figure, plot(gammaTable)
% Screen('LoadNormalizedGammaTable', window, gammaTable*[1 1 1]);
% for i=1:500
%     Screen('FillRect', window,gray);
%     Screen('Flip',window);
%   
%      if KbCheck Screen('CloseAll')
%      end
%     end
%  

% rgbvalues=linspace(0,1,256);
% out=gammacon_r302(rgbvalues,'lum2rgb');
% out=out./max(out);
% out(1)=0;
% gammaTable=out';
% load('C:\Users\Sonja\Documents\MATLAB\stimBruno\Flor\Monitor_Calibration\GammaTable_r604u2713.mat')
% % NormalizedgammaTable_DellU2711:
% Screen('LoadNormalizedGammaTable', window, GammaTable_r604u2713'*[1 1 1]);
% Normal_Gamma_Table:
load ('C:\Jasper\Matlab\Adil\FSM_2p_setup\gamma corection 2p setup\GammaTable_Dell_U2415b_bright20_cont50.mat')
Screen('LoadNormalizedGammaTable', window, GammaTable_Dell_U2415b_bright20_cont50'*[1 1 1]);
% Screen('LoadNormalizedGammaTable', window, ([0:255]./255)'*[1 1 1]);
white=WhiteIndex(window);
black=BlackIndex(window);
gray=(white+black)/2;
inc=white-gray;
% figure, plot(gammaTable)
% gray2=gammacon_r302(0.5,'lum2rgb');
% values=gammacon_r302([0:0.1:1],'lum2rgb');

for i=1:5000
    Screen('FillRect', window,gray);
    Screen('Flip',window);
  
     if KbCheck Screen('CloseAll')
     end
    end
 
kbwait;
screen('CloseAll');

