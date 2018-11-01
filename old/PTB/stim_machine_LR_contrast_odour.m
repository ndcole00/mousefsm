function stim_machine_LR_contrast_odour

% one iteration of the stim machine

global fsm
if fsm.trialnum ==0; return; end
fsm.teensyinput = fsm.s.inputSingleScan;
fsm.teensyinput = fsm.teensyinput(2:end);% remove ch0

aspectratio = 1;

SF = fsm.spatialfreq;
period   = round(fsm.scrset.ppd./SF);
cyclespersecond = fsm.temporalfreq;

freq = 1/period;
contrast = fsm.contrast;
contrastchange = fsm.contrastchange;
changedcontrast = contrast + contrast * (contrastchange/100);

% only one of these 5 should be on at any time
% 1: cueL, 2:cueR, 3: stim both sides, 4:contrast change both sides, 5:Odour
% 6: pause - punishment
if max(fsm.teensyinput)==0;
    trigg = 0;
    fsm.phase = 0; 
else
    trigg = find(fsm.teensyinput);
    fsm.phaseincrement = (cyclespersecond * 360) * fsm.ifi;
    fsm.phase = fsm.phase + fsm.phaseincrement;
end
drawnow;


switch trigg
    
    case 0 % gray screen
        
        if ~fsm.grayscreen
            contrastL = 0;
            contrastR = 0;
            
            Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], fsm.orientation(fsm.trialnum), [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
            Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-fsm.orientation(fsm.trialnum), [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
            %Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
            Screen('Flip', fsm.winL, [],[],1,1);
            fsm.grayscreen = 1;
        end
        
    case 1 % cue vis
        fsm.grayscreen = 0;
        contrastL = contrast;
        contrastR = contrast;
        
        Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], fsm.orientation(fsm.trialnum), [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
        Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-fsm.orientation(fsm.trialnum), [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
        %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
        Screen('Flip', fsm.winL, [],[],1,1);
    case 2 % cue odour
        fsm.grayscreen = 0;
        
        contrastL = 0;
        contrastR = 0;
        
        Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], fsm.orientation(fsm.trialnum), [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
        Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-fsm.orientation(fsm.trialnum), [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
        %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
        Screen('Flip', fsm.winL, [],[],1,1);
        
    case 3 % Stim on both sides
        fsm.grayscreen = 0;
        contrastL = contrast;
        contrastR = contrast;
        
        Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], fsm.orientation(fsm.trialnum), [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
        Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-fsm.orientation(fsm.trialnum), [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
        %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
        Screen('Flip', fsm.winL, [],[],1,1);
        
    case 4 % Change contrast 
        fsm.grayscreen = 0;
        contrastL = changedcontrast;
        contrastR = changedcontrast;
       
        
        Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], fsm.orientation(fsm.trialnum), [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
        Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-fsm.orientation(fsm.trialnum), [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
        %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
        Screen('Flip', fsm.winL, [],[],1,1);
        
    case 5 % odour, and don't change contrast
        fsm.grayscreen = 0;
        
        contrastL = contrast;
        contrastR = contrast;
        
        Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], fsm.orientation(fsm.trialnum), [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
        Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-fsm.orientation(fsm.trialnum), [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
        %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
        Screen('Flip', fsm.winL, [],[],1,1);
        
    case 6 % do nothing - will pause the grating
        fsm.soundon = 0;
end

