function DSX_Servo_Write(block)
  setup(block);
%endfunction
function setup(block)
  block.NumDialogPrms =1; % initial conditions; led off
  
  %% Register number of input and output ports
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 0;
  
  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions        = 1;
  block.InputPort(1).DirectFeedthrough = false;
  
  %% Set block sample time to inherited
  block.SampleTimes = [-1 0];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';
  %% Register methods
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('PostPropagationSetup',@DoPostPropSetup);
    block.RegBlockMethod('Start', @Start);
%     block.RegBlockMethod('Outputs', @Outputs);     % Required
    block.RegBlockMethod('Update', @Update);
    block.RegBlockMethod('Terminate', @Terminate); % Required
%endfunction

function DoPostPropSetup(block)
 %% Setup Dwork
  block.NumDworks = 2;
  block.Dwork(1).Name = 'x0'; 
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  block.Dwork(1).UsedAsDiscState = true;
  block.Dwork(2).Name = 'x1'; 
  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0;
  block.Dwork(2).Complexity      = 'Real';
  block.Dwork(2).UsedAsDiscState = true;

function InitializeConditions(block)
    %% initialize
  Serial_Config_callback('init');
  flush(evalin('base','DSX'));
function Start (block)
%  block.Dwork(1).Data = block.DialogPrm(1).Data;
%  block.Dwork(2).Data = block.InputPort(1).Data;
 Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data, block.InputPort(1).Data));
 
function Update (block)
Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data, block.InputPort(1).Data));

function Terminate(block)
% Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data, 0)); % send final value, off
flush(evalin('base','DSX'));
%endfunction

function command = toCommand(pin,val)
assignin('base','pwmpin',pin);
assignin('base','pwmval',val);

%% Assign leading zero to pin value if necessary:
if length(pin) == 1
    pin = strcat('0',pin);
end
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

%Convert to integer to avoid siecntific notation troubles, then output
%concatenated command:
command = sprintf('%i',str2num(strcat('16',pin,'1',val,'0'))) %convert from scientific
assignin('base','servowritecommand',command);

