function DSX_Serial_Receive(block)
    setup(block);
    %endfunction
function setup(block)
    block.NumDialogPrms =2; % initial conditions; led off

    %% Register number of input and output ports
%     block.NumInputPorts  = 0;
    block.NumOutputPorts = 1;

    %% Setup functional port properties to dynamically
    %% inherited.
%     block.SetPreCompInpPortInfoToDynamic;
%     block.SetPreCompOutPortInfoToDynamic;
    block.OutputPort(1).SamplingMode = 'Sample';
    
    block.OutputPort(1).Dimensions       = 1;
    block.OutputPort(1).DatatypeID  = 0; % double
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
%     block.RegBlockMethod('Update', @Update);
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
    %% Initialize Dwork
    block.Dwork(1).Data = block.DialogPrm(1).Data; % function: read what 
    block.Dwork(2).Data = block.DialogPrm(2).Data; % location: read where
    %% output inputs to base workspcae for debugging
    assignin('base','func_s_func',block.Dwork(1).Data)
    assignin('base','loc_s_func',block.Dwork(2).Data)
    %% init
    Serial_Config_callback('init');
    flush(evalin('base','DSX'));
function Outputs(block)
    %% Defines
    loc = block.DialogPrm(2).Data;
    temp=[]; %will be what we send as a request to DSX
    pingfromDSX =1111111111;
    %% Determine output based on case
    switch block.Dwork(1).Data
        case 1 % GPIO: ask for value of loc pin
            if loc<10 
                temp = str2num(strcat(num2str(100),num2str(loc),'000000')); %add zero to pin location
            else
                temp = str2num(strcat(num2str(10),num2str(loc),'000000')); %no zero added as number has 2 digits
            end
            pingfromDSX = Serial_Receive_callback('read',temp);
        case 2
            temp = 1702000000; % ask for encoder value 
            pingfromDSX = Serial_Receive_callback('read',temp);
    end
    assignin('base','pingfromDSXb4',pingfromDSX);
    if isempty(pingfromDSX)
        pingfromDSX = 1337420;
    end
    assignin('base','pingfromDSXafter',pingfromDSX);
    block.OutputPort(1).Data = pingfromDSX;
    
function Update(block)
    %% Refresh work vectors with updated mask parameters
    block.Dwork(1).Data = block.DialogPrm(1).Data; % function: read what 
    block.Dwork(2).Data = block.DialogPrm(2).Data; % location: read where
function Terminate(block)
    flush(evalin('base','DSX'));
%endfunction

