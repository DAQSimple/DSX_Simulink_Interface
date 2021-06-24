function DSX_PWM_Write(block)
    setup(block);
    %endfunction
function setup(block)
    block.NumDialogPrms = 2; % initial conditions; led off

    %% Register number of input and output ports
    block.NumInputPorts  = 2;
    block.NumOutputPorts = 0;

    %% Setup functional port properties to dynamically
    %% inherited.
    block.SetPreCompInpPortInfoToDynamic;
    block.SetPreCompOutPortInfoToDynamic;
    %% VAL Input
    block.InputPort(1).DatatypeID = -1;
    block.InputPort(1).Dimensions        = 1;
    block.InputPort(1).DirectFeedthrough = true;
    %% FREQ Input
    block.InputPort(2).DatatypeID = -1;
    block.InputPort(2).Dimensions        = 1;
    block.InputPort(2).DirectFeedthrough = true;

    %% Set block sample time to inherited
    block.SampleTimes = [-1 0];

    %% Set the block simStateCompliance to default (i.e., same as a built-in block)
    block.SimStateCompliance = 'DefaultSimState';
    %% Register methods
    block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('Start', @Start);
    block.RegBlockMethod('Update', @Update);
    block.RegBlockMethod('Terminate', @Terminate); % Required
%endfunction

function DoPostPropSetup(block)
    %% Work Vectors
    % Work Vector 1: For storing VAL between iterations
    block.NumDworks = 2;
    block.Dwork(1).Name            = 'lastval';
    block.Dwork(1).Dimensions      = 1;
    block.Dwork(1).DatatypeID      = 0;      % double
    block.Dwork(1).Complexity      = 'Real'; % real
    block.Dwork(1).UsedAsDiscState = 0;
    % Work Vector 2: For storing FREQ between iterations
    block.Dwork(2).Name            = 'lastfreq';
    block.Dwork(2).Dimensions      = 1;
    block.Dwork(2).DatatypeID      = 0;      % double
    block.Dwork(2).Complexity      = 'Real'; % real
    block.Dwork(2).UsedAsDiscState = 0;

function InitializeConditions(block)
    Serial_Config_callback('init'); % make sure port is set up
    block.Dwork(1).Data = 1337; %initialize work vector as a value that wont exist
    
function Start(block)
    block.Dwork(1).Data = 1337; %initialize work vector as a value that wont exist
    firstFREQ = round(block.InputPort(2).DataAsDouble);     
    
    if firstFREQ == 0 || firstFREQ < 0
        defaultFREQ = str2num(block.DialogPrm(2).Data);
        
        firstFREQ = defaultFREQ;
        
        setFreq(block,firstFREQ);
    end
   block.Dwork(2).Data = firstFREQ; 
    
function Update (block)
    %% Send user input value as PWM duty cycle to DSX
    FREQ = round(block.InputPort(2).DataAsDouble);
    if FREQ ~= block.Dwork(2).Data 
        setFreq(block,FREQ); % update the frequency if it's been changed on input 2
    end
    
    val = round(block.InputPort(1).DataAsDouble); % read input port 1 : VAL
    if val > 100
        val = 100;                                                                                                                             
    elseif val < 0
        val = 0;
    end
    % send command if it's different from the last sent, else nothing
    if val ~= block.Dwork(1).Data
        Serial_Send_callback('send',toCommand('14',block.DialogPrm(1).Data,'1', val,'0'));
    end
    % save last value in work vector
    block.Dwork(1).Data = val; 
    block.Dwork(2).Data = FREQ;

function Terminate(block)
    Serial_Send_callback('send',toCommand('14', block.DialogPrm(1).Data,'1','0000','0')); % send final value, off
    flush(evalin('base','DSX'));
    %endfunction

function command = toCommand(func,pin,sign,val,ret)
    % assignin('base','pin',pin);
    % assignin('base','val',val);

    %% Assign leading zero to pin value if necessary
    if length(pin) == 1
        pin = strcat('0',pin);
    end
    %% Assign leading zeros to VAL if necessary
    val=num2str(val);
    switch size(val,2)
        case 1
            val = strcat('000',val);
        case 2
            val = strcat('00',val);
        case 3
            val = strcat('0',val);
        case 4
            val = val;
    end
    command = sprintf('%i',str2num(strcat(func,pin,sign,val,ret)));
    
function setFreq(block,freq)
    %% set PWM frequency once at start of simulation
    freqs = num2str(freq); % convert freq to string array
    freq_digits = numel(freqs); % number of elements in array
    
    if freq_digits > 4  % handles 9999+ case, 1 bit too large
      sign = 1;
      freqs = freqs(1:end-1);
      ret = freqs(end);
      Serial_Send_callback('send',toCommand('15', block.DialogPrm(1).Data, sign, freqs, ret)); %shrink down to 4 bits
    else
        % send command to PIN with FREQ input value and SIGN = 0
      sign = 0;
      ret = 0;
      Serial_Send_callback('send',toCommand('15', block.DialogPrm(1).Data, sign, freqs, ret))
    end
    
    % set VAL as out of bounds
    block.Dwork(1).Data = 1337;
