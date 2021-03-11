function a = Serial_Send_callback(command,message)
%% initial checks
        if ~exist('message')
            message = '';
        end
        if ~exist('command')
            command = 'null';
            disp('command not valid');
        end   
%% Commmands   
    switch command
        case 'send'
            writeline(evalin('base','DSX'),message);
            fprintf('\nSuccessfully sent "%s" to %s.\n',message ,evalin('base','DSX.Port')); 
        case 'init'        
            try % more of a debugging case than anything, shouldn't have to use this often.
                writeline(evalin('base','DSX'),'init');
                dispp('wrote  "init" to globalport/baud');
            catch
                assignin('base','DSX',serialport(evalin('base','globalCom'),evalin('base','globalBaud')));
                writeline(DSX,'init');
                dispp('catch: DSX not defined, but it is now. Also wrote init.');
            end %try
    end %switch
end %function