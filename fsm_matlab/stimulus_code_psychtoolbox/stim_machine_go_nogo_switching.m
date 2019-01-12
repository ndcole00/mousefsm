function stim_machine_go_nogo_switching
dbstop if error
% one iteration of the stim machine

global fsm
if fsm.trialnum ==0; return; end
fsm.teensyinput = fsm.s.inputSingleScan;
% 3rd bit is trialend
fsm.trialend = fsm.teensyinput(end);
fsm.teensyinput = fsm.teensyinput(1:end-1);% remove trial end

aspectratio = 1;

SF = str2num(get(fsm.handles.spatialfreq,'string'));
period   = round(fsm.scrset.ppd./SF);
cyclespersecond = fsm.temporalfreq;

freq = 1/period;
contrast = fsm.contrast;
orientation = fsm.orientation(fsm.trialnum);

%changedorientation = orientation + fsm.orientationchange;

% only one of these should be on at any time
% 1: Stim1 (rewarded), 2:Stim2 (non rewarded), 


if max(fsm.teensyinput)==0;
    trigg = 0;
    fsm.phase = 0; 
else
    trigg = find(fsm.teensyinput);
    fsm.phaseincrement = (cyclespersecond * 360) * fsm.ifi;
    fsm.phase = fsm.phase + fsm.phaseincrement;
end
drawnow;

if 0 % flicker test
    if ~isfield(fsm, 'temp'); fsm.temp = 0; end
    fsm.temp = ~fsm.temp; trigg = fsm.temp;
end

switch trigg
    
    case 0 % gray screen
        
        if ~fsm.grayscreen
            contrastL = 0;
            contrastR = 0;
            
            Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [560+fsm.stimPosOffset,0,2000+fsm.stimPosOffset,1440], orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
            if fsm.twomonitors;Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [560-fsm.stimPosOffset,0,2000-fsm.stimPosOffset,1440], 180-orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);end
            % photodiode patch
            Screen('FillRect',fsm.winL,0,[0 0 120 120]);% white
            %Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
            Screen('Flip', fsm.winL, [],[],[],1);
            fsm.grayscreen = 1;
            fsm.vbl = 0;
        end
        
    case 1 % Stim 1
        fsm.grayscreen = 0;
        contrastL = contrast;
        contrastR = contrast;
        
        Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [560+fsm.stimPosOffset,0,2000+fsm.stimPosOffset,1440], orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
        if fsm.twomonitors;Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [560-fsm.stimPosOffset,0,2000-fsm.stimPosOffset,1440], 180-orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);end
        % photodiode patch
        Screen('FillRect',fsm.winL,255,[0 0 120 120]);% white
        
        %Force smooth stim for min view time
        if fsm.stimStartFlag == 1
            vbl = Screen('Flip', fsm.winL, [],[],[],1);
            vbl0 = vbl;
            while vbl < vbl0 + fsm.stmT
                fsm.phaseincrement = (cyclespersecond * 360) * fsm.ifi;
                fsm.phase = fsm.phase + fsm.phaseincrement;
                Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [560+fsm.stimPosOffset,0,2000+fsm.stimPosOffset,1440], orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
                if fsm.twomonitors;Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [560-fsm.stimPosOffset,0,2000-fsm.stimPosOffset,1440], 180-orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);end
                % photodiode patch
                Screen('FillRect',fsm.winL,255,[0 0 120 120]);% white
                vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],[],1);
            end
            fsm.stimStartFlag = 0;
        else
            Screen('Flip', fsm.winL, [],[],1,1); 
        end

    case 2 % Stim 2
        fsm.grayscreen = 0;
        contrastL = contrast;
        contrastR = contrast;
        
        Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [560+fsm.stimPosOffset,0,2000+fsm.stimPosOffset,1440], orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
        if fsm.twomonitors;Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [560-fsm.stimPosOffset,0,2000-fsm.stimPosOffset,1440], 180-orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);end
        % photodiode patch
        Screen('FillRect',fsm.winL,255,[0 0 120 120]);% white
        
        %Force smooth stim for min view time
        if fsm.stimStartFlag == 1
            vbl = Screen('Flip', fsm.winL, [],[],[],1);
            vbl0 = vbl;
            while vbl < vbl0 + fsm.stmT
                fsm.phaseincrement = (cyclespersecond * 360) * fsm.ifi;
                fsm.phase = fsm.phase + fsm.phaseincrement;
                Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [560+fsm.stimPosOffset,0,2000+fsm.stimPosOffset,1440], orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
                if fsm.twomonitors;Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [560-fsm.stimPosOffset,0,2000-fsm.stimPosOffset,1440], 180-orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);end
                % photodiode patch
                Screen('FillRect',fsm.winL,255,[0 0 120 120]);% white
                vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],[],1);
            end
            fsm.stimStartFlag = 0;
        else
            Screen('Flip', fsm.winL, [],[],1,1); 
        end
        
%     case 3 % Stim on both sides
%         fsm.grayscreen = 0;
%         contrastL = contrast;
%         contrastR = contrast;
%         
%         Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
%         Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
%         %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
%         Screen('Flip', fsm.winL, [],[],1,1);
%         
%     case {4,7} % Change orientation 
%         fsm.grayscreen = 0;
%         contrastL = contrast;
%         contrastR = contrast;
%        
%         
%         Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], changedorientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
%         Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-changedorientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
%         %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
%         Screen('Flip', fsm.winL, [],[],1,1);
%         
%     case 5 % odour, and don't change ori
%         fsm.grayscreen = 0;
%         
%         contrastL = contrast;
%         contrastR = contrast;
%         
%         Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
%         Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
%         %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
%         Screen('Flip', fsm.winL, [],[],1,1);
        
%     case 6 % do nothing - will pause the grating

        
        
end

