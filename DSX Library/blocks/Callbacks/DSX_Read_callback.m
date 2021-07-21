function [pingOut] = DSX_Read_callback(command,spec)
%% Checks
% tic();

try % attempt to see if we've checked this already
    CHECKED.read = evalin('base','CHECKED.read');
catch % if we havent, check it
    w=evalin('base','whos');
    exist_sBuffer = ismember('sBuffer',[w(:).name]);
    exist_DSX = ismember('DSX',[w(:).name]);
    % exist_sBuffer = ismember('dsx_struct',[w(:).name]);
    % exist_sBuffer = exist('sBuffer');
    CHECKED.read = 1;
    assignin('base','CHECKED',CHECKED);
end
%% Unnecessary
% if ~exist('spec')
%     spec = '';
% else 
%     spec = char(spec); % its char for sure now
% end
% if ~exist('command')
%     command = [];
% else 
%     command = char(lower(command)); % its char for sure now
% end
% a = toc();
% assignin('base','DSX_Read_start_checks',a);
% tic();
%% Split ping
[id,loc,sign,val,ret] = splitping(spec);
% a = toc();
% assignin('base','DSX_Read_splitping',a);
%% Checks

% tic();

if CHECKED.read == 1  
    sBuffer = evalin('base','sBuffer');
    DSX = evalin('base','DSX');
else
    sBuffer = [];
    Serial_Config_callback('init');
end
% a = toc();
% assignin('base','DSX_Read_if_exists',a);
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
                    new_sBuffer = [pingOut;sBuffer];      % add ping to start
                    
                    assignin('base','sBuffer',new_sBuffer); % update sBuffer in base workspace
            end        
        case 'checkbuffer'
%             tic();
            %% If ping(s) we want are in buffer
            [index,pingOut] = inBuffer(sBuffer, id, loc);
            if index >0
                %% clear sBuffer of that ping
                sBuffer(index,:) = [];
                assignin('base','sBuffer',sBuffer); % update sBuffer in base workspace     
            end
%             a = toc();
%             assignin('base','DSX_Read_check_buffer',a);
        case 'readcheck'
%             tic;
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
                    new_sBuffer = [pingOut;sBuffer];      % add ping to start
                    assignin('base','sBuffer',new_sBuffer); % update sBuffer in base workspace
            end
            
            %% If ping(s) we want are in buffer
            [index,pingOut] = inBuffer(sBuffer, id, loc);
            if index >0
                %% clear sBuffer of that ping
                sBuffer(index,:) = [];
                assignin('base','sBuffer',sBuffer); % update sBuffer in base workspace     
            end
%             a = toc();
%             assignin('base','READCHECK_time',a);
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