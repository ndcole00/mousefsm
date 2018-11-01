rgbvalues = round(linspace(0,255,16));
%% Calibration done with monitor flickering in room 604 biozentrum,
%% monitor: Dellu2415b
%%%  brightness 50, contrast 50
% measurement 2014-10-13
l=[ % luminance in cd/m^2
 1 0.144
2 0.695
3 1.455
4 2.624
5 4.408
6 6.522
7 9.199
8 12.51
9 16.22
10 20.21
11 24.69
12 30.64
13 37.27
14 44.9
15 53.35
16 60.25
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
GammaTable_Dell_U2415b_bright50_cont50=out;
save ('C:\Jasper\Matlab\Adil\FSM_2p_setup\gamma corection 2p setup\GammaTable_Dell_U2415b_bright50_cont50', 'GammaTable_Dell_U2415b_bright50_cont50')

% Backlight=3
% Contrast=89
% Brightness=0