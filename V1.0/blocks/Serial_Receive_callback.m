function fromDSX = Serial_Receive_callback(command,spec)
%% Ensure DSX exists
Serial_Config_callback('init')
%% Checks
if ~exist('spec')
    spec = [];
end
if isstring(spec)
   spec = str2num(spec); 
end
    switch command
        case 'read'
            time0 = tic;
            timeLimit = 1e-3;
            % Ask for value
            Serial_Send_callback('send',spec)
            % Wait for ping, 1ms timtout
            while(evalin('base','DSX.NumBytesAvailable') == 0 && toc(time0)<timeLimit)end
            fromDSX = readline(evalin('base','DSX'));
     
            if isstring(fromDSX)    % Convert to int
                fromDSX = str2num(fromDSX);
            end
            if fromDSX == 0  % if empty, send emtpy code
               fromDSX = 6969696969;
            end
             if fromDSX == [] % if empty, send emtpy code
               fromDSX = ':(';
            end
            
%         case 'readenc' 
%             % Initialize timeout
%             time0 = tic;
%             timeLimit = 1e-3;
%             % Ask for value
%             Serial_Send_callback('send',spec)
%             % Wait for ping, 1ms timtout
%             while(evalin('base','DSX.NumBytesAvailable') == 0 && toc(time0)<timeLimit)end
%             fromDSX = readline(evalin('base','DSX'));
%             if str2num(fromDSX) == 0
%                fromDSX = 6969696969;
%             end
    end
% end function

