function CL_RL_hab

%adapted from NMTP_Training1; no sample + delay becomes initate; dimmed
%port lights from 50 to 5

global BpodSystem

S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  %If settings file was an empty struct, populate struct with default settings
	S.GUI.InitReward = 1; %μl; change to 0 to skip center reward
	S.GUI.InitHoldTime = 0;
	S.GUI.ChoiceReward = 5; %μl
	S.GUI.ChoiceHoldTime = 0;
	S.GUI.ITI = 5;
end

%% Define trials

MaxTrials = 100;
NumTrialTypes = 2;
TrialTypes = zeros(1, MaxTrials);
for fill = 1:(MaxTrials/NumTrialTypes)
	block = randperm(NumTrialTypes);
    TrialTypes(fill*NumTrialTypes-1:fill*NumTrialTypes) = block;
end
BpodSystem.Data.TrialTypes = [];

%% Initialize plots
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [50 340 1000 400],'name','Outcome plot','numbertitle','off','MenuBar','none','Resize','off');
BpodSystem.GUIHandles.TrialTypeOutcomePlot = axes('Position', [.075 .3 .89 .6]);
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'init',TrialTypes);
BpodNotebook('init');
BpodParameterGUI('init', S);% Initialize parameter GUI plugin

%% Main trial loop
for currentTrial = 1:MaxTrials

    if S.GUI.InitHoldTime < 1
        S.GUI.InitHoldTime = S.GUI.InitHoldTime + .02;
    end
	if S.GUI.ChoiceHoldTime < 1
        S.GUI.ChoiceHoldTime = S.GUI.ChoiceHoldTime + .02;
	end

	S = BpodParameterGUI('sync', S);

	switch TrialTypes(currentTrial)
        case 1
            ChoiceLight = {'PWM4', 5}; WhichChoiceIn = {'Port4In'}; WhichChoiceOut = {'Port4Out'};
            ChoiceValve = {'Valve4', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 4);
        case 2
            ChoiceLight = {'PWM6', 5}; WhichChoiceIn = {'Port6In'}; WhichChoiceOut = {'Port6Out'};
            ChoiceValve = {'Valve6', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 6);
	end
    
	sma = NewStateMatrix(); % Assemble state matrix
 
	sma = AddState(sma, 'Name', 'ITI', 'Timer', S.GUI.ITI,...
	'StateChangeConditions', {'Tup', 'WaitForInitPoke'},...
        'OutputActions', {});

	%center light on
	sma = AddState(sma,'Name','WaitForInitPoke', 'Timer', 0,...
        'StateChangeConditions', {'Port5In','InitOnHold'},...
        'OutputActions', {'PWM5', 5});

	%start hold timer when center is poked; restart if poke ends early
	sma = AddState(sma,'Name','InitOnHold','Timer', S.GUI.InitHoldTime,...
        'StateChangeConditions', {'Tup','InitOn','Port5Out','WaitForInitPoke'},...
        'OutputActions', {'PWM5', 5});
	
	sma = AddState(sma,'Name','InitOn','Timer', GetValveTimes(S.GUI.InitReward, 2),...
        'StateChangeConditions', {'Tup', 'WaitForChoicePoke'},...
        'OutputActions', {'PWM5', 5, 'Valve5', 1});
	
	sma = AddState(sma, 'Name', 'WaitForChoicePoke', 'Timer', 0,...
        'StateChangeConditions', [WhichChoiceIn, 'ChoiceOnHold'],...
        'OutputActions', ChoiceLight);
	
    sma = AddState(sma, 'Name', 'ChoiceOnHold', 'Timer', ChoiceValveTime,...
        'StateChangeConditions', ['Tup', 'ChoiceOn', WhichChoiceOut, 'WaitForChoicePoke'],...
        'OutputActions', ChoiceLight);
	
	sma = AddState(sma, 'Name', 'ChoiceOn', 'Timer', ChoiceValveTime,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', [ChoiceLight, ChoiceValve]);
	
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