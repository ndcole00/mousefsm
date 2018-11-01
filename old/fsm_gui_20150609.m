function fsm_gui_20150609()
close all
clearvars -global fsm
global fsm
% Initialise
fsm.comport = 'COM3';
fsm.savedir = 'D:\BB2data\';
fsm.token = 'M100_B1';
fsm.fname = '';
fsm.spdrnghigh = 90;
fsm.spdrnglow = 10;
fsm.spdavgbin = .02;
fsm.spdylim = 100;
fsm.spdxrng = 5;
fsm.Tcuedelay = 1;
fsm.Tcue = 1;
fsm.Tstimdelaymin = 1;
fsm.Tstimdelaymeanadd = 1;
fsm.Tcontrastdelaymin = 1;
fsm.Tcontrastdelaymeanadd = 1;
fsm.Trewdavailable = 1;
fsm.Titi = 1;
fsm.contrast = 70;
fsm.contrastchange = 10;
fsm.orientation = [];
fsm.spatialfreq = 2;
fsm.temporalfreq = 2;
fsm.attentionlocationlist = {'left','right','front','back'};
fsm.attentionlocation = {};
fsm.contrastchangelocation = {};
fsm.pmismatch = .05;
fsm.mismatch = [];
fsm.ntrialsperblock = 100;
fsm.rewd = .1;
fsm.trialnum = 0;
fsm.triallog = {};
fsm.lickthreshold = 1.2;
fsm.RT = [];
fsm.ntrialsperblock = 80;
fsm.blockchangetrial = 0;


%--------------------------------------------------------------------------
% make GUI

fsm.handles.f = figure('Units','normalized','Position',[0.1 0.1 0.7 0.7],...
    'Toolbar','figure');
set(fsm.handles.f,'CloseRequestFcn',@my_closefcn);

% plot image
fsm.handles.ax(1)=axes('Parent',fsm.handles.f,'Units','normalized','Position',[0.65 0.55 0.33 0.4],'xticklabel',[]);
title('Speed (cm/s)');ylim([-10 fsm.spdylim]);
Xrng_speed_plot

fsm.handles.ax(2)=axes('Parent',fsm.handles.f,'Units','normalized','Position',[0.65 0.05 0.33 0.4]);
title('Reaction Times (s)');
hold(fsm.handles.ax(2),'on');

fsm.handles.ax(3)=axes('Parent',fsm.handles.f,'Units','normalized','Position',[0.35 0 0.27 0.3]);
try imshow ('M:\Adil\FSM\contrast change task schematic.jpg');end

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
    'String',fsm.token,'FontSize',10);

% spd rng high
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.8 0.2 0.04],...
    'String','Speed range high','FontSize',10);
fsm.handles.spdrnghigh = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.8 0.1 0.04],...
    'String',fsm.spdrnghigh,'FontSize',10,'Callback', @call_change_spdrnghigh);

% spd rng low
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.75 0.2 0.04],...
    'String','Speed range low','FontSize',10);
fsm.handles.spdrnglow = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.75 0.1 0.04],...
    'String',fsm.spdrnglow,'FontSize',10,'Callback', @call_change_spdrnglow);

% spd ylim
fsm.handles.spdylim = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.63 0.96 0.02 0.02],...
    'String',fsm.spdylim,'FontSize',10,'Callback', @call_change_spdylim);

% spd xrange
fsm.handles.spdxrng = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.97 0.52 0.02 0.02],...
    'String',fsm.spdxrng,'FontSize',10,'Callback', @call_change_spdxrng);

% t cue delay
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.7 0.2 0.04],...
    'String','T cue delay','FontSize',10);
fsm.handles.Tcuedelay = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.7 0.1 0.04],...
    'String',fsm.Tcuedelay,'FontSize',10);

% T cue duration
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.65 0.2 0.04],...
    'String','T cue duration','FontSize',10);
fsm.handles.Tcue = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.65 0.1 0.04],...
    'String',fsm.Tcue,'FontSize',10);

% T stim delay min
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.6 0.2 0.04],...
    'String','T stim delay min','FontSize',10);
