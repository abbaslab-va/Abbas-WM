function RL_Training


%%Template script -- used to build new bpod behavior scripts

global BpodSystem


S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.ITI = 1;
    S.GUI.SmallReward = 1;  %ul
    S.GUI.MainReward = 5; 
    S.GUI.PunishTime= 5 %ul
end

%% Check previous sessions for starting reward size
dataPath = fileparts(BpodSystem.Path.CurrentDataFile);
cd(dataPath)
matDir = dir('*.mat');
numSessions = numel(matDir);
possibleTT = [1 2];
ttCounter=0;
% if numSessions
%     load(matDir(numSessions).name);
%     tt = SessionData.TrialTypes;
%     lastStart = tt(1);
%     startingTT = possibleTT(possibleTT ~= lastStart);
% else
    % Set this value manually during the first session
    startingTT = input('Enter a starting trial type, bitch (1 or 2):\n')
% end

%% Define trials
numTrialTypes = 1;
MaxTrials = 500;
TrialTypes = zeros(1, MaxTrials) + startingTT;
BpodSystem.Data.TrialTypes = []; 
BpodSystem.SoftCodeHandlerFunction = 'RL_SoftChode';

%% Initialize plots
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [50 340 1000 400],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.TrialTypeOutcomePlot = axes('Position', [.075 .3 .89 .6]);
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'init',TrialTypes);
BpodNotebook('init');
BpodParameterGUI('init', S); % Initialize parameter GUI plugin

%% Main trial loop
for currentTrial = 1:MaxTrials
    ttCounter=ttCounter+1;
    S = BpodParameterGUI('sync', S);
 
    sma = NewStateMatrix(); % Assemble state matrix
    switch TrialTypes(currentTrial) % Determine trial-specific state matrix fields
        case 1 %Left
            leftCode = 1;
            rightCode = 2;
        case 2 %Right
            leftCode = 2;
            rightCode = 1;
    end 
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
        'StateChangeConditions', {'Port1In', 'LeftCode', 'Port5In', 'RightReward'},...
        'OutputActions', {'PWM1', 40, 'PWM5', 40});
    
    % mabye put a Tup in here? 

    sma = AddState(sma, 'Name', 'LeftCode', 'Timer', 0,...
        'StateChangeConditions', {'Tup', 'SetRewardSize'},...
        'OutputActions', {'PWM1', 40, 'SoftCode', leftCode});

    sma = AddState(sma, 'Name', 'RightReward', 'Timer', 0,...
        'StateChangeConditions', {'Tup', 'SetRewardSize'},...
        'OutputActions', {'PWM5', 40, 'SoftCode', rightCode});

    sma = AddState(sma, 'Name', 'SetRewardSize', 'Timer', 0,...
        'StateChangeConditions', {'SoftCode1', 'WaitForBackRewarded', 'SoftCode2', 'WaitForBackUnrewarded'},...
        'OutputActions', {});

    sma = AddState(sma, 'Name', 'WaitForBackRewarded', 'Timer', 0,...
        'StateChangeConditions', {'Port7In', 'BackReward'},...
        'OutputActions', {'PWM7', 40});

    sma = AddState(sma, 'Name', 'BackReward', 'Timer', GetValveTimes(S.GUI.MainReward, 7),...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'PWM7', 40, 'Valve7', 1});

    sma = AddState(sma, 'Name', 'WaitForBackUnrewarded', 'Timer', 0,...
        'StateChangeConditions', {'Port7In', 'exit'},...
        'OutputActions', {'PWM7', 40});
    
%     sma = AddState(sma, 'Name', 'Punish', 'Timer',S.GUI.PunishTime,...
%         'StateChangeConditions', {'Tup','exit'},...
%         'OutputActions', {'Valve6', 1});
    
    

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
    if ttCounter > 10
        LocalOutcomes = BpodSystem.Data.SessionPerformance(currentTrial-9:currentTrial);
        if numel(find(LocalOutcomes)) >= 8
            disp('80%!')
            TrialTypes(currentTrial+1:end) = possibleTT(possibleTT ~= TrialTypes(currentTrial));
            ttCounter=0;
        end

    end
end

function UpdateTrialTypeOutcomePlot(TrialTypes, Data)
global BpodSystem
Outcomes = zeros(1,Data.nTrials);
for x = 1:Data.nTrials    
    if ~isnan(Data.RawEvents.Trial{x}.States.BackReward(1))
        Outcomes(x) = 1;
    else
        Outcomes(x) = 0;
    end
end
BpodSystem.Data.SessionPerformance = Outcomes;
SaveBpodSessionData;
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes);
        
    
    
 