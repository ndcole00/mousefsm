function stim_machine_LR_orientation_freeze_sound20160420

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
orientation = fsm.orientation(fsm.trialnum);
changedorientation = orientation + fsm.orientationchange(fsm.trialnum);
duratn = 5;% max beep duration
Fs = 8192;
t = 0:1/Fs:duratn-(1/Fs);
            

% only one of these 5 should be on at any time
% 1: High sound, 2:Low sound, 3: stim both sides, 4:orientation change L, 5:freeze

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
            
            Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
            Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
            %Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
            Screen('Flip', fsm.winL, [],[],1,1);
            fsm.grayscreen = 1;
        end
        status = PsychPortAudio('GetStatus', fsm.pahandle);
        if status.Active
            PsychPortAudio('Stop', fsm.pahandle); 
        end
        
    case 1 % High tone
        fsm.grayscreen = 0;
        status = PsychPortAudio('GetStatus', fsm.pahandle);
        if ~status.Active
            fsm.sfreq = 2000; %frequency of sound
            snd = cos(2*pi*fsm.sfreq*t)+1/2*sin(2*pi*fsm.sfreq*(t-pi/4))+1/4*cos(2*pi*fsm.sfreq*t);
            snd = snd/max(snd);
            PsychPortAudio('FillBuffer', fsm.pahandle, snd);
            PsychPortAudio('Start', fsm.pahandle);
            drawnow;pause(0.00000001)
        end
        contrastL = 0;
        contrastR = 0;
        
        Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
        Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
        %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
        Screen('Flip', fsm.winL, [],[],1,1);
    case 2 % Low tone
        fsm.grayscreen = 0;
        status = PsychPortAudio('GetStatus', fsm.pahandle);
        if ~status.Active
            fsm.sfreq = 1000; %frequency of sound
            snd = cos(2*pi*fsm.sfreq*t)+1/2*sin(2*pi*fsm.sfreq*(t-pi/4))+1/4*cos(2*pi*fsm.sfreq*t);
            snd = snd/max(snd);
            PsychPortAudio('FillBuffer', fsm.pahandle, snd);
            PsychPortAudio('Start', fsm.pahandle);
            drawnow;pause(0.00000001)
        end
        contrastL = 0;
        contrastR = 0;
        
        Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
        Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
        %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
        Screen('Flip', fsm.winL, [],[],1,1);
        
    case 3 % Stim on both sides
        fsm.grayscreen = 0;
        contrastL = contrast;
        contrastR = contrast;
        
        Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
        Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
        %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
        Screen('Flip', fsm.winL, [],[],1,1);
        if get(fsm.handles.longbeep ,'Value')==1 % if beep stays on
            % let it play
        else
           PsychPortAudio('Stop', fsm.pahandle); 
        end
        
    case 4 % Change orientation L
        fsm.grayscreen = 0;
        contrastL = contrast;
        contrastR = contrast;
        
        
        Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], changedorientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
        if get(fsm.handles.bothsides ,'Value')==1 % both sides ori change
            Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-changedorientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
        else
            Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
        end
        
        %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
        Screen('Flip', fsm.winL, [],[],1,1);
        if get(fsm.handles.longbeep ,'Value')==1 % if beep stays on
            %let it play
        else
           PsychPortAudio('Stop', fsm.pahandle); 
        end
%    case 5 % Change orientation R
%         fsm.grayscreen = 0;
%         contrastL = contrast;
%         contrastR = contrast;
%         
%         Screen('DrawTexture', fsm.winR, fsm.gabortex2, [], [], 180-changedorientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastR, aspectratio, 0, 0, 0]);
%         if get(fsm.handles.bothsides ,'Value')==1 % both sides ori change
%             Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], changedorientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
%         else
%             Screen('DrawTexture', fsm.winL, fsm.gabortex1, [], [], orientation, [], [], [], [], kPsychDontDoRotation, [180-fsm.phase, freq, fsm.sc, contrastL, aspectratio, 0, 0, 0]);
%         end
%         %vbl = Screen('Flip', fsm.winL, vbl + 0.5 * fsm.ifi,[],1,1);
%         Screen('Flip', fsm.winL, [],[],1,1);
    
    case 5 % do nothing - will pause the grating
end

