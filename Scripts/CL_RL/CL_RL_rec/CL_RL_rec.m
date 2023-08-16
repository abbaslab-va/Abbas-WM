function CL_RL_rec

%adapted from NMTP_Training1; no sample + delay becomes initate

global BpodSystem

S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.InitReward = 1; %μl
    S.GUI.HoldTime = 0;
    S.GUI.ChoiceReward = 5; %μl
    S.GUI.ITI = 5;
    S.GUI.RewardedSide = 6; %4 for left, 6 for right
end

%% Define trials

MaxTrials = 100;
TrialTypes = ones(1, MaxTrials);
BpodSystem.Data.TrialTypes = [];

switch S.GUI.RewardedSide
    case 4
        ChoiceLight = {'PWM4', 50}; WhichChoiceIn = {'Port4In'}; WhichChoiceOut = {'Port4Out'};
        ChoiceValve = {'Valve4', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 4);
        WrongChoiceIn = {'Port6In'};
    case 6
        ChoiceLight = {'PWM6', 50}; WhichChoiceIn = {'Port6In'}; WhichChoiceOut = {'Port6Out'};
        ChoiceValve = {'Valve6', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 6);
        WrongChoiceIn = {'Port4In'};
end

BpodSystem.Data.HoldTimes = [];
BpodSystem.Data.Outcomes = [];

%% Initialize plots
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [50 340 1000 400],'name','Outcome plot','numbertitle','off','MenuBar','none','Resize','off');
BpodSystem.GUIHandles.TrialTypeOutcomePlot = axes('Position', [.075 .3 .89 .6]);
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'init',TrialTypes);
BpodNotebook('init');
BpodParameterGUI('init', S);% Initialize parameter GUI plugin

%% Main trial loop
for currentTrial = 1:MaxTrials
    disp(currentTrial)
    if S.GUI.HoldTime < 1
        S.GUI.HoldTime = S.GUI.HoldTime + .1;
    end
    BpodSystem.Data.HoldTimes(currentTrial) = S.GUI.HoldTime; %store to aid analysis
    
    S = BpodParameterGUI('sync', S);
    
    sma = NewStateMatrix(); % Assemble state matrix
    
    %center light on
    sma = AddState(sma, 'Name', 'WaitForInitPoke', 'Timer', 0,...
        'StateChangeConditions', {'Port5In', 'InitOnHold'},...
        'OutputActions', {'PWM5', 5});
    
    %start hold timer when center is poked; restart if poke ends early
    sma = AddState(sma, 'Name', 'InitOnHold', 'Timer', S.GUI.HoldTime,...
        'StateChangeConditions', {'Tup', 'WaitForChoicePoke', 'Port5Out', 'WaitForInitPoke'},...
        'OutputActions', {'PWM5', 5, 'Wire1', 1});
    
    % start hold timer for correct poke, straight to ITI with houselight for incorrect poke
    sma = AddState(sma, 'Name', 'WaitForChoicePoke', 'Timer', 0,...
        'StateChangeConditions', [WhichChoiceIn, 'ChoiceOnHold', WrongChoiceIn, 'ITIPunish'],...
        'OutputActions', {'PWM4', 5, 'PWM6', 5});
    
    % restart timer for early withdrawal
    sma = AddState(sma, 'Name', 'ChoiceOnHold', 'Timer', S.GUI.HoldTime,...
        'StateChangeConditions', ['Tup', 'ChoiceOn', WhichChoiceOut, 'WaitForChoicePoke'],...
        'OutputActions', [ChoiceLight, 'Wire2', 1]);
    
    % reward + light off after successful hold
    sma = AddState(sma, 'Name', 'ChoiceOn', 'Timer', ChoiceValveTime,...
        'StateChangeConditions', {'Tup', 'ITI'},...
        'OutputActions', ChoiceValve);

    sma = AddState(sma, 'Name', 'ITI', 'Timer', S.GUI.ITI,...
        'StateChangeConditions', {'Tup', 'WaitForInitPoke'},...
        'OutputActions', {});

    sma = AddState(sma, 'Name', 'ITIPunish', 'Timer', S.GUI.ITI,...
        'StateChangeConditions', {'Tup', 'WaitForInitPoke'},...
        'OutputActions', {'Valve8', 1, 'Wire3', 1}); %not sure if correct (valve8 is house light for triangle Bpod)
    
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
