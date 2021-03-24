% test_script% test_script
% message being sent
clear all;
clc;
% message : has to be char array in matlab
x='1009100019'

% Initialize COM port
DSX = serialport('COM5',9600)

% Set timeout
DSX.Timeout = 1e-1;

% send message
writeline(DSX,x)

% read ping
ping = readline(DSX)

