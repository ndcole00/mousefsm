rgbvalues = round(linspace(0,255,16));
%% Calibration done with monitor flickering in room 604 biozentrum,
%% monitor: Dellu2415b
%%%  brightness 20, contrast 50
% measurement 2014-10-13
l=[ % luminance in cd/m^2
1 0.036
2 .212
3 .528
4 1.094
5 1.865
6 2.891
7 4.187
8 5.727
9 7.535
10 9.695
11 12.07
12 14.77
13 17.95
14 21.31
15 24.87
16 28.36
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
GammaTable=out;
fname = mfilename('fullpath'); 
save (fname, 'GammaTable')

% Backlight=3
% Contrast=89
% Brightness=0