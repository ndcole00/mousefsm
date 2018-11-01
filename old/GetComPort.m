% INPUT: device name (e.g. 'Teensy USB Serial')
% OUTPUT: virtual com port the device is connected to 

% Basel 2016, orsolici
% Modified after: Answer by Vitaly Gavrilyuk on 6 Nov 2015, MathWorks Community 

function [port_name] = GetComPort (dev_name)

[~,res]=system('wmic path Win32_SerialPort');
ind = strfind(res,dev_name);
if (~isempty(ind))
    port_name = res(ind(1)+length(dev_name)+2:ind(1)+length(dev_name)+5);
   else
    fprintf(strcat(dev_name,' not found!'));
end

end