fsm.handles.Tstimdelaymin = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.6 0.1 0.04],...
    'String',fsm.Tstimdelaymin,'FontSize',10);

% T stim delay mean additional
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.55 0.2 0.04],...
    'String','T stim delay mean added','FontSize',10);
fsm.handles.Tstimdelaymeanadd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.55 0.1 0.04],...
    'String',fsm.Tstimdelaymeanadd,'FontSize',10);

% T contrast delay min
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.5 0.2 0.04],...
    'String','T contrast delay min','FontSize',10);
fsm.handles.Tcontrastdelaymin = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.5 0.1 0.04],...
    'String',fsm.Tcontrastdelaymin,'FontSize',10);

% T contrast delay mean additional
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.45 0.2 0.04],...
    'String','T contrast delay mean added','FontSize',10);
fsm.handles.Tcontrastdelaymeanadd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.45 0.1 0.04],...
    'String',fsm.Tcontrastdelaymeanadd,'FontSize',10);

% T reward available
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.4 0.2 0.04],...
    'String','T reward available','FontSize',10);
fsm.handles.Trewdavailable = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.4 0.1 0.04],...
    'String',fsm.Trewdavailable,'FontSize',10);

% inter trial interval
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.35 0.2 0.04],...
    'String','Inter trial interval','FontSize',10);
fsm.handles.Titi = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.35 0.1 0.04],...
    'String',fsm.Titi,'FontSize',10);

% Speed averaging bin
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.3 0.2 0.04],...
    'String','Speed averaging bin','FontSize',10);
fsm.handles.spdavgbin = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.3 0.1 0.04],...
    'String',fsm.spdavgbin,'FontSize',10);

% Prob mismatch trials
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.25 0.2 0.04],...
    'String','Prob. mismatch trials','FontSize',10);
fsm.handles.pmismatch = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.25 0.1 0.04],...
    'String',fsm.pmismatch,'FontSize',10);

% Rewd valve duration
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.2 0.2 0.04],...
    'String','Reward valve duration','FontSize',10);
fsm.handles.rewd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.2 0.1 0.04],...
    'String',fsm.rewd,'FontSize',10);

% Starting Contrast
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.15 0.2 0.04],...
    'String','Starting contrast','FontSize',10);
fsm.handles.contrast = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.15 0.1 0.04],...
    'String',fsm.contrast,'FontSize',10);

% Contrast change %
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.1 0.2 0.04],...
    'String','Contrast change %','FontSize',10);
fsm.handles.contrastchange = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.1 0.1 0.04],...
    'String',fsm.contrastchange,'FontSize',10);

% Spatial freq
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.05 0.2 0.04],...
    'String','Spatial frequency','FontSize',10);
fsm.handles.spatialfreq = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.05 0.1 0.04],...
    'String',fsm.spatialfreq,'FontSize',10);

% Temporal freq
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.005 0.2 0.04],...
    'String','Temporal frequency','FontSize',10);
fsm.handles.temporalfreq = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.005 0.1 0.04],...
    'String',fsm.temporalfreq,'FontSize',10);

% N trials per block
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.65 0.17 0.04],...
    'String','N trials per block','FontSize',10);
fsm.handles.ntrialsperblock = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.53 0.65 0.08 0.04],...
    'String',fsm.ntrialsperblock,'FontSize',10);

% Lick threshold
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.6 0.17 0.04],...
    'String','Lick Threshold','FontSize',10);
fsm.handles.lickthreshold = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.53 0.6 0.08 0.04],...
    'String',fsm.lickthreshold,'FontSize',10);

% stimulus location, left/right OR front/back
fsm.handles.lrORfb = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','popupmenu',...
    'Position', [0.35 0.55 0.13 0.04],'String',{'Left/Right','Front/Back'},...
    'Value',1,'FontSize',10);

% Blocks or trial by trial
fsm.handles.blockORtbt = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','popupmenu',...
    'Position', [0.49 0.55 0.12 0.04],'String',{'Blocks','Trial by Trial'},...
    'Value',1,'FontSize',10);

