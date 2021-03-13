function lineIn = Serial_Receive_callback(command)
    switch command
        case 'read'
%             if exist("evalin('base','DSX')")
            try
                lineIn = readline(evalin('base','DSX'));
%             else
            catch
                Serial_Config_callback('init');
                lineIn = readline(evalin('base','DSX'));
            end
    end
% end function

