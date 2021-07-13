clc
clear all

% new_sBuffer=['133334';'123334';'155334';'214334'];
% cmd = '21';
% locInBuffer=find(new_sBuffer(:,(1:2))==cmd);                               
% %% If ping(s) we want are in buffer
% if ~isempty(locInBuffer)
%     % Get oldest value from buffer
%     pullValue = new_sBuffer(locInBuffer(1),:);
% 
%     % Convert to char for indexing
%     pullValue = num2str(pullValue)
% 
%     % FINALLY extract value from ping
%     fromDSX = pullValue(end-4:end-1)
% 
%     % Remove pulled value from buffer
%     new_sBuffer = new_sBuffer(new_sBuffer ~= pullValue)
% end
% 
% 
% spec = '2107100000';
%     ping.cmd = spec(1:2);
%     ping.loc = spec(3:4);
%     ping.sign = spec(5);
%     ping.val = spec(6:9);
%     ping.ret = spec(10);



% 
% 
% locInBuffer=find(sBuffer(:,(3))=='3')   

% sBuffer
% readlim = '2108100001';
% \
readA0 = '1313000000';
DSX = serialport("COM6",2e6);
% configureTerminator(s,"CR")
 writeline(DSX, readA0);
 
valback = readline(DSX)

% % %% test_script
% % 
% % % clear all;
% % % clc;
% % 
% % % messages
% % x=1009100019;
% % xoff=1009100009;
% % read07=1107000000;
% % a0=1320000000;
% % 
% % % Initialize COM port
% % Serial_Config_callback('init');
% % % pause(1)
% % % send x to DSX
% % % Serial_Send_callback('send',xoff)
% % % pause(1)
% % 
% % % get ping from DSX
% % % bytes_available = evalin('base','DSX.NumBytesAvailable')
% % 
% % VALUE = Serial_Receive_callback('getval',a0)