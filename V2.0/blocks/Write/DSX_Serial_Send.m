function DSX_Serial_Send(block)
  setup(block);
%endfunction
function setup(block)
  block.NumDialogPrms =1; % initial conditions; led off
  
  %% Register number of input and output ports
  block.NumInputPorts  = 0;
  block.NumOutputPorts = 0;
  
  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
%   block.InputPort(1).Dimensions        = 1;
%   block.InputPort(1).DirectFeedthrough = false;
%   
  %% Set block sample time to inherited
  block.SampleTimes = [-1 0];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';
  %% Register methods
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('PostPropagationSetup',@DoPostPropSetup);
%     block.RegBlockMethod('Start', @Start);
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
    Serial_Config_callback('init');
function Update (block)
  %% Initialize Dwork
       block.DialogPrm(1).Data;
       Serial_Send_callback('send',block.Dwork(1).Data);

function Terminate(block)
Serial_Send_callback('send',string(block.DialogPrm(1).Data));
flush(evalin('base','DSX'));
%endfunction

