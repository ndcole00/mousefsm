% % Communications MatLab <--> Arduino
% % Matlab file 1 for use with Arduino file 1
% 
% 
% %s1 = serial('/dev/ttyUSB1');    % define serial port
% s1 = serial('COM7');
% s1.BaudRate=9600;               % define baud rate
% set(s1, 'terminator', 'LF');    % define the terminator for println
% fopen(s1);
%                           % signal the arduino to start collection
% w=fscanf(s1,'%s')             % must define the input % d or %s, etc.
% 
%   
%     fprintf(s1,'%s\n','B');     % establishContact just wants 
% 
%     aa = [13];
% fprintf(s1,'%d',aa);
% pause(1)
% v=fscanf(s1,'%d')
% 
% fclose(s1);


answer=1; % this is where we'll store the user's answer
ard=serial('COM7','BaudRate',9600); % create serial communication object on port COM4
 
fopen(ard); % initiate arduino communication

pause(2)
fprintf(ard,'%s','200,300,700')
fclose(ard); % end communication with arduino
 
while answer
    fprintf(ard,'%s',char(answer)); % send answer variable content to arduino
    answer=input('Enter led value 1 or 2 (1=ON, 2=OFF, 0=EXIT PROGRAM): '); % ask user to enter value for variable answer
end
 
fclose(ard); % end communication with arduino
 
