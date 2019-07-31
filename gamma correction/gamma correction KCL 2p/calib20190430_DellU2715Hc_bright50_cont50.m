rgbvalues = round(linspace(0,255,16));
%% Calibration done with monitor flickering in room 604 biozentrum,
%% monitor: Dellu2415b
%%%  brightness 20, contrast 50
% measurement 2014-10-13
l=[ % luminance in cd/m^2
1 0.317
2 1.759
3 4.5
4 8.626
5 15.03
6 23.42
7 34.19
8 47.28
9 62.87
10 81.48
11 102.9
12 126.7
13 155.5
14 186.3
15 221.1
16 260.7
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
out(out>1)=1;
p = mfilename('fullpath');
GammaTable=out;
%save ('C:\Jasper\Matlab\Adil\FSM_2p_setup\gamma corection 2p setup\GammaTable_Dell_U2415b_bright20_cont50', 'GammaTable_Dell_U2415b_bright20_cont50')
save (p,'GammaTable')

% Backlight=3
% Contrast=89
% Brightness=0