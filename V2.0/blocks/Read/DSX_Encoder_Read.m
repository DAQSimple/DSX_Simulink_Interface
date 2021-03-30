function DSX_Encoder_Read(block)
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

%% Set block sample time to inherited
    block.SampleTimes = [-1 0];
%% Set the block simStateCompliance to default (i.e., same as a built-in block)
    block.SimStateCompliance = 'DefaultSimState';
%% Register methods (what functions we'll use)
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('Outputs', @Outputs);     % Required
    block.RegBlockMethod('Terminate', @Terminate); % Required
    %endfunction

function InitializeConditions(block)
    Serial_Config_callback('init');
    flush(evalin('base','DSX'));  
function Outputs(block)  
    loc = block.DialogPrm(1).Data;
    temp=[]; %will be what we send as a request to DSX
    %% Determine output based on case

    temp = str2num(strcat(num2str(17),num2str(loc),'000000')); %no zero added as number has 2 digits


    [DSXval,DSXsign] = Serial_Receive_callback('getval',temp);
    
    if ~isempty(DSXval)
        if DSXsign == '1'   % if positive sign
            block.OutputPort(1).Data = str2num(DSXval);
            block.OutputPort(2).Data = str2num(DSXsign);
        elseif DSXsign == '0'   % if negative sign
            block.OutputPort(1).Data = -str2num(DSXval);
            block.OutputPort(2).Data = str2num(DSXsign);
        end
%         block.OutputPort(2).Data = DSXval;
    end    
function Terminate(block)
    flush(evalin('base','DSX'));
%endfunction

