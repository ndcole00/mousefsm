%Setup Camera
video_input_object = videoinput('tisimaq_r2013_64', 1, 'Y800 (320x240)');   %Create Video Input Object
video_source = getselectedsource(video_input_object);                       %Connect This Object To The Camera

stop(video_input_object);
stoppreview(video_input_object);

triggerconfig(video_input_object, 'hardware', 'hardware', 'hardware');      %Set Camera To Use Hardware Trigger
video_input_object.FramesPerTrigger = 1;     
video_input_object.TriggerRepeat = Inf;                                     %Tell Camera To Capture 1 Frame Per Trigger

video_source.Gain = 63;                                                     %Set Camera to Have Gain of 63 (max)
video_source.Exposure = 0.012;                                              %Set Camera To Have Exposure of 0.012ms (max for this frame rate)

%Set Camera Save Settings
save_directory = 'C:\Eye_Cam_Videos\';                                      %Set Directory Where Videos Will Be Saved
mouse_name = 'El Mause';                                                    %Set Name Of Mouse
timestamp = datestr(now,'yyyy-mm-dd-HH-MM-SS');                             %Get Current Time
full_directory = strcat(save_directory, mouse_name, "_", timestamp, ".avi") %Combine These Strings Into Full Video File Name

%video_input_object.LoggingMode = 'disk';                                   
%diskLogger = VideoWriter('C:\Eye_Cam_Videos\R2018b.avi', 'Grayscale AVI');
%video_input_object.DiskLogger = diskLogger;


preview(video_input_object);
start(video_input_object);
%Connect To Teensy]
%teensy_com_port = 'COM3';
%teensy = serial(teensy_com_port)
%fopen(teensy)
%fprintf(teensy, 1)