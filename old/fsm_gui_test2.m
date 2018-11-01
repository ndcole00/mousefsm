function fsm_gui_test2()

global fsm

% Initiate
fsm.savedir = 'C:\BB2data\';
fsm.token = 'M100_B1';
fsm.fname = '';
fsm.spdrnghigh = 100;
fsm.spdrnglow = 0;
fsm.spdavgbin = .01;
fsm.spdylim = 100;
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
fsm.orientation = 0;
fsm.spatialfreq = 2;
fsm.temporalfreq = 2;
fsm.attention = {'left','right','up','down'};
fsm.attentionID = 1;
fsm.stateind = 0;
fsm.pmismatch = .05;
fsm.mismatch = 0;
fsm.blocks = 0;
fsm.ntrialsperblock = 100;
fsm.rewd = .1;
fsm.state = 0;
fsm.trialnum = 0;




%--------------------------------------------------------------------------
% make GUI

fsm.handles.f = figure('Units','normalized','Position',[0.1 0.1 0.7 0.7],...
    'Toolbar','figure');
set(fsm.handles.f,'CloseRequestFcn',@my_closefcn);

% plot image
fsm.ax(1)=axes('Parent',fsm.handles.f,'Units','normalized','Position',[0.65 0.55 0.33 0.4]);
title('Speed (cm/s)');ylim([-10 fsm.spdylim]);

fsm.ax(2)=axes('Parent',fsm.handles.f,'Units','normalized','Position',[0.65 0.05 0.33 0.4]);
title('Reaction Times (s)');

fsm.ax(3)=axes('Parent',fsm.handles.f,'Units','normalized','Position',[0.35 0 0.27 0.3]);
try imshow ('C:\Users\Adil\Google Drive\Matlab\ArduinoIO\contrast change task schematic.jpg');end

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
    'String',fsm.spdrnghigh,'FontSize',10,'Callback', @call_edit_spdrnghigh);

% spd rng low
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.75 0.2 0.04],...
    'String','Spped range low','FontSize',10);
fsm.handles.spdrnglow = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.75 0.1 0.04],...
    'String',fsm.spdrnglow,'FontSize',10,'Callback', @call_edit_spdrnglow);

% t cue delay
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.7 0.2 0.04],...
    'String','T cue delay','FontSize',10);
fsm.handles.Tcuedelay = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.7 0.1 0.04],...
    'String',fsm.Tcuedelay,'FontSize',10,'Callback', @call_edit_Tcuedelay);

% T cue duration
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.65 0.2 0.04],...
    'String','T cue duration','FontSize',10);
fsm.handles.Tcue = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.65 0.1 0.04],...
    'String',fsm.Tcue,'FontSize',10,'Callback', @call_edit_Tcue);

% T stim delay min
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.6 0.2 0.04],...
    'String','T stim delay min','FontSize',10);
fsm.handles.Tstimdelaymin = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.6 0.1 0.04],...
    'String',fsm.Tstimdelaymin,'FontSize',10,'Callback', @call_edit_Tstimdelaymin);

% T stim delay mean additional
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.55 0.2 0.04],...
    'String','T stim delay mean added','FontSize',10);
fsm.handles.Tstimdelaymeanadd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.55 0.1 0.04],...
    'String',fsm.Tstimdelaymeanadd,'FontSize',10,'Callback', @call_edit_Tstimdelaymeanadd);

% T contrast delay min
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.5 0.2 0.04],...
    'String','T contrast delay min','FontSize',10);
fsm.handles.Tcontrastdelaymin = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.5 0.1 0.04],...
    'String',fsm.Tcontrastdelaymin,'FontSize',10,'Callback', @call_edit_Tcontrastdelaymin);

% T contrast delay mean additional
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.45 0.2 0.04],...
    'String','T contrast delay mean added','FontSize',10);
fsm.handles.Tcontrastdelaymeanadd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.45 0.1 0.04],...
    'String',fsm.Tcontrastdelaymeanadd,'FontSize',10,'Callback', @call_edit_Tcontrastdelaymeanadd);

% T reward available
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.4 0.2 0.04],...
    'String','T reward available','FontSize',10);
fsm.handles.Trewdavailable = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.4 0.1 0.04],...
    'String',fsm.Trewdavailable,'FontSize',10,'Callback', @call_edit_Trewdavailable);

% inter trial interval
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.35 0.2 0.04],...
    'String','Inter trial interval','FontSize',10);
fsm.handles.Titi = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.35 0.1 0.04],...
    'String',fsm.Titi,'FontSize',10,'Callback', @call_edit_Titi);

% Speed averaging bin
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.3 0.2 0.04],...
    'String','Speed averaging bin','FontSize',10);
fsm.handles.spdavgbin = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.3 0.1 0.04],...
    'String',fsm.spdavgbin,'FontSize',10,'Callback', @call_edit_spdavgbin);

% Prob mismatch trials
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.25 0.2 0.04],...
    'String','Prob. mismatch trials','FontSize',10);
fsm.handles.mismatch = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.25 0.1 0.04],...
    'String',fsm.mismatch,'FontSize',10,'Callback', @call_edit_mismatch);

% Rewd valve duration
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.2 0.2 0.04],...
    'String','Reward valve duration','FontSize',10);
fsm.handles.rewd = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.2 0.1 0.04],...
    'String',fsm.rewd,'FontSize',10,'Callback', @call_edit_rewd);

% Starting Contrast
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.15 0.2 0.04],...
    'String','Starting contrast','FontSize',10);
