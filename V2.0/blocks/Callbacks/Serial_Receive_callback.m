function fromDSX = Serial_Receive_callback(command,spec)
%% Ensure DSX exists
% Serial_Config_callback('init')


%% Checks
w=evalin('base','whos');
% exist_sBuffer = ismember('sBuffer',[w(:).name]);
% exist_sBuffer = exist('sBuffer');

if ~exist('spec')
    spec = [];
end
if isstring(spec)
   spec = char(spec); 
elseif isnumeric(spec)
    spec=num2str(spec);
end
% if exist_sBuffer>0
if ~exist('sBuffer')
    assignin('base','sBuffer','');
end
%% Commands
    switch command
        % no input needed, only specify 'read' 
        case 'readnext'
            %% Read next line in serial buffer
            fromDSX = readline(evalin('base','DSX'));
            %% Convert to a number, gets rid of LF
            try 
                fromDSX = str2num(fromDSX);
            catch % if there was nothing to read, do nothing
            end
            %% Make a char copy
            fromDSXchar = num2str(fromDSX);
                
            %% Ensure the command is valid, else discard
            if fromDSX > 1000000000
                if fromDSXchar(end-4:end-1)=='8888' % Value slots
                    %do nothing with ping, discard
                else
                    sBuffer = evalin('base','sBuffer');   % import old serial buffer from base workspace
                    new_sBuffer = [sBuffer;fromDSX];      % add ping to end 
                    assignin('base','sBuffer',new_sBuffer); % update sBuffer in base workspace
                end
            end  
        case 'read'
%             % Accepts an input command of 10 digits to send to DSX, receives
%             % ping back and stores in a MATLAB array as a buffer.
%             
%             % send command to simulink 
%             Serial_Send_callback('send',spec)  
% 
%             % read value sent from DSX
%             fromDSX = readline(evalin('base','DSX'));
%             %% Convert to a number, gets rid of LF
%             if ~isempty(fromDSX) 
%                 fromDSX = str2num(fromDSX);
%             else % if there was nothing to read, set to zero
%                 fromDSX = 0;
%             end
%     
%             %% Ensure the command is valid, else discard
%             if fromDSX > 1000000000
%                 fromDSXchar = num2str(fromDSX); % Make a char copy, makes ping indexable
%                 if fromDSXchar(end-4:end-1)=='8888' % Value slots
%                     %do nothing with ping, discard
%                 else
%                     sBuffer = evalin('base','sBuffer');   % import old serial buffer from base workspace
%                     new_sBuffer = [sBuffer;fromDSX];      % add ping to end 
%                     assignin('base','sBuffer',new_sBuffer); % update sBuffer in base workspace
%                 end
%             end
        case 'getval'
            %% Accepts an input command of 10 digits to send to DSX, receives
            % ping back and returns the value bits of ping
            
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
                    fromDSXchar = num2str(fromDSXnum);
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
            end
            
            
    end
% end function