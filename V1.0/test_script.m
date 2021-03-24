% test_script
% message being sent
clear all;
clc;
x=1009100019;
% Initialize COM port
Serial_Config_callback('init');
% wait 1s
% pause(1)
% send x to DSX
Serial_Send_callback('send',x)
% wait 1s
% pause(1)
% get ping from DSX
bytes_available = evalin('base','DSX.NumBytesAvailable')
% pingfromDSX = Serial_Receive_callback('readnext')
readline(evalin('base','DSX'))