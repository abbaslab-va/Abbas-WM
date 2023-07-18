function NMTP_Outer_Hab


%The habituation in a series of training protocols for a 6 port
%stimulus-focused working memory task. This task aims to familiarize the
%subjects with the reward delivery from the 4 ports that will be active. 
%Lights will come on with water already present in randomized blocks of six.

global BpodSystem


S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.SampleReward = 1; %μl
    S.GUI.DelayReward = 1; %μl
    S.GUI.ChoiceReward = 5; %μl
    S.GUI.ITI = 15; % How long the mouse must poke in the center to activate the goal port
end

%% Define trials

MaxTrials = 600;
TrialTypes = zeros(1, 600);
for fill = 1:150
    block = randperm(4);
    TrialTypes(fill*4-3:fill*4) = block;
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

    switch TrialTypes(currentTrial)
        case 1
            SampleLight = {'PWM1', 50}; WhichSampleIn = {'Port1In'};
            SampleValve = {'Valve1', 1}; SampleValveTime = GetValveTimes(S.GUI.SampleReward, 1);
            ChoiceLight = {'PWM3', 50}; WhichChoiceIn = {'Port3In'};
            ChoiceValve = {'Valve3', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 3);
        case 2
            SampleLight = {'PWM1', 50}; WhichSampleIn = {'Port1In'};
            SampleValve = {'Valve1', 1}; SampleValveTime = GetValveTimes(S.GUI.SampleReward, 1);
            ChoiceLight = {'PWM5', 50}; WhichChoiceIn = {'Port5In'};
            ChoiceValve = {'Valve5', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 5);
%         case 3 
%             SampleLight = {'PWM3', 50}; WhichSampleIn = {'Port3In'};
%             SampleValve = {'Valve3', 1}; SampleValveTime = GetValveTimes(S.GUI.SampleReward, 3);
%             ChoiceLight = {'PWM1', 50}; WhichChoiceIn = {'Port1In'};
%             ChoiceValve = {'Valve1', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 1);
%         case 4
%             SampleLight = {'PWM3', 50}; WhichSampleIn = {'Port3In'};
%             SampleValve = {'Valve3', 1}; SampleValveTime = GetValveTimes(S.GUI.SampleReward, 3);
%             ChoiceLight = {'PWM5', 50}; WhichChoiceIn = {'Port5In'};
%             ChoiceValve = {'Valve5', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 5);
        case 3
            SampleLight = {'PWM5', 50}; WhichSampleIn = {'Port5In'};
            SampleValve = {'Valve5', 1}; SampleValveTime = GetValveTimes(S.GUI.SampleReward, 5);
            ChoiceLight = {'PWM1', 50}; WhichChoiceIn = {'Port1In'};
            ChoiceValve = {'Valve1', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 1);
        case 4
            SampleLight = {'PWM5', 50}; WhichSampleIn = {'Port5In'};
            SampleValve = {'Valve5', 1}; SampleValveTime = GetValveTimes(S.GUI.SampleReward, 5);
            ChoiceLight = {'PWM3', 50}; WhichChoiceIn = {'Port3In'};
            ChoiceValve = {'Valve3', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 3);
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
    
    sma = AddState(sma, 'Name', 'DelayOn', 'Timer', GetValveTimes(S.GUI.DelayReward, 7),...
        'StateChangeConditions', {'Port7In', 'ChoiceOn', 'Tup', 'WaitForDelayPoke'},...
        'OutputActions', {'PWM7', 50, 'Valve7', 1});
    
    sma = AddState(sma, 'Name', 'WaitForDelayPoke', 'Timer', 0,...
        'StateChangeConditions', {'Port7In', 'ChoiceOn'},...
        'OutputActions', {'PWM7', 50});
    
    sma = AddState(sma, 'Name', 'ChoiceOn', 'Timer', ChoiceValveTime,...
        'StateChangeConditions', [WhichChoiceIn, 'exit', 'Tup', 'WaitForChoicePoke'],...
        'OutputActions', [ChoiceLight, ChoiceValve]);
    
    sma = AddState(sma, 'Name', 'WaitForChoicePoke', 'Timer', 0,...
        'StateChangeConditions', [WhichChoiceIn, 'exit'],...
        'OutputActions', ChoiceLight);
    
    
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
        
    
    
 