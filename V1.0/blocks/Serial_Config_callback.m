function Serial_Config_callback(command,com,baud)
%% Input checks
initBaud = 9600;
[ports,numports] = Serial_Get_Ports();  % get list of all com ports
likely_com = ports(numports);           % guess that the device is the last com port
%% Check globals
if ~exist('globalCom')
   assignin('base','globalCom',likely_com);     % assign likely_com to a globalCom in the base workspace.(we will use this variable to remember our choices)
end
if ~exist('globalBaud')
   assignin('base','globalBaud',initBaud);      % assign initBaud to a globalBaud in the base workspace.        (^)
end
%% Fill empty inputs with variables from base workspace
if ~exist('com')
    com = evalin('base','globalCom');     
end 
if ~exist('baud')
    baud = evalin('base','globalBaud');
end
%% Convert input baud rate to an integer
if isstring(baud) || ischar(baud)
    baud=str2double(baud);
end
%% Callback Commands
    switch command
        case ' '
            %intentionally blank, only generates variables above if needed
        case 'clear'
%             evalin('base','clear')
%             disp('Cleared base workspace.'); 
            clear all;
        case 'init'
            try 
                evalin('base','DSX');
                dispp('Connection already established.'); 
            catch
                assignin('base','DSX',serialport(evalin('base','globalCom'),evalin('base','globalBaud')));  
                fprintf('\nSuccessfully initialized DSX serial connection to %s at %u Baud.\n\n',evalin('base','globalCom'),evalin('base','globalBaud')); 
            end %try
        case 'update'
            evalin('base', 'clear DSX');
            assignin('base','globalBaud',baud)
            assignin('base','globalCom',com)
            assignin('base','DSX',serialport(evalin('base','globalCom'),evalin('base','globalBaud')));
            fprintf('\nSuccessfully closed old port and opened %s at %u Baud.\n\n', evalin('base','globalCom'),evalin('base','globalBaud')); 
    end %switch
end %function