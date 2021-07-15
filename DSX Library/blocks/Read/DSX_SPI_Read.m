function DSX_SPI_Read(block)
    setup(block);
    
% Define block properties    
function setup(block)
    block.NumDialogPrms = 0; %Number of variables to import from mask

    %% Register number of input and output ports
    block.NumInputPorts  = 0;
    block.NumOutputPorts = 1;

    %% Setup functional port properties
    block.OutputPort(1).SamplingMode = 'Sample'; 
    block.OutputPort(1).Dimensions       = 1;
    block.OutputPort(1).DatatypeID  = 0; % double -1: inherited
    block.OutputPort(1).Complexity  = 'Real';
    %% Set block sample time to inherited
    block.SampleTimes = [-1 0];

    %% Set the block simStateCompliance to default (i.e., same as a built-in block)
    block.SimStateCompliance = 'DefaultSimState';
    %% Register methods
    block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
%     block.RegBlockMethod('Start', @Start);
    block.RegBlockMethod('Update', @Update);
%     block.RegBlockMethod('Terminate', @Terminate); % Required
    
    
function DoPostPropSetup(block)
  block.NumDworks = 1;
  block.Dwork(1).Name            = 'lastloc';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = 0;
  
% At the start of the simulation
function InitializeConditions(block)
%% When block is initialized
    Serial_Config_callback('init'); 
    block.Dwork(1).Data = 9999; %initialize work vector as a locue that wont exist

function Update (block)
    spec = strcat('27', '00', '0','0000','0');
    DSX_Read_callback('readnext',spec); % read this stuff but dont use it, just reading into the buffer
    ping = DSX_Read_callback('checkbuffer',spec); % this reads only the buffer and checks for commands, updates buffer after
    %% Check Ping
    if numel(ping)>8 % not empty & 0
        [pingid, pingloc, pingsign, pingval, pingret] = splitping(ping); 
        VAL = str2num(pingval);
        block.OutputPort(1).Data = VAL;
    end  