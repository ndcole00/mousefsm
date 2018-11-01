

ard=serial('COM3','BaudRate',9600); % create serial communication object on port COM7
set(ard,'Timeout',.1);
fopen(ard); % initiate arduino communication
npts=1000;
figure;
h = plot(1:npts,ones(npts,1),'k','linewidth',2);
rcvd1 = fscanf(ard,'%d');
while isempty(rcvd1)
    rcvd1 = fscanf(ard,'%d');
end
rcvd = fscanf(ard,'%d');
while rcvd>=-50;
    rcvd = fscanf(ard,'%d');
    if ~isempty(rcvd)
        olddat = get(h,'ydata');
        newdat = cat(2,olddat(2:end),rcvd);
        set(h,'ydata',newdat);
        drawnow
    else
        rcvd = 0;
    end
   
end
close all
fclose(ard); % end communication with arduino
fprintf('the end\n')