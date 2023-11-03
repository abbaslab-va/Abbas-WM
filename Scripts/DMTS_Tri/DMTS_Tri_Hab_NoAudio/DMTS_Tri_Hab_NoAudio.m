function DMTS_Tri_Hab


%The habituation script for a 4 port spatial working memory task. This task
%aims to familiarize the subjects with the reward delivery from the 4 ports
%that will be active. Lights will come on with water already present in
%randomized blocks of 12.

global BpodSystem

S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.SampleReward = 1; %μl
    S.GUI.DelayReward = 2; %μl
    S.GUI.ChoiceReward = 5; %μl
    S.GUI.ITI = 10; %seconds   
end

%% Define trials
ports = [1 2 3];
numTT = 6;
trialsPerType = 20;
MaxTrials = numTT * trialsPerType;
TrialTypes = zeros(1, MaxTrials);
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
    currentTT=TrialTypes(currentTrial);
    switch currentTT
        case 1
            SampleLight = {'PWM1', 50}; SampleValve = {'Valve1', 1};
            WhichSampleIn = {'Port1In'}; WhichSampleOut = {'Port1Out'};
            DelayLight = {'PWM2', 50}; DelayValve = {'Valve2', 1};
            WhichDelayIn = {'Port2In'}; WhichDelayOut = {'Port2Out'};
            SampleValveTime = GetValveTimes(S.GUI.SampleReward, 1);
            DelayValveTime = GetValveTimes(S.GUI.DelayReward, 2);
            ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 1);
        case 2
            SampleLight = {'PWM1', 50}; SampleValve = {'Valve1', 1};
            WhichSampleIn = {'Port1In'}; WhichSampleOut = {'Port1Out'};
            DelayLight = {'PWM3', 50}; DelayValve = {'Valve3', 1};
            WhichDelayIn = {'Port3In'}; WhichDelayOut = {'Port3Out'};
            SampleValveTime = GetValveTimes(S.GUI.SampleReward, 1);
            DelayValveTime = GetValveTimes(S.GUI.DelayReward, 3);
            ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 1);
        case 3
            SampleLight = {'PWM2', 50}; SampleValve = {'Valve2', 1};
            WhichSampleIn = {'Port2In'}; WhichSampleOut = {'Port2Out'};
            DelayLight = {'PWM1', 50}; DelayValve = {'Valve1', 1};
            WhichDelayIn = {'Port1In'}; WhichDelayOut = {'Port1Out'};
            SampleValveTime = GetValveTimes(S.GUI.SampleReward, 2);
            DelayValveTime = GetValveTimes(S.GUI.DelayReward, 1);
            ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 2);
        case 4
            SampleLight = {'PWM2', 50}; SampleValve = {'Valve2', 1};
            WhichSampleIn = {'Port2In'}; WhichSampleOut = {'Port2Out'};
            DelayLight = {'PWM3', 50}; DelayValve = {'Valve3', 1};
            WhichDelayIn = {'Port3In'}; WhichDelayOut = {'Port3Out'};
            SampleValveTime = GetValveTimes(S.GUI.SampleReward, 2);
            DelayValveTime = GetValveTimes(S.GUI.DelayReward, 3);
            ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 2);
        case 5
            SampleLight = {'PWM3', 50}; SampleValve = {'Valve3', 1};
            WhichSampleIn = {'Port3In'}; WhichSampleOut = {'Port3Out'};
            DelayLight = {'PWM1', 50}; DelayValve = {'Valve1', 1};
            WhichDelayIn = {'Port1In'}; WhichDelayOut = {'Port1Out'};
            SampleValveTime = GetValveTimes(S.GUI.SampleReward, 3);
            DelayValveTime = GetValveTimes(S.GUI.DelayReward, 1);
            ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 3);
        case 6
            SampleLight = {'PWM3', 50}; SampleValve = {'Valve3', 1};
            WhichSampleIn = {'Port3In'}; WhichSampleOut = {'Port3Out'};
            DelayLight = {'PWM2', 50}; DelayValve = {'Valve2', 1};
            WhichDelayIn = {'Port2In'}; WhichDelayOut = {'Port2Out'};
            SampleValveTime = GetValveTimes(S.GUI.SampleReward, 3);
            DelayValveTime = GetValveTimes(S.GUI.DelayReward, 2);
            ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 3);
    end
    
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
        'OutputActions', [DelayLight, DelayValve]);
    
    sma = AddState(sma, 'Name', 'WaitForDelayPoke', 'Timer', 0,...
        'StateChangeConditions', [WhichDelayIn, 'ChoiceOn'],...
        'OutputActions', DelayLight);
    
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
        
    
    
 