function DMTS_Hab


%The habituation script for a 4 port spatial working memory task. This task
%aims to familiarize the subjects with the reward delivery from the 4 ports
%that will be active. Lights will come on with water already present in
%randomized blocks of 12.

global BpodSystem

S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.SampleReward = 1; %μl
    S.GUI.DelayReward = 1; %μl
    S.GUI.ChoiceReward = 5; %μl
    S.GUI.ITI = 10; %seconds
end

%% Define trials
ports = [1 3 5 7];
numTT = 12;
trialsPerType = 20;
MaxTrials = numTT * trialsPerType;
TrialTypes = zeros(1, maxTrials);
for fill = 1:trialsPerType
    block = randperm(numTT);
    TrialTypes(fill*numTT-(numTT-1):fill*numTT) = block;
end
BpodSystem.Data.TrialTypes = []; 

%% Initialize plots
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [50 340 1000 400],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.TrialTypeOutcomePlot = axes('Position', [.075 .3 .89 .6]);
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'init',TrialTypes);
BpodNotebook('init');
BpodParameterGUI('init', S); % Initialize parameter GUI plugin
%% Main trial loop
for currentTrial = 1:MaxTrials
    
    S = BpodParameterGUI('sync', S);
    sampleGroup = ceil(trialTypes(currentTrial)*3/numTT);
    switch sampleGroup
        case 1
            SampleLight = {'PWM1', 50}; WhichSampleIn = {'Port1In'}; SampleValve = {'Valve1', 1}; 
            SampleValveTime = GetValveTimes(S.GUI.SampleReward, 1);
            ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 1);
        case 2
            SampleLight = {'PWM3', 50}; WhichSampleIn = {'Port3In'}; SampleValve = {'Valve3', 1}; 
            SampleValveTime = GetValveTimes(S.GUI.SampleReward, 3);
            ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 3);
        case 3
            SampleLight = {'PWM5', 50}; WhichSampleIn = {'Port5In'}; SampleValve = {'Valve5', 1}; 
            SampleValveTime = GetValveTimes(S.GUI.SampleReward, 5);
            ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 5);
        case 4
            SampleLight = {'PWM7', 50}; WhichSampleIn = {'Port7In'}; SampleValve = {'Valve7', 1}; 
            SampleValveTime = GetValveTimes(S.GUI.SampleReward, 7);
            ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 7);
    end
    
    notDelay = ports(sampleGroup);
    activeDelayPorts = ports(ports ~= notDelay);
    DelayPortIdx = mod(TrialTypes(currentTrial), 3) + 1;
    DelayPort = activeDelayPorts(DelayPortIdx);
    DelayLight = {sprintf('PWM%s', string(DelayPort)), 50}; 
    WhichDelayIn = {sprintf('Port%sIn', string(DelayPort))};
    DelayValve = {sprintf('Valve%s', string(DelayPort)), 1}; 
    DelayValveTime = GetValveTimes(S.GUI.DelayReward, DelayPort);
    
    
    sma = NewStateMatrix(); % Assemble state matrix
    
    %Waiting for first choice, sample start (needs valve calibration)
    
    sma = AddState(sma, 'Name', 'ITI', 'Timer', S.GUI.ITI,...
        'StateChangeConditions', {'Tup', 'SampleOn'},...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'SampleOn', 'Timer', SampleValveTime,...
        'StateChangeConditions', [WhichSampleIn, 'DelayOn', 'Tup', 'WaitForSamplePoke'],...
        'OutputActions', [SampleLight, SampleValve]);
    
    sma = AddState(sma, 'Name', 'WaitForSamplePoke', 'Timer', 0,...
        'StateChangeConditions', [WhichSampleIn, 'DelayOn'],...
        'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'DelayOn', 'Timer', DelayValveTime,...
        'StateChangeConditions', [WhichDelayIn, 'ChoiceOn', 'Tup', 'WaitForDelayPoke'],...
        'OutputActions', [DelayLight, 50, DelayValve, 1]);
    
    sma = AddState(sma, 'Name', 'WaitForDelayPoke', 'Timer', 0,...
        'StateChangeConditions', [WhichDelayIn, 'ChoiceOn'],...
        'OutputActions', [DelayLight, 50]);
    
    sma = AddState(sma, 'Name', 'ChoiceOn', 'Timer', ChoiceValveTime,...
        'StateChangeConditions', [WhichSampleIn, 'exit', 'Tup', 'WaitForChoicePoke'],...
        'OutputActions', [SampleLight, SampleValve]);
    
    sma = AddState(sma, 'Name', 'WaitForChoicePoke', 'Timer', 0,...
        'StateChangeConditions', [WhichSampleIn, 'exit'],...
        'OutputActions', SampleLight);
    
    
    SendStateMatrix(sma);
    
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial);
        UpdateTrialTypeOutcomePlot(TrialTypes, BpodSystem.Data);
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end
end

function UpdateTrialTypeOutcomePlot(TrialTypes, Data)
global BpodSystem
Outcomes = zeros(1,Data.nTrials);
for x = 1:Data.nTrials
    Outcomes(x) = 1;
end
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes);
        
    
    
 