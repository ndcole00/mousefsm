rgbvalues = round(linspace(0,255,16));
%% Calibration done with monitor flickering in behaviour only room,
%% monitor: Dellp2219h
%%%  brightness 50, contrast 50
% measurement 2019-09-11
l=[ % luminance in cd/m^2
1 
2 
3 
4 
5 
6 
7 
8 
9 
10 
11 
12 
13 
14 
15 
16 
];

figure;plot(rgbvalues(l(:,1)),l(:,2),'o'), ylabel('luminance (cd/m^2)')

% fitting 
n   = [rgbvalues(l(:,1))./255]';
lum = l(:,2)./l(end,2);
f = fittype('(a*x)^b+c'); 
[fit1,gof1] = fit(n,lum,f,'Lower',[-Inf,-Inf,0]);
cfs=coeffvalues(fit1)

lfit = gammacon_r303(n,'rgb2lum',cfs);

figure;plot(n,lum,'ro');ylabel('normalized luminance');
hold on;plot(n,lfit);
figure;plot(n,lum,'ro');ylabel('normalized luminance'); hold on, plot(fit1,'b')

%% GammaTable
n2=[0:255]./255;
out = gammacon_r303(n2,'lum2rgb',cfs);
figure, plot(n2,out)
out(end)=1;
GammaTable_Dell_U2415b_bright20_cont50=out;
save ('C:\C:\Users\Behaviour Only One\Documents\MATLAB\mousefsm\gamma correction\gamma correction mesoscope\calib20190911_DellP2219H_bright50_cont50.m', 'GammaTable_Dell_U2415b_bright20_cont50')

% Backlight=3
% Contrast=89
% Brightness=0