fsm.handles.contrast = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.15 0.1 0.04],...
    'String',fsm.contrast,'FontSize',10,'Callback', @call_edit_contrast);

% Contrast change %
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.1 0.2 0.04],...
    'String','Contrast change %','FontSize',10);
fsm.handles.contrastchange = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.1 0.1 0.04],...
    'String',fsm.contrastchange,'FontSize',10,'Callback', @call_edit_contrastchange);

% Spatial freq
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.05 0.2 0.04],...
    'String','Spatial frequency','FontSize',10);
fsm.handles.spatialfreq = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.05 0.1 0.04],...
    'String',fsm.spatialfreq,'FontSize',10,'Callback', @call_edit_spatialfreq);

% Temporal freq
uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.02 0.005 0.2 0.04],...
    'String','Temporal frequency','FontSize',10);
fsm.handles.temporalfreq = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.23 0.005 0.1 0.04],...
    'String',fsm.temporalfreq,'FontSize',10,'Callback', @call_edit_temporalfreq);

%%% Indicators %%%

% Filename
fsm.handles.fname = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.9 0.26 0.04],...
    'String',['Filename: ' fsm.fname],'FontSize',10,'HorizontalAlignment','left');

% State
fsm.handles.state = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.85 0.26 0.04],...
    'String',['State: ' num2str(fsm.state)],'FontSize',10,'HorizontalAlignment','left');

% Attention
fsm.handles.attention = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.8 0.26 0.04],...
    'String',['Attention: ' fsm.attention{fsm.attentionID}],'FontSize',10,'HorizontalAlignment','left');

% Mismatch trial
fsm.handles.mismatch = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.75 0.26 0.04],...
    'String',['Mismatch trial: ' num2str(fsm.mismatch)],'FontSize',10,'HorizontalAlignment','left');

% Grating orientation
fsm.handles.orientation = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.7 0.26 0.04],...
    'String',['Orientation: ' num2str(fsm.orientation)],'FontSize',10,'HorizontalAlignment','left');

% Trial number
fsm.handles.orientation = uicontrol('Parent',fsm.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.35 0.65 0.26 0.04],...
    'String',['Trial number: ' num2str(fsm.trialnum)],'FontSize',10,'HorizontalAlignment','left');

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
fsm.ard=serial('COM7','BaudRate',9600); % create serial communication object on port COM7
set(fsm.ard,'Timeout',.1);
fopen(fsm.ard); % initiate arduino communication
fprintf('serial port opened\n')

function call_start(src,eventdata)
global fsm
DateString = datestr(now,'yyyymmdd_HHMMSS');
fsm.fname = fullfile(fsm.savedir,[get(fsm.handles.token,'string') '_' DateString]);
set(fsm.handles.fname,'String',fsm.fname)
set(fsm.handles.start,'enable','off')
set(fsm.handles.stop,'enable','on')
drawnow;
make_state_matrix


function make_state_matrix
global fsm
keeprunning = 1;fsm.stop = 0;
while keeprunning
   
    holdt = 1;
    iti = 0.001;
    rewdt = 2;
    
    stm = [... % remember zero indexing

    %  spd in   spd out     Tup     Timer   digiOut
        0           0        1      .1          0 ;...% state 0 init
        2           1        1       10         0 ;...% state 1 wait for speed in
        2           2        3      .1          1 ;...% state 2 blink on entering target speed
        3           1        4      holdt       0 ;...% state 3 hold speed
        4           4        5      rewdt       1 ;...% state 4 rewd
        5           5        99     iti         0 ;...% state 5 ITI
        ];

    stm (:,4) = stm(:,4)*1000; % sec to ms
    rcvd = '';
    % send an 'A' and receive a 'B'
    while ~strcmp(rcvd,'B');
        fprintf(fsm.ard,'%s','A');
        rcvd = fscanf(fsm.ard,'%s')
    end

    % send [nRows nCols]
    [row, col] = size(stm);
    fprintf(fsm.ard,'%s',num2str([row col]));

    % wait for signal that its been received
    rcvd = '';
    while ~strcmp(rcvd,'C');
        rcvd = fscanf(fsm.ard,'%s')
    end

    % send stm row by row
    for r = 1:row
        if r < row
            fprintf(fsm.ard,'%s\n',num2str(stm(r,:)));
        else
            fprintf(fsm.ard,'%s',num2str(stm(r,:)));
        end
    end
    
    % send signal to end
    rcvd = fscanf(fsm.ard,'%s')
    fprintf(fsm.ard,'%s','>');
   
    
    while ~strcmp(rcvd,'E'); % it will send an E when trial ends
        rcvd = fscanf(fsm.ard,'%s')
        if fsm.stop == 1
            keeprunning = 0;
            break
        end
        disp(rand)
        drawnow
        %spd = input('Speed: ');
        %fprintf(ard,'%d',spd);
    end
end
fprintf('make state matrix ended\n')

function call_stop(src,eventdata)
global fsm
fsm.stop = 1;
set(fsm.handles.start,'enable','on')

fclose(fsm.ard);% end communication with arduino
fopen(fsm.ard); % initiate arduino communication
fprintf('serial port reset\n')

function my_closefcn(src,eventdata)
global fsm
fclose(fsm.ard);% end communication with arduino
fprintf('serial port closed\n')
delete(gcf);

function call_change_savedir(src,eventdata)
global fsm
folder_name = uigetdir;
fsm.savedir = folder_name;
set(fsm.handles.savedir, 'string',fsm.savedir);

