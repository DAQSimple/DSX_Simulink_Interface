function DSX_PWM_Write(block)
  setup(block);
%endfunction
function setup(block)
    block.NumDialogPrms =2; % initial conditions; led off

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
  Serial_Config_callback('init');
  %% set PWM frequency once at start of simulation
  if size(block.DialogPrm(2).Data,2) == 5  % handles 32000 case, 1 bit too large
      Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data, '3200','15')); %shrink down to 4 bits
  else
      Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data,block.DialogPrm(2).Data,'15'))
  end
  block.Dwork(1).Data = 1337;
  
function Update (block)
%% Send user input value as PWM duty cycle to DSX
val = round(block.InputPort(1).DataAsDouble);
if val > 100
    val = 100;
end
% send command if it's different from the last sent, else nothing
if val ~= block.Dwork(1).Data
    Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data, val,'14'));
end
% save last value in work vector
block.Dwork(1).Data = val; 

function Terminate(block)
Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data, 0,'14')); % send final value, off
flush(evalin('base','DSX'));
%endfunction

function command = toCommand(pin,val,func)
% assignin('base','pin',pin);
% assignin('base','val',val);

%% Assign leading zero to pin value if necessary
if length(pin) == 1
    pin = strcat('0',pin);
end
%% Assign leading zeros to PWM value if necessary
val=num2str(val);
switch size(val,2)
    case 1
        val = strcat('000',val);
    case 2
        val = strcat('00',val);
    case 3
        val = strcat('0',val);
    case 4
        val = val;
end
command = sprintf('%i',str2num(strcat(func,pin,'1',val,'0')));
% assignin('base','pwmwritecommand',command);

