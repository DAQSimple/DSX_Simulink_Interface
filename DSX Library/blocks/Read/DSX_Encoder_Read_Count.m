function DSX_Encoder_Read_Count(block)
% Latest change: 3/17/2021
% This function is the back end controlling the DSX Digital Read block.
setup(block);
    %endfunction
function setup(block)
%     block.NumDialogPrms =2; % initial conditions; led off
    block.NumDialogPrms =1; % initial conditions; led off
    %% Register number of input and output ports
    block.NumOutputPorts = 1;
    %% Setup functional port properties to dynamically
    %% inherited.
%     block.SetPreCompInpPortInfoToDynamic;
%     block.SetPreCompOutPortInfoToDynamic;
%% set properties for output ports
    block.OutputPort(1).SamplingMode = 'Sample'; 
    block.OutputPort(1).Dimensions       = 1;
    block.OutputPort(1).DatatypeID  = 0; % double -1: inherited
    block.OutputPort(1).Complexity  = 'Real';
%     block.OutputPort(2).SamplingMode = 'Sample'; 
%     block.OutputPort(2).Dimensions       = 1;
%     block.OutputPort(2).DatatypeID  = 0; % double -1: inherited
%     block.OutputPort(2).Complexity  = 'Real';

%% Set block sample time to inherited
    block.SampleTimes = [-1 0];
%% Set the block simStateCompliance to default (i.e., same as a built-in block)
    block.SimStateCompliance = 'DefaultSimState';
%% Register methods (what functions we'll use)
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('Start', @Start);
    block.RegBlockMethod('Outputs', @Outputs);     % Required
    block.RegBlockMethod('Terminate', @Terminate); % Required
    %endfunction

function InitializeConditions(block)
    Serial_Config_callback('init'); 

function Start(block)
    %% load CPR from mask
    CPR = block.DialogPrm(1).Data;
    %% if no numbers are in the STR (invalid entry), str2num() will return [], which will return 1 from isempty()
    if isempty(str2num(CPR))
        f = errordlg('Invalid CPR input. Please only enter numbers :)', 'Encoder Count Error','modal');
        set_param(gcs, 'SimulationCommand', 'stop');
    end
    %% Make sure its 4 bits
    switch numel(CPR)
        case 1
            CPR = strcat('000',CPR);
        case 2
            CPR = strcat('00',CPR);
        case 3
            CPR = strcat('0',CPR);
        case 4
            CPR = CPR;
    end
    %% Send command
    spec = strcat('28','00','0',CPR,'0');
    Serial_Send_callback('send',spec); % send final value, off
    
function Outputs(block)  
    spec = strcat('29','00','000000'); 
%     DSX_Read_callback('readnext',spec); % read this stuff but dont use it, just reading into the buffer
    ping = DSX_Read_callback('readcheck',spec); % this reads only the buffer and checks for commands, updates variables
    %% hello jay
    if numel(ping)>8 % not empty & 0
        [pingid, pingloc, pingsign, pingval, pingret] = splitping(ping);
        if pingsign == '0'
            block.OutputPort(1).Data = str2num(pingval);
        elseif pingsign == '1'
            block.OutputPort(1).Data = -str2num(pingval);
        end
    end
    
function Terminate(block)
    flush(evalin('base','DSX'));
%endfunction

