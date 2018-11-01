% Calculate and send a state matrix to an arduino 
% Adil Khan, Basel 2015


ard=serial('COM7','BaudRate',9600); % create serial communication object on port COM7 
set(ard,'Timeout',.1);
fopen(ard); % initiate arduino communication

stm = [11 1 12;2 66 4;34 21 55];

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

fclose(ard); % end communication with arduino
 