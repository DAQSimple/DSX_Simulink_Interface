function Serial_Config_callback(command,com,baud)
%% Input checks
initBaud = 115200;
timeOutString = 'DSX.Timeout = 1';
[ports,numports] = Serial_Get_Ports();  % get list of all com ports
likely_com = ports(numports);           % guess that the device is the last com port
%% Check globals
w=evalin('base','whos');
exist_globalCom = ismember('globalCom',[w(:).name]);
exist_globalBaud = ismember('globalCom',[w(:).name]);
exist_sBuffer = ismember('globalBaud',[w(:).name]);

if exist_globalCom>0
else
   assignin('base','globalCom',likely_com);     % assign likely_com to a globalCom in the base workspace.(we will use this variable to remember our choices)
end
if exist_globalBaud>0
else
   assignin('base','globalBaud',initBaud);      % assign initBaud to a globalBaud in the base workspace.        (^)
end
%% Fill empty function inputs with variables from base workspace
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
            w=evalin('base','whos');
            DSXexist = ismember('DSX',[w(:).name]);
            if DSXexist>0
                %nothing
                flush(evalin('base','DSX'));   
%                 dispp('A connection is already established.');
            else
               
                assignin('base','DSX',serialport(evalin('base','globalCom'),evalin('base','globalBaud')));
                evalin('base',timeOutString); % set DSX timeout 
%                 Serial_Send_callback('send','0000000000');
                fprintf('\nSuccessfully initialized DSX serial connection to %s at %u Baud.\n\n',evalin('base','globalCom'),evalin('base','globalBaud')); 
            end %try        
        case 'update'
            evalin('base', 'clear DSX');
            assignin('base','globalBaud',baud)
            
            if isstring(com)    % convert to char array
                com=char(com);
            end
            if com(1:3)=='COM'  % ensure input COM is real, handles "select a port" in config block
                assignin('base','globalCom',com)
            end
            assignin('base','DSX',serialport(evalin('base','globalCom'),evalin('base','globalBaud')));
            evalin('base',timeOutString); %set DSX timeout
            fprintf('\nSuccessfully closed old port and opened %s at %u Baud.\n\n', evalin('base','globalCom'),evalin('base','globalBaud')); 
    end %switch
end %function