%%% Indicators %%%

% Filename
fsm.handles.fname = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.9 0.26 0.04],...
    'String',['Filename: ' fsm.fname],'FontSize',10,'HorizontalAlignment','left');

% Trial number
fsm.handles.trialnum = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.85 0.26 0.04],...
    'String',['Trial Number: ' num2str(fsm.trialnum)],'FontSize',10,'HorizontalAlignment','left');

% Stim location
fsm.handles.attentionlocation = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.8 0.26 0.04],...
    'String',['Stim location: ' fsm.attentionlocationlist{1}],'FontSize',10,'HorizontalAlignment','left');

% Mismatch trial
fsm.handles.mismatch = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.75 0.26 0.04],...
    'String',['Mismatch trial: ' ],'FontSize',10,'HorizontalAlignment','left');

% Grating orientation
fsm.handles.orientation = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.7 0.26 0.04],...
    'String',['Orientation: ' num2str(fsm.orientation)],'FontSize',10,'HorizontalAlignment','left');


%%%%% Buttons%%%%
% Start button
fsm.handles.start = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.35 0.3 0.13 0.10],...
    'String','Start','BackgroundColor', 'green','Callback', @call_start);

% Stop button
fsm.handles.stop = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.49 0.3 0.12 0.10],...
    'String','Stop','BackgroundColor', 'red','enable','off','Callback', @call_stop);

%--------------------------------------------------------------------------
% End make GUI


% start serial port
fsm.ard=serial(fsm.comport,'BaudRate',9600); % create serial communication object on port COM7
set(fsm.ard,'Timeout',.01);
fopen(fsm.ard); % initiate arduino communication
fprintf('serial port opened\n')

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
set(fsm.handles.stop,'enable','on')
drawnow;pause(0.00000001)
make_state_matrix


function make_state_matrix
global fsm
keeprunning = 1;fsm.stop = 0;
while keeprunning
    
    choose_stim % decide which stimlus to give
    cueD  = str2num(get(fsm.handles.Tcuedelay,'string'));
    cueT  = str2num(get(fsm.handles.Tcue,'string'));
    stimD = str2num(get(fsm.handles.Tstimdelaymin,'string')) + exprnd(str2num(get(fsm.handles.Tstimdelaymeanadd,'string')));
    stimT = str2num(get(fsm.handles.Tcontrastdelaymin,'string')) + exprnd(str2num(get(fsm.handles.Tcontrastdelaymeanadd,'string')));
    waitT = str2num(get(fsm.handles.Trewdavailable,'string'));
    rewT  = str2num(get(fsm.handles.rewd,'string'));
    iti   = str2num(get(fsm.handles.Titi,'string'));
    
    stm = [... % remember zero indexing; units are seconds, multiplied later to ms
        
    %  spd in   spd out     lick    Tup       Timer   digiOut
        0           0        0       1         0.01     0               ;...% state 0 init
        2           1        1       1         100      0               ;...% state 1 wait for speed in
        2           1        2       8         cueD     1               ;...% state 2 wait for cue
        3           1        3       4         cueT     1               ;...% state 3 cue on
        4           1        1       5         stimD    0               ;...% state 4 wait for stim
        5           1        1       6         stimT    2               ;...% state 5 stim on, wait for contrast change
        6           6        7       8         waitT    3               ;...% state 6 contrast change, wait for lick
        7           7        7       8         rewT     4               ;...% state 7 reward on
        8           8        8       99        iti      0               ;...% state 8 ITI

        ];

    stm (:,5) = round(stm(:,5)*1000); % sec to ms
    rcvd = '';
    % send an 'A' and receive a 'B'
    while ~strcmp(rcvd,'B');
        fprintf(fsm.ard,'%s','A');
        fprintf('Handshake: A');
        rcvd = fscanf(fsm.ard,'%s');
        fprintf('%s',rcvd);
    end

    % send [nRows nCols]
    [row, col] = size(stm);
    fprintf(fsm.ard,'%s\n',num2str([row col]));
    
    % send speed averaging bin size 
    spdbin = str2num(get(fsm.handles.spdavgbin,'string'))*1000;
    fprintf(fsm.ard,'%s\n',num2str(spdbin));
    
    % send upper and lower limit for speed range
    fprintf(fsm.ard,'%s\n',num2str(fsm.spdrnghigh));
    fprintf(fsm.ard,'%s',num2str(fsm.spdrnglow));
    
    % send lick threshold; 5V is 1024
    threshold = round((1024/5)*str2num(get(fsm.handles.lickthreshold,'string')));
    fprintf(fsm.ard,threshold);

    
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
        case 'startingFSM'
            fsm.trialnum = fsm.trialnum + 1;
            set(fsm.handles.trialnum,'String',['Trial Number: ' num2str(fsm.trialnum)])
            fprintf('Trial number %d\n',fsm.trialnum);
            trialend = 0;
            while trialend == 0%~strcmp(rcvd2,'E'); % it will send an E when trial ends
                % check stop button
                if fsm.stop == 1
                    keeprunning = 0;
                    break
                end
                % check for end of trial
                if fsm.ard.BytesAvailable
                    rcvd2 = fscanf(fsm.ard,'%s');%if rcvd2=='0';keyboard;end
                    if rcvd2 == 'E';
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
                        fsm.RT(fsm.trialnum) = findrectiontime(fsm.triallog{fsm.trialnum});
                        updateRTplot
                    else % else its sending the speed
                        olddat = get(fsm.handles.spdplot,'ydata');
                        newdat = cat(2,olddat(2:end),str2num(rcvd2));
                        set(fsm.handles.spdplot,'ydata',newdat);
                        set(fsm.handles.ax(1),'ylim',[-10 fsm.spdylim]);
                        drawnow
                        %fprintf('%s\n',rcvd2);
                    end
                    
                end
                
                drawnow
            end
    end

