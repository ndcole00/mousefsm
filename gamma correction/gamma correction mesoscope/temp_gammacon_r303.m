function out = temp_gammacon_r303(val,whichway)
%% converts luminance into RGB. The luminance value is a value between 0
%% and 1. One is the maximum luminance meassure in DELLs monitor and 0 is
%% the lower luminance. 
%% whichway can be 'rgb2lum' or 'lum2RGB'. 
%String argument can be either 'rgb2lum' or 'lum2rgb'

%      General model:
%        fit1(x) = (a*x)^b+c
       
% 8.7330    2.0819    2.8264
cfs = [ 8.7330    2.0819    2.8264];
a=cfs(1);
b=cfs(2);
c=cfs(3);
        
if strcmp('rgb2lum',whichway)
    out = (a.*val).^b+c; 
elseif strcmp('lum2rgb',whichway)    
    out = exp((log(val-c)./b)-log(a));
else
    disp('Invalid string input!')
    out = 0;
    return
end

return       