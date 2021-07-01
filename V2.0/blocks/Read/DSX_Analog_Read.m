function DSX_Analog_Read(block)
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
    
%% Set block sample time to inherited
    block.SampleTimes = [0.001, 0];
    
%% Set the block simStateCompliance to default (i.e., same as a built-in block)
    block.SimStateCompliance = 'DefaultSimState';
%% Register methods (what functions we'll use)
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
    block.RegBlockMethod('Outputs', @Outputs);     % Required
    block.RegBlockMethod('Terminate', @Terminate); % Required
    %endfunction
 
function DoPostPropSetup(block)
    %% Work Vectors
    % Work Vector 1: For storing VAL between iterations
    block.NumDworks = 1;
    block.Dwork(1).Name            = 'lastval';
    block.Dwork(1).Dimensions      = 1;
    block.Dwork(1).DatatypeID      = 0;      % double
    block.Dwork(1).Complexity      = 'Real'; % real
    block.Dwork(1).UsedAsDiscState = 0;
    
 function InitializeConditions(block)
    Serial_Config_callback('init');
    flush(evalin('base','DSX'));
    block.Dwork(1).Data = 9999; 
function Outputs(block)  
    loc = block.DialogPrm(1).Data; 
    %% Serial
    spec = strcat('13', num2str(loc), '000000');
    DSX_Read_callback('readnext',spec); % read this stuff but dont use it, just reading into the buffer
    ping = DSX_Read_callback('checkBuffer',spec); % this reads only the buffer and checks for commands, updates variables
    assignin('base','A0ping',ping);
    %% Check Ping
    if numel(ping)>1 % not empty & 0
        [pingid, pingloc, pingsign, pingval, pingret] = splitping(ping); 
        if pingloc == loc
            VAL = str2num(pingval);
%                 assignin('base','AreadVAL',VAL);
                block.OutputPort(1).Data = double(VAL);
        end
    end  
function Terminate(block)
    flush(evalin('base','DSX'));
%endfunction

