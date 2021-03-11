function Serial_Config_callback(command,com,baud)
%% Input checks
initBaud = 9600;
[ports,numports] = Serial_Get_Ports(); % get list of all com ports
likely_com = ports(numports);
%% Check globals
if ~exist('globalCom')
   assignin('base','globalCom',ports(numports));
end
if ~exist('globalBaud')
   assignin('base','globalBaud',9600);
end
%% Check baud input for type

%% Fill empty inputs
if ~exist('com')
    com = evalin('base','globalCom');
end 
if ~exist('baud')
    baud = evalin('base','globalBaud');
end
if isstring(baud) || ischar(baud)
    baud=str2double(baud);
end
%% Callback Commands
    switch command
        case 'clear'            
            evalin('base','clear')
            disp('Cleared base workspace.'); 
        case 'init'
            try 
                evalin('base','DSX');
                dispp('Connection already established.'); 
            catch
                assignin('base','DSX',serialport(evalin('base','globalCom'),evalin('base','globalBaud')));  
                fprintf('\nSuccessfully initialized DSX serial connection to %s at %u Baud.\n\n',evalin('base','globalCom'),evalin('base','globalBaud')); 
            end
          
%         case 'update_baud'    % old commands, combined into 'update' command
%             assignin('base','globalBaud',str2double(baud))                 % update globalBaud value with function input
%             assignin('base','DSX.BaudRate',evalin('base','globalBaud'));    % update DSX.BaudRate
%             dispp('updated DSX.Baudrate with globalBaud');  
%         case 'update_com'
%             globalCom = input;
%             DSXdevice = serialport(globalCom,str2double(globalBaud));
%             dispp('updated DSX with globalCom/Baud');
            %
        case 'update'
            evalin('base', 'clear DSX');
            assignin('base','globalBaud',baud)
            assignin('base','globalCom',com)
            assignin('base','DSX',serialport(evalin('base','globalCom'),evalin('base','globalBaud')));
            fprintf('\nSuccessfully closed old port and opened %s at %u Baud.\n\n', evalin('base','globalCom'),evalin('base','globalBaud')); 
    end
end