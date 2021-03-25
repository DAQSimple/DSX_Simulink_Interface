function DSX_Digital_Write(block)
    setup(block);
    
function setup(block)
    block.NumDialogPrms =1; %Number of variables to import from mask

    %% Register number of input and output ports
    block.NumInputPorts  = 1;
    block.NumOutputPorts = 0;

    %% Setup functional port properties
    block.SetPreCompInpPortInfoToDynamic;
    block.SetPreCompOutPortInfoToDynamic;
    block.InputPort(1).Dimensions        = 1;
    block.InputPort(1).DirectFeedthrough = false
    %% Set block sample time to inherited
    block.SampleTimes = [-1 0];

    %% Set the block simStateCompliance to default (i.e., same as a built-in block)
    block.SimStateCompliance = 'DefaultSimState';
    %% Register methods
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('Update', @Update);
    block.RegBlockMethod('Terminate', @Terminate); % Required
    
function InitializeConditions()
    % evaluate at the start of the simulation
    Serial_Config_callback('init'); % Ensure serial port connection 
    % Flush serial buffer in case port already exists and buffer isnt empty 
    flush(evalin('base','DSX'));                                  

function Update (block)
% evaluate every time step
Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data, block.InputPort(1).Data));

function Terminate(block)
% when program is stopped or the block is deleted/destoyed
Serial_Send_callback('send',toCommand(block.DialogPrm(1).Data, 0)); % send final value, off
flush(evalin('base','DSX'));

function command = toCommand(pin,val)
% convert pin# and input value into a DSX 10-bit command
% assignin('base','pin',pin);   % put values in workspace: debugging 
% assignin('base','val',val);   % put values in workspace: debugging 
if val > 1
    val = 1;
end
if size(pin) == 1
    pin = strcat('0',pin);
end
command = sprintf('%i',str2num(strcat('10',pin,'1','000',num2str(val),'0')));
assignin('base','digitalwritecommand',command);


%% 