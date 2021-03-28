% test_script% test_script
% message being sent
% clear all;
clc;
% clear all;
% message : has to be char array in matlab
x='1009100009'

% Initialize COM port
if ~exist('DSX')
    DSX = serialport('COM5',9600) % Create serialport object "DSX"
    DSX.Timeout = 1e-1;  % Set timeout
end
% send message
writeline(DSX,x)

% read ping
ping = readline(DSX)

