rgbvalues = round(linspace(0,255,16));
%% Calibration done with monitor flickering in behaviour room, KCL 4.23L
%% monitor: DellP2219H
%%%  brightness 50, contrast 50
% measurement 2019/10/02
l=[ % luminance in cd/m^2
1 0.575
2 0.726
3 1.355
4 2.534
5 4.151
6 6.615
7 9.831
8 13.66
9 18.36
10 24
11 30.1
12 37.66
13 44.34
14 51.74
15 59.97
16 68.29
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
%save ('C:\Users\Behaviour Only One\Documents\MATLAB\mousefsm\gamma correction\gamma correction KCL 2p\GammaTable_Dell_P2219H_bright50_cont50', 'GammaTable_Dell_P2219H')
save (p,'GammaTable')
% Backlight=3
% Contrast=89
% Brightness=0