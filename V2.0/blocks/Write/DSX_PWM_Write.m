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
 
  block.InputPort(1).Dimensions        = 1;
  block.InputPort(1).DirectFeedthrough = true;
  
  %% Set block sample time to inherited
  block.SampleTimes = [-1 0];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';
  %% Register methods
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('PostPropagationSetup',@DoPostPropSetup);
    block.RegBlockMethod('Start', @Start);
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
  %% Execute when anything in block is updated or block is loaded
  Serial_Config_callback('init');
  %% set PWM frequency to frequency specified in mask
  if size(block.DialogPrm(2).Data,2) == 5
      Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data, '3200')); %shrink down to 4 bits
  end
  Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data, block.DialogPrm(2).Data));

  
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
assignin('base','pin',pin);
assignin('base','val',val);

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

command = sprintf('%i',str2num(strcat('14',pin,'1',val,'0')));
assignin('base','pwmwritecommand',command);

