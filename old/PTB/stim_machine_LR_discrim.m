function stim_machine_LR_discrim

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
% contrastchange = fsm.contrastchange;
% changedcontrast = contrast + contrast * (contrastchange/100);

% only one of these 7 should be on at any time
% 1: cueL, 2:cueR, 3: stim both sides, 4:checkerboardVert L, 5:checkerboardVert R, 6:checkerboardAng L, 7:checkerboardAng R
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
        
    case 1 % cueL
        fsm.grayscreen = 0;
        contrastL = contrast;
        contrastR = 0;
        
        Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], fsm.orientation(fsm.trialnum), [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
        Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-fsm.orientation(fsm.trialnum), [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
        %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
        Screen('Flip', fsm.winL, [],[],1,1);
    case 2 % cueR
        fsm.grayscreen = 0;
        contrastL = 0;
        contrastR = contrast;
        
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
        
    case 4 % CheckerboardVert L
        fsm.grayscreen = 0;
        rotang = 0;
        
        Screen('DrawTexture', fsm.winL, fsm.checkerTextureL, [], fsm.dstRect, rotang, fsm.filterMode, contrast, [], [], []);
        Screen('DrawTexture', fsm.winR, fsm.checkerTextureR, [], fsm.dstRect, rotang, fsm.filterMode, contrast, [], [], []);
        %for training only
        %Screen('FillRect', fsm.winR, 128)
        %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
        Screen('Flip', fsm.winL, [],[],1,1);
        
    case 5 % CheckerboardVert R
        fsm.grayscreen = 0;
        rotang = 0;
        
        Screen('DrawTexture', fsm.winR, fsm.checkerTextureR, [], fsm.dstRect, rotang, fsm.filterMode, contrast, [], [], []);
        Screen('FillRect', fsm.winL, 128)
        %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
        Screen('Flip', fsm.winL, [],[],1,1);
        
    case 6 % CheckerboardAng L
        fsm.grayscreen = 0;
        rotang = 45;
        
        Screen('DrawTexture', fsm.winL, fsm.checkerTextureL, [], fsm.dstRect, rotang, fsm.filterMode, contrast, [], [], []);
        Screen('DrawTexture', fsm.winR, fsm.checkerTextureR, [], fsm.dstRect, rotang, fsm.filterMode, contrast, [], [], []);
        % for training only
        %Screen('FillRect', fsm.winR, 128)
        %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
        Screen('Flip', fsm.winL, [],[],1,1);
        
    case 7 % CheckerboardAng R
        fsm.grayscreen = 0;
        rotang = 45;
        
        Screen('DrawTexture', fsm.winR, fsm.checkerTextureR, [], fsm.dstRect, rotang, fsm.filterMode, contrast, [], [], []);
        Screen('FillRect', fsm.winL, 128)
        %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
        Screen('Flip', fsm.winL, [],[],1,1);
end

