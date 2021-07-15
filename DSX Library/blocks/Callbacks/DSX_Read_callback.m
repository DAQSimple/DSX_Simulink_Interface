function [pingOut] = DSX_Read_callback(command,spec)
%% Checks
w=evalin('base','whos');
exist_sBuffer = ismember('sBuffer',[w(:).name]);
exist_DSX = ismember('DSX',[w(:).name]);
% exist_sBuffer = ismember('dsx_struct',[w(:).name]);
% exist_sBuffer = exist('sBuffer');
if ~exist('spec')
    spec = '';
else 
    spec = char(spec); % its char for sure now
end
if ~exist('command')
    command = [];
else 
    command = char(lower(command)); % its char for sure now
end
%% Define current command in a struct
[id,loc,sign,val,ret] = splitping(spec);  
%% Checks
if exist_sBuffer  
    sBuffer = evalin('base','sBuffer');
else
    sBuffer = [];
end
if exist_DSX
    DSX = evalin('base','DSX');
else
    Serial_Config_callback('init');
end
%% Initialize output
pingOut = '0';
%% Commands
    switch command
        % no input needed, only specify 'read' 
        case 'readnext'
            %% Ask DSX for value 
            writeline(DSX,spec);
            %% Read next line in serial buffer
            pingOut = char(readline(DSX));
            %% Ensure the command is valid, else discard
            if numel(pingOut)>9
                if pingOut(1:2) == '22'
                    f = errordlg('Simulation stopped due to SOS message from DSX', 'DSX Emergency Shutdown','modal');
                    set_param(gcs, 'SimulationCommand', 'stop');
                end
                    new_sBuffer = [sBuffer;pingOut];      % add ping to end 
                    assignin('base','sBuffer',new_sBuffer); % update sBuffer in base workspace
            end        
        case 'checkbuffer'
            %% If ping(s) we want are in buffer
            [index,pingOut] = inBuffer(sBuffer, id, loc);
            if index >0
                %% clear sBuffer of that ping
%                 sBuffer = sBuffer(sBuffer ~= sBuffer(:,index));
                sBuffer(index,:) = [];
                assignin('base','sBuffer',sBuffer); % update sBuffer in base workspace     
            end
        case 'simpleread'
            pingOut = readline(evalin('base','DSX'));
        case 'read'
             %% Ask DSX for value 
            writeline(DSX,spec);
            %% Read next line in serial buffer
            pingOut = char(readline(DSX));
            %% Ensure the command is valid, else discard
            if numel(pingOut)>9
                    new_sBuffer = [sBuffer;pingOut];      % add ping to end 
                    assignin('base','sBuffer',new_sBuffer); % update sBuffer in base workspace
                %% If ping(s) we want are in buffer
                [index,pingOut] = inBuffer(new_sBuffer, id, loc);
                if index >0
                    %% clear sBuffer of that ping
    %                 sBuffer = sBuffer(sBuffer ~= sBuffer(:,index));
                    new_Buffer(index,:) = [];
                    assignin('base','sBuffer',new_sBuffer); % update sBuffer in base workspace     
                end
            end
    end
% end function