end

fprintf('make state matrix ended\n')

function call_stop(src,eventdata)
global fsm
fsm.stop = 1;
set(fsm.handles.start,'enable','on')
fprintf(fsm.ard,'%s\n','X');
fprintf('FSM stopped\n')
% read trial log
if ~isempty(fsm.triallog) % if its the first time you click stop
    while ~fsm.ard.BytesAvailable;end

    stopsignal = '';triallog = '';
    while ~strcmp(stopsignal,'d')% from 'stopped'
        partialtriallog = fscanf(fsm.ard,'%s');
        triallog = strcat(triallog,partialtriallog);
        try;stopsignal = partialtriallog(end);end
    end
    fsm.triallog{fsm.trialnum} = triallog;

    % save fsm
    save(fsm.fname,'fsm');

    % reset
    fsm.trialnum = 0;
    fsm.triallog = {};
    fsm.mismatch = [];
    fsm.attentionlocation = {};
    fsm.contrastchangelocation = {};
    fsm.orientation = [];
    fsm.RT = [];
end




function my_closefcn(src,eventdata)
global fsm
call_stop
fclose(fsm.ard);% end communication with arduino
fprintf('serial port closed\n')
delete(gcf);

function call_change_savedir(src,eventdata)
global fsm
folder_name = uigetdir;
fsm.savedir = folder_name;
set(fsm.handles.savedir, 'string',fsm.savedir);

function Xrng_speed_plot
global fsm
fsm.npointsX = fsm.spdxrng/fsm.spdavgbin;
fsm.handles.spdplot = plot(fsm.handles.ax(1),1:fsm.npointsX,ones(fsm.npointsX,1),'k','linewidth',2);
fsm.handles.spdRngHiLine = line([0 fsm.npointsX],[fsm.spdrnghigh fsm.spdrnghigh],'Linestyle','--','Linewidth',2,'Color','k','Parent',fsm.handles.ax(1));
fsm.handles.spdRngLoLine = line([0 fsm.npointsX],[fsm.spdrnglow fsm.spdrnglow],'Linestyle','--','Linewidth',2,'Color','k','Parent',fsm.handles.ax(1));

