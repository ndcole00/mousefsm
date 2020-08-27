function IDs = fetchScreensAndComport(data)
rootPath = 'C:\FSM_Settings';

switch lower(data)
    case 'screens'
        % Load screen configuration
        load(fullfile(rootPath, 'Screen_Configuration.mat'), 'screen_configuration')
        IDs = [screen_configuration{2:3}];
    case 'com'
        % Load comport settings
        load(fullfile(rootPath, 'Serial_Port_Allocations.mat'), 'serial_matrix')
        IDs = serial_matrix{1};
end

end