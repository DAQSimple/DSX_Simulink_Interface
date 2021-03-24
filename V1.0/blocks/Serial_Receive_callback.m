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
if ~exist('sBuffer')
    assignin('base','sBuffer',[0]);
end
%% Commands
    switch command
        % no input needed, only specify 'read' 
        case 'readnext'  
            fromDSX = readline(evalin('base','DSX'));
            
            if isstring(fromDSX)                         % Convert to int
                fromDSX = str2num(fromDSX);
            end
            
            sBuffer = evalin('base','sBuffer');   % import old serial buffer from base workspace
            new_sBuffer = [sBuffer;fromDSX];        
            assignin('base','sBuffer',new_sBuffer)
            
        case 'read'
            % Accepts an input command of 10 digits to send to DSX, receives
            % ping back and stores in a MATLAB array as a buffer.
            
            % send command to simulink 
            Serial_Send_callback('send',spec)  

            % read value sent from DSX
            fromDSX = readline(evalin('base','DSX'));
            %Convert from scientific notation
           
            % convert to a number if possible
            if isstring(fromDSX)                         
                fromDSX = str2num(fromDSX);
            end
           
            %% ISSUE EXISTS HERE: old_sBuffer stays empty despite sBuffer in Base workspace not being empty.
            
            % Copy current sBuffer from base workspace
            old_sBuffer = evalin('base','sBuffer');
            
            % Create a new array with new command appended  
            new_sBuffer = [old_sBuffer;fromDSX]; 
       
            %% Update our perosonal serial buffer in the base workspace
            assignin('base','sBuffer',new_sBuffer) 
            %% assign uneeded variables in base workspace for debugging
            assignin('base','fromDSX',fromDSX)
    end
% end function