set(fsm.handles.ax(1),'xticklabel',[],'ylim',[-10,fsm.spdylim])

function call_change_spdrnghigh(src,eventdata)
global fsm
fsm.spdrnghigh = str2num(get(fsm.handles.spdrnghigh,'string'));
set(fsm.handles.spdRngHiLine,'ydata',[fsm.spdrnghigh;fsm.spdrnghigh]);
%ylim([-10 fsm.spdylim]);

function call_change_spdrnglow(src,eventdata)
global fsm
fsm.spdrnglow = str2num(get(fsm.handles.spdrnglow,'string'));
set(fsm.handles.spdRngLoLine,'ydata',[fsm.spdrnglow;fsm.spdrnglow]);
%ylim([-10 fsm.spdylim]);

function call_change_spdylim(src,eventdata)
global fsm
fsm.spdylim = str2num(get(fsm.handles.spdylim,'string'));
set(fsm.handles.ax(1),'ylim',[-10 fsm.spdylim]);

function call_change_spdxrng(src,eventdata)
global fsm
fsm.spdxrng = str2num(get(fsm.handles.spdxrng,'string'));
 Xrng_speed_plot
 
function RT = findrectiontime(triallog)
% contrast change 5 to 6, lick 6 to 7
ct1 = strfind(triallog, '_0to1');
ct2 = strfind(triallog(1:ct1(end)-1),'_');
ct = str2num(triallog(ct2(end)+1:ct1(end)-1));

lt1 = strfind(triallog, '_1to2');
if ~isempty(lt1)
    lt2 = strfind(triallog(1:lt1(end)-1),'_');
    lt = str2num(triallog(lt2(end)+1:lt1(end)-1));
    RT = (lt-ct)/1000;
else
    RT = NaN;
end

function updateRTplot
global fsm
if isnan(fsm.RT(end)); RT = fsm.Trewdavailable; else RT = fsm.RT(end);end
if ~isfield(fsm.handles,'RTplot')% if first call
   fsm.handles.RTplot = plot(fsm.handles.ax(2),1,RT,'k.');
   set(fsm.handles.ax(2),'ylim',[0 10]);
else
    switch fsm.attentionlocation{fsm.trialnum}
        case fsm.attentionlocationlist{1}
            cmrkr = 'k.';
        case fsm.attentionlocationlist{2}
            cmrkr = 'g.';
        case fsm.attentionlocationlist{3}
            cmrkr = 'b.';
        case fsm.attentionlocationlist{4}
            cmrkr = 'c.';
    end
    
    if fsm.mismatch(fsm.trialnum)
        cmrkr = 'ro';
    elseif isnan(fsm.RT(end)); % miss without mismatch
        cmrkr = 'y^';
    end
    plot(fsm.handles.ax(2),fsm.trialnum,RT,cmrkr);
    set(fsm.handles.ax(2),'ylim',[0 10]);
    
end

