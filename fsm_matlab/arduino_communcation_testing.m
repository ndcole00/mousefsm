
arduino = serial('COM3')
fopen(arduino)
pause(5)

flushoutput(arduino)
fprintf(arduino, "3/n");
flushoutput(arduino)
%pause(10)

%fprintf(arduino, "4/n");
%message = fscanf(s,'%s\n')
%disp(message)
%pause(3)

%fprintf(s, "3/n")
%fclose(arduino)