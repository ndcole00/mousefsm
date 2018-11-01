rgbvalues = round(linspace(0,255,16));
%% Calibration done with monitor flickering in room 604 biozentrum,
%% monitor: Dellu2415b
%%%  brightness 20, contrast 50
% measurement 2014-10-13
l=[ % luminance in cd/m^2
1 0.061
2 .326
3 .67
4 1.166
5 1.948
6 2.938
7 4.112
8 5.491
9 7.336
10 9.461
11 11.55
12 14.44
13 17.61
14 20.8
15 24.75
16 27.76
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
save ('C:\Jasper\Matlab\Adil\FSM_2p_setup\gamma corection 2p setup\GammaTable_Dell_U2415b_bright20_cont50', 'GammaTable_Dell_U2415b_bright20_cont50')

% Backlight=3
% Contrast=89
% Brightness=0