function choose_stim
global fsm
% fsm.attentionlocationlist = {'left','right','front','back'};
lrORfb = get(fsm.handles.lrORfb,'Value');
switch lrORfb
    case 1 % left/right
        % find out if blockwise or trial by trial
        blockORtbt = get(fsm.handles.blockORtbt,'Value');
        switch blockORtbt
            case 1 % blocks
                % is it time to change blocks?% trialnum is not yet incremented
                if fsm.trialnum+1 - fsm.blockchangetrial >= str2num(get(fsm.handles.ntrialsperblock,'String'))
                    fsm.blockchangetrial = fsm.trialnum+1;
                    if strcmp(fsm.attentionlocation{fsm.trialnum}, fsm.attentionlocationlist{1});%if its 'left'
                        fsm.attentionlocation{fsm.trialnum+1} = fsm.attentionlocationlist{2};% make it 'right'
                    else
                        fsm.attentionlocation{fsm.trialnum+1} = fsm.attentionlocationlist{1};% make it 'left'
                    end
                else
                    if fsm.trialnum == 0 % if first trial
                        fsm.attentionlocation{fsm.trialnum+1} = fsm.attentionlocationlist{1};
                    else
                        fsm.attentionlocation{fsm.trialnum+1} = fsm.attentionlocation{fsm.trialnum};
                    end
                end
            case 2 % trial by trial
                % choose left or right
                if rand>.5
                    fsm.attentionlocation{fsm.trialnum+1} = fsm.attentionlocationlist{1};% left
                else
                    fsm.attentionlocation{fsm.trialnum+1} = fsm.attentionlocationlist{2};% right
                end
        end
    case 2 % front/back
        % find out if blockwise or trial by trial
        blockORtbt = get(fsm.handles.blockORtbt,'Value');
        switch blockORtbt
            case 1 % blocks
                % is it time to change blocks?
                if fsm.trialnum+1 - fsm.blockchangetrial >= str2num(get(fsm.handles.ntrialsperblock,'String'))
                    fsm.blockchangetrial = fsm.trialnum+1;
                    if strcmp(fsm.attentionlocation{fsm.trialnum}, fsm.attentionlocationlist{3});%if its 'front'
                        fsm.attentionlocation{fsm.trialnum+1} = fsm.attentionlocationlist{4};% make it 'back'
                    else
                        fsm.attentionlocation{fsm.trialnum+1} = fsm.attentionlocationlist{3};% make it 'front'
                    end
                else
                    if fsm.trialnum == 0 % if first trial
                        fsm.attentionlocation{fsm.trialnum+1} = fsm.attentionlocationlist{3};
                    else
                        fsm.attentionlocation{fsm.trialnum+1} = fsm.attentionlocation{fsm.trialnum};
                    end
                end
            case 2 % trial by trial
                % choose left or right
                if rand>.5
                    fsm.attentionlocation{fsm.trialnum+1} = fsm.attentionlocationlist{3};% front
                else
                    fsm.attentionlocation{fsm.trialnum+1} = fsm.attentionlocationlist{4};% back
                end
        end
end
set(fsm.handles.attentionlocation,'String',['Stim location: ' fsm.attentionlocation{fsm.trialnum+1} ])

% This decides where the attention is focused, and where the cue (if any) will come
% now choose contrast change location
if rand < str2num(get(fsm.handles.pmismatch,'String')) % mismatch trial
    fsm.mismatch(fsm.trialnum+1) = 1;
    set(fsm.handles.mismatch,'String',['Mismatch trial: ' num2str(fsm.mismatch(fsm.trialnum+1))]); 
    if strcmp(fsm.attentionlocation{fsm.trialnum+1},fsm.attentionlocationlist{1})
        fsm.contrastchangelocation{fsm.trialnum+1} = fsm.attentionlocationlist{2}; 
    elseif strcmp(fsm.attentionlocation{fsm.trialnum+1},fsm.attentionlocationlist{2})
        fsm.contrastchangelocation{fsm.trialnum+1} = fsm.attentionlocationlist{1};
    elseif strcmp(fsm.attentionlocation{fsm.trialnum+1},fsm.attentionlocationlist{3})
        fsm.contrastchangelocation{fsm.trialnum+1} = fsm.attentionlocationlist{4};
    elseif strcmp(fsm.attentionlocation{fsm.trialnum+1},fsm.attentionlocationlist{4})
        fsm.contrastchangelocation{fsm.trialnum+1} = fsm.attentionlocationlist{3};
    end
else % no mismatch
    fsm.mismatch(fsm.trialnum+1) = 0;
    set(fsm.handles.mismatch,'String',['Mismatch trial: ' num2str(fsm.mismatch(fsm.trialnum+1))]);
    fsm.contrastchangelocation{fsm.trialnum+1} = fsm.attentionlocation{fsm.trialnum+1}; 
end
    
% Now choose the orientation from 8 options, go through list without replacement
if rem(fsm.trialnum,8) == 0
    fsm.orilist = randperm(8);
end
fsm.orientation(fsm.trialnum+1) = fsm.orilist(rem(fsm.trialnum,8)+1);
set(fsm.handles.orientation, 'String',['Orientation: ' num2str(fsm.orientation(fsm.trialnum+1))]);




    


