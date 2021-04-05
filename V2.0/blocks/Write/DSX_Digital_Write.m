function DSX_Digital_Write(block)
    setup(block);
    
% Define block properties    
function setup(block)
    block.NumDialogPrms =1; %Number of variables to import from mask

    %% Register number of input and output ports
    block.NumInputPorts  = 1;
    block.NumOutputPorts = 0;

    %% Setup functional port properties
    block.SetPreCompInpPortInfoToDynamic;
    block.SetPreCompOutPortInfoToDynamic;
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
    
function DoPostPropSetup(block)
  block.NumDworks = 1;
  block.Dwork(1).Name            = 'lastval';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = 0;
  
% At the start of the simulation
function InitializeConditions(block)
    Serial_Config_callback('init'); % Ensure serial port connection 
    % Flush serial buffer in case port already exists and buffer isnt empty 
    flush(evalin('base','DSX'));
    block.Dwork(1).Data = 1337; %initialize work vector as neither 0 or 1
% Every time step
function Start(block)
    block.Dwork(1).Data = 1337; %initialize work vector as neither 0 or 1
    assignin('base','startDwork',block.Dwork(1).Data);
function Update (block)
    assignin('base','Dworkupdate',block.Dwork(1).Data);
    val = block.InputPort(1).Data; % Data input to block
    if val >= 0.5  % 0 or 1
        val = 1;
    else
        val = 0;
    end
    
    if val ~= block.Dwork(1).Data % only send command if it's unique from last
        Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data, val));
        assignin('base','sentVal',val);
    end
    block.Dwork(1).Data = val; % save current value for next update
    assignin('base','DworkVal',val);
    
% When program is stopped or the block is deleted
function Terminate(block)
    Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data, 0)); % send final value, off
    flush(evalin('base','DSX'));

% Convert pin# and input value into a DSX 10-bit command
function command = toCommand(pin,val)
    if size(pin) == 1
        pin = strcat('0',pin);
    end
    command = sprintf('%i',str2num(strcat('10',pin,'1','000',num2str(val),'0')));
    assignin('base','digitalwritecommand',command);