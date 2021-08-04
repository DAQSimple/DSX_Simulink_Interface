function DSX_Serial_Config(block)
    setup(block);
    
% Define block properties    
function setup(block)
    block.NumDialogPrms = 3; %Number of variables to import from mask

    %% Register number of input and output ports
    block.NumInputPorts  = 0;
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