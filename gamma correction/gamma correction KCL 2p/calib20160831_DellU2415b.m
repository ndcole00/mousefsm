rgbvalues = round(linspace(0,255,64));
%% Calibration done with monitor flickering in room 604 biozentrum,
%% monitor: Dellu2415b
%%%  brightness 75, contrast 75
% measurement 2014-10-13
l=[ % luminance in cd/m^2
 1 0.17
2 0.379
3 0.653
4 0.926
5 1.269
6 1.67
7 2.109
8 2.625
9 3.253
10 3.971
11 4.81
12 6.039
13 7.031
14 8.164
15 9.393
16 10.86
17 12.24
18 13.73
19 15.24
20 16.49
21 18.55
22 20.42
23 22.61
24 24.64
25 27.21
26 29.81
27 32.74
28 35.61
29 38.86
30 41.83
31 44.96
32 48.09
33 52.28
34 56.37
35 60.26
36 64.23
37 66.57
38 70.12
39 75.91
40 79.92
41 84.32
42 89.76
43 94.71
44 99.89
45 105
46 110.4
47 115.7
48 121.5
49 126.1
50 133.2
51 139.9
52 146.3
53 152
54 161.8
55 169
56 175.9
57 183.4
58 189.9
59 197.2
60 204.6
61 214.8
62 220.1
63 222.4
64 225.4
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
GammaTable_Dell_U2415b=out;
save ('M:\Data\Adil\BB2\Matlab\Gamma correction\GammaTable_Dell_U2415b', 'GammaTable_Dell_U2415b')

% Backlight=3
% Contrast=89
% Brightness=0