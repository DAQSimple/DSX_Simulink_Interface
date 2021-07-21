function checkpins(loc,func)
if func == "check"
    try
        pins = evalin('base','pins');
    catch
        pins.out.pwm1 = 0;
        pins.out.pwm2 = 0;
    end
    %% Check
    if loc == '11'  
        if pins.out.pwm1 == 1
            f = errordlg('More than one block is assigned to PWM/Servo 1.', 'Digital Output Error','modal');
            set_param(gcs, 'SimulationCommand', 'stop');
        else
            pins.out.pwm1 = 1;
        end
        
    elseif loc == '12'    
        if pins.out.pwm2 == 1 % if the pin has already been assigned
            f = errordlg('More than one block is assigned to PWM/Servo 2.', 'Digital Output Error','modal');
            set_param(gcs, 'SimulationCommand', 'stop');
        else
            pins.out.pwm2 = 1; 
        end
    end
elseif func == "clr"
   pins.out.pwm1 = 0;
   pins.out.pwm2 = 0;
end
    %% save updated pins in base workspace
    assignin('base','pins',pins);
    