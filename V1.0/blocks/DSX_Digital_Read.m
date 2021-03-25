function DSX_Digital_Read(block)
% Latest change: 3/17/2021
% This function is the back end controlling the DSX Digital Read block.
setup(block);
    %endfunction
function setup(block)
%     block.NumDialogPrms =2; % initial conditions; led off
    block.NumDialogPrms =1; % initial conditions; led off
    %% Register number of input and output ports
    block.NumOutputPorts = 2;
    %% Setup functional port properties to dynamically
    %% inherited.
%     block.SetPreCompInpPortInfoToDynamic;
%     block.SetPreCompOutPortInfoToDynamic;
%% set properties for output ports
    block.OutputPort(1).SamplingMode = 'Sample'; 
    block.OutputPort(1).Dimensions       = 1;
    block.OutputPort(1).DatatypeID  = 0; % double -1: inherited
    block.OutputPort(1).Complexity  = 'Real';
    block.OutputPort(2).SamplingMode = 'Sample'; 
    block.OutputPort(2).Dimensions       = 1;
    block.OutputPort(2).DatatypeID  = 0; % double -1: inherited
    block.OutputPort(2).Complexity  = 'Real';
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
    block.RegBlockMethod('PostPropagationSetup',@DoPostPropSetup);
%     block.RegBlockMethod('Start', @Start);
    block.RegBlockMethod('Outputs', @Outputs);     % Required
    block.RegBlockMethod('Update', @Update);
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
%     block.Dwork(1).Data = block.DialogPrm(1).Data; % function: read where

    %% output inputs to base workspcae for debugging
%     assignin('base','func_s_func',block.Dwork(1).Data)
%     assignin('base','loc_s_func',block.Dwork(2).Data)
    %% init
    Serial_Config_callback('init');
    flush(evalin('base','DSX'));
function Update(block)
    block.Dwork(1).Data = block.DialogPrm(1).Data; % function: read what 
%     block.Dwork(2).Data = block.DialogPrm(2).Data; % location: read where
    loc = block.DialogPrm(1).Data;
function Outputs(block)  
    %% Refresh work vectors with updated mask parameters
    block.Dwork(1).Data = block.DialogPrm(1).Data; % function: read what 
%     block.Dwork(2).Data = block.DialogPrm(2).Data; % location: read where
    loc = block.DialogPrm(1).Data;
    temp=[]; %will be what we send as a request to DSX
    %% Determine output based on case

    if loc<10 
        temp = str2num(strcat(num2str(110),num2str(loc),'000000')); %add zero to pin location
    else
        temp = str2num(strcat(num2str(11),num2str(loc),'000000')); %no zero added as number has 2 digits
    end

    pingfromDSX = Serial_Receive_callback('read',temp);
    
    pingchar = num2str(pingfromDSX);
    if isempty(pingfromDSX)
    else
       val = str2num(pingchar(6:9));
       if pingchar(1:2) == '11'
           if val ~= 8888
              block.OutputPort(1).Data = val;
%               block.OutputPort(2).Data = pingfromDSX;
              assignin('base','val',val);
           end
       else
%            block.OutputPort(1).Data = 0;
       end
    end    
function Terminate(block)
    flush(evalin('base','DSX'));
%endfunction

