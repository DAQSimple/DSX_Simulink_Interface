function a = Serial_Send_callback(command,message)
%% Fill function inputs if not specified
    if ~exist('message')
        message = '';
    end
    if ~exist('command')
        command = 'null';
        dispp('command not valid');
    end
    if ~ischar(message)
        message=char(message);
    end

%% Commmands   
    switch command
        case 'send'
            writeline(evalin('base','DSX'),message);
        case 'init'        
                Serial_Config_callback('init');
        case 'waitping' % obsolete, was before stock serial timeout was discovered
            time0 = tic;
            timeLimit = 1;  % seconds
            while(evalin('base','DSX.NumBytesAvailable') == 0 && toc(time0)<timeLimit)
            end
            ping1 = Serial_Receive_callback('read');
            ping2 = num2str(ping1);
            ping1 = str2double(ping1);
            ping2 = strtrim(ping2);
            assignin('base','ping2',ping2);     % monitoring these myself in the base workspace
            assignin('base','ping1',ping1);     % for debugging purposes
            if ping1 > 0
                if   ping2(end) == '9'
                    dispp('good ping');
                else
                    dispp('not good ping');
                end
            end
    end %switch   
end %function