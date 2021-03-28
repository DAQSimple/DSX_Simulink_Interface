clc;
clear all;

sBuffer = 1;
w=evalin('base','whos');
exist_sBuffer = ismember('sBuffer',[w(:).name])
if exist_sBuffer >0
    A=1
end
