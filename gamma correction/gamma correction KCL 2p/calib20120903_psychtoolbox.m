% cgloadlib
% freq = 60;
% cgopen(1,32,freq,2) % second monitor
% cgfont('Arial',20)
% cgalign('c','c')
% 
% steps = 64;
% scale = 0:1./(steps-1):1
% cgpencol(1,0,0)
% cgflip(0,0,0)
% for n = 1:length(scale)
%     cgtext(num2str(n),-200,-200)
%     cgflip(scale(n),scale(n),scale(n))
%     pause
% end
% 
% cgshut
% 
%edit runstim_driftinggrating.m


% steps = 64;
%rgbvalues = round(linspace(0,255,64));
rgbvalues = round(linspace(0,255,16));
% initialize screen
screens=Screen('Screens');
screenNumber=2%max(screens)
%     [window,screenRect,ifi,whichScreen]=initScreen;

%open an (the only) onscreen Window, if you give only two input arguments
%this will make the full screen white (=default)
test = 0;
colbackground = 128;
if test, %sca
    [expWin,screenRect]=Screen('OpenWindow',screenNumber,colbackground,[10 20 768 384]); % Screen('OpenWindow?')    
else
    [expWin,screenRect]=Screen('OpenWindow',screenNumber,colbackground);
    %[~,s]=Screen('LoadNormalizedGammaTable', expWin, ([0:255]./255)'*[1 1 1]);
    Screen('LoadNormalizedGammaTable', expWin, ([0:255]./255)'*[1 1 1]);

end
vbl = Screen('Flip', expWin);
Screen('TextSize',expWin,24);
Screen('TextColor',expWin,[255 0 0]);

KbName('UnifyKeyNames');
KeyEscape = KbName('ESCAPE');
KeyUp     = KbName('UpArrow');
KeyDown   = KbName('DownArrow');
% KbName('KeyNames')

stop = 0;

i    = 1;
while stop==0,
    Screen('FillRect',expWin,rgbvalues(i));
    %DrawFormattedText(expWin,sprintf('rgb=%d',rgbvalues(i)),'center', 'center'); % help DrawFormattedText
    DrawFormattedText(expWin,sprintf('%d:rgb=%d',i,rgbvalues(i)),screenRect(1)+50,screenRect(2)+50); % help DrawFormattedText
    vbl = Screen('Flip', expWin);
        
    stop2=0;
    while stop2==0,
        [ keyIsDown, timeSecs, keyCode ] = KbCheck;
        if keyIsDown
            if keyCode(KeyEscape)
                Screen('CloseAll');
                stop2=1;
                stop =1;                       
            elseif keyCode(KeyUp)
                i=i+1; if i>length(rgbvalues), i=length(rgbvalues); end
                stop2=1;
            elseif keyCode(KeyDown)                
                i=i-1; if i<1, i=1; end
                stop2=1;                
            end            
            
            % If the user holds down a key, KbCheck will report multiple events.
            % To condense multiple 'keyDown' events into a single event, we wait until all
            % keys have been released.
            while KbCheck; end
        end
    end    
    
end
