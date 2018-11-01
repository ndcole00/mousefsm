% Calculate and send a state matrix to an arduino
% Adil Khan, Basel 2015


ard=serial('COM7','BaudRate',9600); % create serial communication object on port COM7
set(ard,'Timeout',.1);
fopen(ard); % initiate arduino communication


while 1
    
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
        fprintf(ard,'%s','A');
        rcvd = fscanf(ard,'%s')
    end
    
    % send [nRows nCols]
    [row, col] = size(stm);
    fprintf(ard,'%s',num2str([row col]));
    
    % wait for signal that its been received
    rcvd = '';
    while ~strcmp(rcvd,'C');
        rcvd = fscanf(ard,'%s')
    end
    
    % send stm row by row
    for r = 1:row
        if r < row
            fprintf(ard,'%s\n',num2str(stm(r,:)));
        else
            fprintf(ard,'%s',num2str(stm(r,:)));
        end
    end
    % send signal to end
    rcvd = fscanf(ard,'%s')
    fprintf(ard,'%s','>');
    
    while ~strcmp(rcvd,'E'); % it will send an E when trial ends
        rcvd = fscanf(ard,'%s')
        %spd = input('Speed: ');
        %fprintf(ard,'%d',spd);
    end
end
fclose(ard); % end communication with arduino
