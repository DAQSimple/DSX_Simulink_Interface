function DSX_Servo_Write(block)
  setup(block);
%endfunction
function setup(block)
    block.NumDialogPrms =3; % initial conditions; led off

    %% Register number of input and output ports
    block.NumInputPorts  = 1;
    block.NumOutputPorts = 0;

    %% Setup functional port properties to dynamically
    %% inherited.
    block.SetPreCompInpPortInfoToDynamic;
    block.SetPreCompOutPortInfoToDynamic;

    block.InputPort(1).DatatypeID = -1;
    block.InputPort(1).Dimensions        = 1;
    block.InputPort(1).DirectFeedthrough = true;

    %% Set block sample time to inherited
    block.SampleTimes = [-1 0];

    %% Set the block simStateCompliance to default (i.e., same as a built-in block)
    block.SimStateCompliance = 'DefaultSimState';
  %% Register methods
    block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('Start', @Start);
    block.RegBlockMethod('Update', @Update);
    block.RegBlockMethod('Terminate', @Terminate); % Required
%endfunction
function DoPostPropSetup(block)
    block.NumDworks = 1;
    block.Dwork(1).Name            = 'lastval';
    block.Dwork(1).Dimensions      = 1;
    block.Dwork(1).DatatypeID      = 0;      % double
    block.Dwork(1).Complexity      = 'Real'; % real
    block.Dwork(1).UsedAsDiscState = 0;
function InitializeConditions(block)
%% When block is born
    Serial_Config_callback('init');
    block.Dwork(1).Data = 1337; %initialize work vector as a value that wont exist
    checkpins(block.DialogPrm(1).Data,"clr");
%% define PWM slot
function Start(block)
%% check pins for errors
checkpins(block.DialogPrm(1).Data,"check");
    
function Update(block)
%% Send user input value as servo angle to DSX
    
    val = round(block.InputPort(1).Data);
    lastval = block.Dwork(1).Data;
    
    minval = block.DialogPrm(2).Data;
    maxval = block.DialogPrm(3).Data;
    
    %% Send command if it's different from the last sent, else nothing
    if val ~= lastval
        if val > maxval
            val = maxval;
        elseif val < minval
            val = minval;
        end
        Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data, val));
    end
    %% Save last value in work vector
    block.Dwork(1).Data = val;   
function servowrite(block)
%% Send user input value as servo angle to DSX
    val = round(block.InputPort(1).Data);
    lastval = block.Dwork(1).Data;
    if val > 180
        val = 180;
    elseif val < 0
        val = 0;
    end
    %% Send command if it's different from the last sent, else nothing
    if val ~= lastval
        Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data, val));
    end
    %% Save last value in work vector
    block.Dwork(1).Data = val;   
function Terminate(block)
% Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data, 0)); % send final value, off
flush(evalin('base','DSX'));
%endfunction

function command = toCommand(pin,val)
% assignin('base','pwmpin',pin);
% assignin('base','pwmval',val);

%% Assign leading zero to pin value if necessary:
% if length(pin) == 1
%     pin = strcat('0',pin);
% end
%% Assign leading zeros to PWM value if necessary:
val=num2str(val);
switch size(val,2)
    case 1
        val = strcat('000',val);
    case 2
        val = strcat('00',val);
    case 3
        val = strcat('0',val);
end

command = strcat('16',pin,'1',val,'0');