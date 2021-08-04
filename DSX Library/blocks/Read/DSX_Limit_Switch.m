function DSX_Limit_Switch(block)
% Latest change: 3/17/2021
% This function is the back end controlling the DSX Digital Read block.
setup(block);
    %endfunction
function setup(block)
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
    block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('Start', @Start);
%     block.RegBlockMethod('Outputs', @Outputs);     % Required
%     block.RegBlockMethod('Terminate', @Terminate); % Required
    %endfunction

function DoPostPropSetup(block)
    %% Work Vectors
    % Work Vector 1: For storing VAL between iterations
    block.NumDworks = 1;
    block.Dwork(1).Name            = 'DSXcommand';
    block.Dwork(1).Dimensions      = 1;
    block.Dwork(1).DatatypeID      = 0;      % double
    block.Dwork(1).Complexity      = 'Real'; % real
    block.Dwork(1).UsedAsDiscState = 0;
    
function InitializeConditions(block)
    Serial_Config_callback('init');
     
function Start(block)
    %% Read mask parameters into variables
    
    cmd         = '21'; % limit switch lookup table code
    loc         = block.DialogPrm(1).Data;  % pin location
    emerg_state = num2str(block.DialogPrm(2).Data); % dialog box
    val         = '0000';
    ret         = '0';
    
    %% Convert block mask variables into DSX command

    limit_init = toCommand(cmd,loc,emerg_state,val,ret); % make our beloved DSX ping variable
    
    %% Send ping to lookout for limit switch / emergyency stop conditions
    
    Serial_Send_callback('send', limit_init);
    

    
% function Outputs(block)
%     cmd         = '21'; % limit switch lookup table code
%     loc         = num2str(block.DialogPrm(1).Data);  % pin location
%     emerg_state = num2str(block.DialogPrm(2).Data); % dialog box
%     val         = '0000';
%     ret         = '0';  
%     limit_init = toCommand(cmd,loc,emerg_state,val,ret); % make our beloved DSX ping variable
%     %% Read value and check buffer
%     ping = DSX_Read_callback('checkbuffer',limit_init); % use initial ping
%     [pingid, pingloc, pingsign, pingval, pingret] = splitping(ping);
%     %% check
%     if ~isempty(ping) % if there was succesfully a CMD21 ping
%         if pingloc == loc % is it for this block?                
%             if pingsign == '1' 
%                 % not crucial stop, execute commands
%                 if pingret == '1' % write 1  
%                     block.OutputPort(1).Data = 1;
%                 elseif pingret == '0' % write 0
%                     block.OutputPort(1).Data = 0;
%                 end              
%             elseif pingsign == '0'
%                 % crucial stop, output bad and sit back
%                 block.OutputPort(1).Data = 10;
%             end
%         end
%     end
function string = toCommand(cmd,loc,emerg_state,val,ret) % convert our inputs to a command, lovelyly
    string = strcat(cmd,'0',loc,emerg_state,val,ret); % add zero for ping loc as its only '7' not '07' 
% function Terminate()
%endfunction