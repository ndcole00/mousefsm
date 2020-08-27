
%Connect To Camera
vid = videoinput('tisimaq_r2013_64', 1, 'Y800 (320x240)');
src = getselectedsource(vid);

vid.FramesPerTrigger = 1;
src.Exposure = 0.01;
src.Trigger = 'Enable';
triggerconfig(vid, 'hardware', 'hardware', 'hardware');
vid.TriggerRepeat = Inf;
vid.LoggingMode = 'memory';

%Connect To Teensy
arduino = serial('COM3')
fopen(arduino)
pause(5)


%Start Camera
preview(vid);
start(vid);
stoppreview(vid);
stop(vid);


%Send Messsage To Teensy
flushoutput(arduino)
fprintf(arduino, "2/n");
flushoutput(arduino)

