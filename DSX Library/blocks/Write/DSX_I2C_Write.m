function DSX_I2C_Write(block)
    setup(block);
    
% Define block properties    
function setup(block)
    block.NumDialogPrms = 3; %Number of variables to import from mask

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
%% When block is initialized
    Serial_Config_callback('init'); 
    block.Dwork(1).Data = 1337; %initialize work vector as a value that wont exist
   
function Start(block)
    block.Dwork(1).Data = 1337; %initialize work vector as a value that wont exist

function Update (block)
%% Every Time step
    valIn = round(block.InputPort(1).DataAsDouble); % Data input to block
    %% Round to logic ON or OFF
    sign = 0;
    if valIn > 100  % Too big
        val = 100;
        sign = 0;  
    elseif valIn >= 0 % Positive and acceptable
        val = valIn;
        sign = 0;
    elseif valIn < 0 && valIn > -100 % Negative and acceptable
        val = abs(valIn);
        sign = 1;
    elseif valIn <= -100 % Negative and too big
        val = 100;
        sign = 1;
    else
        val = 0;
    end
    %% Processing

    intOut = bitor(val, bitshift(sign,7));    
    
    %% only send command if it's unique from last
    if valIn ~= block.Dwork(1).Data 
        Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data,intOut));
    end
    %% save current value in work vector for next iteration
    block.Dwork(1).Data = valIn; % save current value for next update


function Terminate(block)
%% When program is stopped or the block is deleted
    Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data,0)); % send final value, off
    flush(evalin('base','DSX'));


function command = toCommand(loc,val)
%% Convert pin# and input value into a DSX 10-bit command
val = num2str(val);
loc = num2str(loc);
switch numel(val)
    case 1
        val = strcat('000',val);
    case 2
        val = strcat('00',val);
    case 3
        val = strcat('0',val);
    case 4
        val = val;
end            
    command = strcat('23','0',loc,'0',val,'0');