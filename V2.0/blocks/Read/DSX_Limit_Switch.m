function DSX_Limit_Switch(block)
% Latest change: 3/17/2021
% This function is the back end controlling the DSX Digital Read block.
setup(block);
    %endfunction
function setup(block)
%     block.NumDialogPrms =2; % initial conditions; led off
    block.NumDialogPrms = 2; % initial conditions; led off
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
    %% Read mask parameters into variables
    loc         = block.DialogPrm(1).Data;
    emerg_state = block.DialogPrm(2).Data;
    %% Convert block mask variables into DSX command
    limit_init = str2num(strcat(num2str(210),num2str(loc),num2str(emerg_state),'00000')); %add zero to pin location
    %% Send ping to lookout for limit switch / emergyency stop conditions
    Serial_Send_Callback('send', limit_init);
    
function Outputs(block)  
    
    
    pingreq=[]; %will be what we send as a request to DSX
    %% Determine output based on case

    if loc<10 
        pingreq = str2num(strcat(num2str(210),num2str(loc),'000000')); %add zero to pin location
    else
        pingreq = str2num(strcat(num2str(11),num2str(loc),'000000')); %no zero added as number has 2 digits
    end

    DSXval = Serial_Receive_callback('getval',pingreq);
    
    if ~isempty(DSXval)
        block.OutputPort(1).Data = str2num(DSXval);
    end    
function Terminate(block)
    flush(evalin('base','DSX'));
%endfunction

