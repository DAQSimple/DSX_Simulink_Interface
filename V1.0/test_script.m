%% test_script

% clear all;
% clc;

% messages
x=1009100019;
xoff=1009100009;
read07=1107000000;
a0=1320000000;

% Initialize COM port
Serial_Config_callback('init');
% pause(1)
% send x to DSX
% Serial_Send_callback('send',xoff)
% pause(1)

% get ping from DSX
% bytes_available = evalin('base','DSX.NumBytesAvailable')

VALUE = Serial_Receive_callback('getval',a0)