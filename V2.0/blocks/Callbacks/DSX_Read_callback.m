function [pingOut] = DSX_Read_callback(command,spec)
%% Checks
w=evalin('base','whos');
exist_sBuffer = ismember('sBuffer',[w(:).name]);
% exist_sBuffer = ismember('dsx_struct',[w(:).name]);
% exist_sBuffer = exist('sBuffer');
if ~exist('spec')
    spec = [];
else
    spec = char(spec); % its char for sure now
end
%% Define current command in a struct
[id,loc,sign,val,ret] = splitping(spec);  

if exist_sBuffer  
    sBuffer = evalin('base','sBuffer');
else
    sBuffer = [];
end
pingOut = '0';
%% Commands
    switch command
        % no input needed, only specify 'read' 
        case 'readnext'
            %% Ask DSX for value 
            Serial_Send_callback('send',spec);
            %% Read next line in serial buffer
            pingOut = char(readline(evalin('base','DSX')));
            %% Ensure the command is valid, else discard
            if pingOut(1) >= 1 % is the first bit not 0 a.k.a its a command
                    new_sBuffer = [sBuffer;pingOut];      % add ping to end 
                    assignin('base','sBuffer',new_sBuffer); % update sBuffer in base workspace
            end        
        case 'checkBuffer'   
            % Are there pings of that command type in buffer
            if ~isempty(sBuffer)
            	locInBuffer=find(sBuffer(:,(1:2))==id);   
            else 
                locInBuffer = [];
            end
            %% If ping(s) we want are in buffer
            if ~isempty(locInBuffer)
                %% Grab oldest buffer value
                pullCmd = sBuffer(locInBuffer(1),:);        
                %% pingOut data if the LOC is correct
                if pullCmd(3:4) == loc % if the LOC values are consistent,
                    pingOut = pullCmd;
                    % Remove pulled value from buffer
                    sBuffer = sBuffer(sBuffer ~= pullCmd);
                    assignin('base','sBuffer',sBuffer); % update sBuffer in base workspace
                end
            else
                pingOut = '0';
            end
        
        case 'read'
            pingOut = readline(evalin('base','DSX'));       
    end
% end function