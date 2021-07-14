function DSX_Digital_Read(block)
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
    loc = strcat('0',num2str(loc));
    spec=[]; %will be what we send as a request to DSX
    
    %% Determine output based on case
    spec = strcat('11',num2str(loc),'0','0000','0'); %add zero to pin location
    DSX_Read_callback('readnext',spec); % read this stuff but dont use it, just reading into the buffer
    ping = DSX_Read_callback('checkbuffer',spec); % this reads only the buffer and checks for commands, updates variables 
    
    if numel(ping)>8 % not empty & 0
        [pingid, pingloc, pingsign, pingval, pingret] = splitping(ping); 
        if pingloc == loc
            block.OutputPort(1).Data = str2num(pingval); % OUTPUT VALUE
        end
    end 

function Terminate(block)
    flush(evalin('base','DSX'));
%endfunction

