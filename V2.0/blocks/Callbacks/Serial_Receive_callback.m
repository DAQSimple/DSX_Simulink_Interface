function [output] = Serial_Receive_callback(command,spec)
%% Ensure DSX exists
% Serial_Config_callback('init')

%% Checks

w=evalin('base','whos');
exist_sBuffer = ismember('sBuffer',[w(:).name]);
% exist_sBuffer = ismember('dsx_struct',[w(:).name]);
% exist_sBuffer = exist('sBuffer');

if ~exist('spec')
    spec = [];
end

if isstring(spec)
   spec = char(spec); 
elseif isnumeric(spec)
    spec=num2str(spec);
end
%% Define current command in a struct
    [id,loc,sign,val,ret] = splitping(spec);  

if exist_sBuffer  
    evalin('base','sBuffer');
else
    assignin('base','sBuffer',[]);
end
fromDSX = '0';
fromDSXsign = '0';
%% Commands
    switch command
        % no input needed, only specify 'read' 
        case 'readnext'
            %% Ask DSX for value 
            Serial_Send_callback('send',spec);
            %% Read next line in serial buffer
            fromDSX = char(readline(evalin('base','DSX')));
            %% Convert to a number, gets rid of LF
            fromDSXnum = str2num(fromDSX);
            %% Ensure the command is valid, else discard
            if fromDSX(1) >= 1 % is the first bit not 0 a.k.a its a command
                    sBuffer = evalin('base','sBuffer');   % import old serial buffer from base workspace
                    new_sBuffer = [sBuffer;fromDSXchar];      % add ping to end 
                    assignin('base','sBuffer',new_sBuffer); % update sBuffer in base workspace
            end 
           
            
        case 'checkBuffer'
            % import old serial buffer from base workspace
            sBuffer = evalin('base','sBuffer');        

            % Are there pings of that command type in buffer
            if ~isempty(sBuffer)
            	locInBuffer=find(sBuffer(:,(1:2))==ping.cmd);   
            else 
                locInBuffer = [];
            end
            %% If ping(s) we want are in buffer
            if ~isempty(locInBuffer)
                %% Grab oldest buffer value
                pullCmd = sBuffer(locInBuffer(1),:);
                          
                pullCmdChar = pullCmd; % Idk why this exists, pullCmd and pullCmdchar are more chars
                %% Output data if the LOC is correct
                if pullCmdChar(3:4) == ping.loc % if the LOC values are consistent,
                    
                    fromDSXstruct.loc = pullCmdChar(3:4);
                    fromDSXstruct.cmd = pullCmdChar(1:2);    
                    fromDSXstruct.sign = pullCmdChar(5);
                    fromDSXstruct.val = pullCmdChar(6:9);
                    fromDSXstruct.ret = pullCmdChar(10);

                    % send ping out
                    fromDSX = str2num(pullCmd);
                    fromDSXsign = fromDSXstruct.sign;

                    % Remove pulled value from buffer
                    sBuffer = sBuffer(sBuffer ~= pullCmd);
                    assignin('base','sBuffer',sBuffer); % update sBuffer in base workspace
                end
            else
                fromDSX = 0;
            end
        
        case 'read'

            fromDSX = readline(evalin('base','DSX'));

        case 'getval'
            %% Accepts an input command of 10 digits to send to DSX, receives
            % ping back and returns the value and sign bits of ping
            
            %% send command to simulink asking for value
            Serial_Send_callback('send',spec);  

            %% read value sent from DSX
            fromDSXchar = readline(evalin('base','DSX'));
       
            %% if the ping wasnt empty, process ping
            if ~isempty(fromDSXchar)
                fromDSXnum=str2num(fromDSXchar);
            %% Store command in buffer if valid, else discard
                if fromDSXnum > 1000000000
                    % Convert from strin to char              
                    fromDSXval = fromDSXchar(end-4:end-1);            
                    if fromDSXval=='8888' % Ignore if value is 8888
                        %do nothing with ping, discard
                    else %store add to buffer
                        % import old serial buffer from base workspace
                        sBuffer = evalin('base','sBuffer');  
                        
                        % add ping to end
                        new_sBuffer = [sBuffer;fromDSXchar];
                        %debug
                        assignin('base','new_sBuffer',new_sBuffer);
                        
                        % what command are we looking for the value of?
                        cmd = spec(1:2);
                        
                        % Are there pings of that command type in buffer
                        locInBuffer=find(new_sBuffer(:,(1:2))==cmd); 
                        assignin('base', 'locInBuffer',locInBuffer);
                        %% If ping(s) we want are in buffer
                        if ~isempty(locInBuffer)
                            % Get oldest value from buffer
                            pullPing = new_sBuffer(locInBuffer(1),:);
                            assigninbase('base','monitoringwithmanraj',pullPing);
                            
                            % Convert to char for indexing
                            pullPingchar = num2str(pullPing);
                            
                            % FINALLY extract value from ping
                            fromDSX = pullPingchar(end-4:end-1);
                            fromDSXsign = pullPingchar(end-5);
                            % Remove pulled value from buffer
                            new_sBuffer = new_sBuffer(new_sBuffer ~= pullValue);
                        end
                        assignin('base','sBuffer',new_sBuffer); % update sBuffer in base workspace
                    end
                end

            else % if there was nothing to read, return zero
                fromDSX = [];
                fromDSXsign = [];
            end
            
         case 'stop'
            %% Accepts an input command of 10 digits to send to DSX, receives
            % ping back and returns the value and sign bits of ping
            
            %% send command to simulink asking for value
            Serial_Send_callback('send',spec)  

            %% read value sent from DSX
            fromDSX = readline(evalin('base','DSX'));
       
            %% if the ping wasnt empty, process ping
            if ~isempty(fromDSX)
                fromDSXnum=str2num(fromDSX);
            %% Store command in buffer if valid, else discard
                if fromDSXnum > 1000000000
                    % Convert from strin to char
                    fromDSXchar = fromDSX;
                    fromDSXval = fromDSXchar(end-4:end-1); 
                    fromDSXsign = fromDSXchar(end-5);
                    if fromDSXval=='8888' % Ignore if value is 8888
                        %do nothing with ping, discard
                    else %store add to buffer
                        % import old serial buffer from base workspace
                        sBuffer = evalin('base','sBuffer');  
                        
                        % add ping to end
                        new_sBuffer = [sBuffer;fromDSXchar];
                        %debug
                        assignin('base','new_sBuffer',new_sBuffer);
                        
                        % what command are we looking for the value of?
                        cmd = spec(1:2);
                        
                        % Are there pings of that command type in buffer
                        locInBuffer=find(new_sBuffer(:,(1:2))==cmd);                               
                        %% If ping(s) we want are in buffer
                        if ~isempty(locInBuffer)
                            % Get oldest value from buffer
                            pullValue = new_sBuffer(locInBuffer(1),:);
                            
                            % Convert to char for indexing
                            pullValue = num2str(pullValue);
                            
                            % FINALLY extract value from ping
                            fromDSX = pullValue(end-4:end-1);
                            
                            % Remove pulled value from buffer
                            new_sBuffer = new_sBuffer(new_sBuffer ~= pullValue);
                        end
                        assignin('base','sBuffer',new_sBuffer); % update sBuffer in base workspace
                    end
                end

            else % if there was nothing to read, return zero
                fromDSX = [];
                fromDSXsign = [];
            end
            
        case 's'
            %% Accepts an input command of 10 digits to send to DSX, receives
            % ping back and returns the value and sign bits of ping       
            %% send command to simulink asking for value 
            fromDSX = readline(evalin('base','DSX'));
       
            %% if the ping wasnt empty, process ping
            if ~isempty(fromDSX)
                fromDSXnum=str2num(fromDSX);
            %% Store command in buffer if valid, else discard
                if fromDSXnum > 1000000000
                    % Convert from strin to char
                    fromDSXchar = fromDSX;
                    fromDSXval = fromDSXchar(end-4:end-1); 
                    fromDSXsign = fromDSXchar(end-5);
                    if fromDSXval=='8888' % Ignore if value is 8888
                        %do nothing with ping, discard
                    else %store add to buffer
                        % import old serial buffer from base workspace
                        sBuffer = evalin('base','sBuffer');  
                        
                        % add ping to end
                        new_sBuffer = [sBuffer;fromDSXchar];
                        %debug
                        assignin('base','new_sBuffer',new_sBuffer);
                        
                        % what command are we looking for the value of?
                        cmd = spec(1:2);
                        
                        % Are there pings of that command type in buffer
                        locInBuffer=find(new_sBuffer(:,(1:2))==cmd);                               
                        %% If ping(s) we want are in buffer
                        if ~isempty(locInBuffer)
                            % Get oldest value from buffer
                            pullValue = new_sBuffer(locInBuffer(1),:);
                            
                            % Convert to char for indexing
                            pullValue = num2str(pullValue);
                            
                            % FINALLY extract value from ping
                            fromDSX = pullValue(end-4:end-1);
                            
                            % Remove pulled value from buffer
                            new_sBuffer = new_sBuffer(new_sBuffer ~= pullValue);
                        end
                        assignin('base','sBuffer',new_sBuffer); % update sBuffer in base workspace
                    end
                end

            else % if there was nothing to read, return zero
                fromDSX = [];
                fromDSXsign = [];
            end
            
    end
% end function