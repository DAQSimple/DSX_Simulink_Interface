function DSX_Serial_Receive(block)
    setup(block);
    %endfunction
function setup(block)
    block.NumDialogPrms =0; % initial conditions; led off

    %% Register number of input and output ports
%     block.NumInputPorts  = 0;
    block.NumOutputPorts = 1;

    %% Setup functional port properties to dynamically
    %% inherited.
%     block.SetPreCompInpPortInfoToDynamic;
%     block.SetPreCompOutPortInfoToDynamic;
    block.OutputPort(1).SamplingMode = 'Sample';
    
    block.OutputPort(1).Dimensions       = 1;
    block.OutputPort(1).DatatypeID  = 0; % double -1: inherited
    block.OutputPort(1).Complexity  = 'Real';


    %% Set block sample time to inherited
    block.SampleTimes = [-1 0];

    %% Set the block simStateCompliance to default (i.e., same as a built-in block)
    block.SimStateCompliance = 'DefaultSimState';
    %% Register methods
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('PostPropagationSetup',@DoPostPropSetup);
%     block.RegBlockMethod('Start', @Start);
    block.RegBlockMethod('Outputs', @Outputs);     % Required
    block.RegBlockMethod('Terminate', @Terminate); % Required
    %endfunction

function DoPostPropSetup(block)
    %% Setup Dwork
    block.NumDworks = 2;
    block.Dwork(1).Name = 'function'; 
    block.Dwork(1).Dimensions      = 1;
    block.Dwork(1).DatatypeID      = 0;
    block.Dwork(1).Complexity      = 'Real';
    block.Dwork(1).UsedAsDiscState = true;
    block.Dwork(2).Name = 'x0'; 
    block.Dwork(2).Dimensions      = 1;
    block.Dwork(2).DatatypeID      = 0;
    block.Dwork(2).Complexity      = 'Real';
    block.Dwork(2).UsedAsDiscState = true;

function InitializeConditions(block)
    %% init
    Serial_Config_callback('init');
    
function Outputs(block)
    pingfromDSX = Serial_Receive_callback('read','');
    assignin('base','zzpingfromDSX',pingfromDSX);
    if ~isempty(pingfromDSX) && isstring(pingfromDSX)
        block.OutputPort(1).Data = str2num(pingfromDSX);
    end
function Terminate(block)
    flush(evalin('base','DSX'));
%endfunction
