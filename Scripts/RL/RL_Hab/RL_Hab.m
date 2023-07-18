function RL_Hab


%%Template script -- used to build new bpod behavior scripts

global BpodSystem


S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.ITI = 5;
    S.GUI.SmallReward = 1;  %ul
    S.GUI.MainReward = 8;   %ul
end

%% Define trials
numTrialTypes = 1;
MaxTrials = 500;
TrialTypes = ones(1, MaxTrials);
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
 
    sma = NewStateMatrix(); % Assemble state matrix
    
    %Waiting for first choice, sample start (needs valve calibration)
    
    sma = AddState(sma, 'Name', 'ITI', 'Timer', S.GUI.ITI,...
        'StateChangeConditions', {'Tup', 'WaitForCenterPoke'},...
        'OutputActions', {});

    sma = AddState(sma, 'Name', 'WaitForCenterPoke', 'Timer', 0,...
        'StateChangeConditions', {'Port3In', 'CenterReward'},...
        'OutputActions', {'PWM3', 40});

    sma = AddState(sma, 'Name', 'CenterReward', 'Timer', GetValveTimes(S.GUI.SmallReward, 3),...
        'StateChangeConditions', {'Tup', 'WaitForOuterPoke'},...
        'OutputActions', {'PWM3', 40, 'Valve3', 1});        
    
    sma = AddState(sma, 'Name', 'WaitForOuterPoke', 'Timer', 0,... 
        'StateChangeConditions', {'Port1In', 'LeftReward', 'Port5In', 'RightReward'},...
        'OutputActions', {'PWM1', 40, 'PWM5', 40});

    sma = AddState(sma, 'Name', 'LeftReward', 'Timer', GetValveTimes(S.GUI.SmallReward, 1),...
        'StateChangeConditions', {'Tup', 'WaitForBackPoke'},...
        'OutputActions', {'PWM1', 40, 'Valve1', 1});

    sma = AddState(sma, 'Name', 'RightReward', 'Timer', GetValveTimes(S.GUI.SmallReward, 5),...
        'StateChangeConditions', {'Tup', 'WaitForBackPoke'},...
        'OutputActions', {'PWM5', 40, 'Valve5', 1});

    sma = AddState(sma, 'Name', 'WaitForBackPoke', 'Timer', 0,...
        'StateChangeConditions', {'Port7In', 'BackReward'},...
        'OutputActions', {'PWM7', 40});

    sma = AddState(sma, 'Name', 'BackReward', 'Timer', GetValveTimes(S.GUI.MainReward, 7),...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'PWM7', 40, 'Valve7', 1});


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
    if ~isnan(Data.RawEvents.Trial{x}.States.ITI(1))
        Outcomes(x) = 1;
    end
end
BpodSystem.Data.SessionPerformance = Outcomes;
SaveBpodSessionData;
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes);
        
    
    
 