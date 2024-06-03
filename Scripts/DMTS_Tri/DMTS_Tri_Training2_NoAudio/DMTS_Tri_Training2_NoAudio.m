function DMTS_Tri_Training2_NoAudio

%The training protocol for a 3 port spatial working memory task. This
%script introduces punishments, extended delay period and early
%withdrawals, as well as trial repeats.

global BpodSystem


S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.SampleReward = 1;     %μl
    S.GUI.DelayReward = 2;      
    S.GUI.ChoiceReward = 6;     
    S.GUI.ITI = 5;             %seconds
    S.GUI.DelayHoldTime = 0;    
    S.GUI.DelayMaxHold = 0;
    S.GUI.EarlyIncrement = 0.45;
    S.GUI.TimeIncrement = 0.45; %Start this value at .05 and increase up to 1
    S.GUI.EarlyWithdrawalTimeout = 5;
    S.GUI.PunishTime = 10;
end

%% Define trials
ports = [1 2 3];
AllPortsIn = {'Port1In', 'Port2In', 'Port3In'};
AllPortsOut = {'Port1Out', 'Port2Out', 'Port3Out'};
numTT = 6;
trialsPerType = 40;
MaxTrials = numTT * trialsPerType;
TrialTypes = zeros(1, MaxTrials);
for fill = 1:trialsPerType
    block = randperm(numTT);
    TrialTypes(fill*numTT-(numTT-1):fill*numTT) = block;
end

RepeatTrial = 0;

BpodSystem.Data.TrialTypes = []; 

%% Lookback at previous 3 sessions for trial repeats
dataPath = fileparts(BpodSystem.Path.CurrentDataFile);
dataFolder = BpodSystem.Path.DataFolder;
networkDataPath = ['\\User-pc\f\All_rigs_bpodRecording\bpodRecording', dataPath(numel(dataFolder)+1:end)];
cd(networkDataPath)
matDir = dir('*.mat');
numSessions = numel(matDir);
allTrials = [];
allCorrect = [];
if numSessions < 2
    doRepeat = zeros(1, numTT);
else
%     for sess = numSessions-2:numSessions
    try
        for sess = numSessions-1:numSessions
            load(matDir(sess).name);
            [nTrials, nCorrect] = bpod_performance(SessionData, 1);
            if numel(nTrials) == numTT
                allTrials(end+1, :) = nTrials;
                allCorrect(end+1, :) = nCorrect;
            end
%             ewData = adaptive_early_withdrawal(SessionData);
        end
        allTrials = sum(allTrials, 1);
        allCorrect = sum(allCorrect, 1);
        doRepeat = allCorrect./allTrials < 0.5;
    catch
        doRepeat = zeros(1, numTT);
    end
end
if isempty(doRepeat)
    doRepeat = zeros(1, numTT);
end


%% Initialize plots
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [50 340 1000 400],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
sgtitle(replace(BpodSystem.GUIData.SubjectName,'_','  '))
BpodSystem.GUIHandles.TrialTypeOutcomePlot = axes('Position', [.075 .3 .89 .6]);
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'init',TrialTypes);
BpodNotebook('init');
BpodParameterGUI('init', S); % Initialize parameter GUI plugin
%% Main trial loop
for currentTrial = 1:MaxTrials
% %     repeated = 0;
    RepeatTrial = doRepeat(TrialTypes(currentTrial));
    if S.GUI.DelayMaxHold < 7 && S.GUI.DelayMaxHold >= 3
        S.GUI.DelayMaxHold = S.GUI.DelayMaxHold + S.GUI.TimeIncrement;
    elseif S.GUI.DelayMaxHold < 3
        S.GUI.DelayMaxHold = S.GUI.DelayMaxHold + S.GUI.EarlyIncrement;
    end
    if S.GUI.DelayMaxHold > 3
        S.GUI.DelayHoldTime = randsample(3:.1:S.GUI.DelayMaxHold, 1);
    else
        S.GUI.DelayHoldTime = S.GUI.DelayMaxHold;
    end
    S = BpodParameterGUI('sync', S);
    currentTT = TrialTypes(currentTrial);
%     if currentTT > numTT
%         currentTT = currentTT - numTT;
%     end
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
    
    WrongPortsInSample = setdiff(AllPortsIn, WhichSampleIn);
    WrongPortsOutSample = setdiff(AllPortsOut, WhichSampleOut);
    WrongPortsInDelay = setdiff(WrongPortsInSample, WhichDelayIn);
    WrongPortsOutDelay = setdiff(WrongPortsOutSample, WhichDelayOut);
    
    sma = NewStateMatrix(); % Assemble state matrix
    sma = SetGlobalTimer(sma, 1, S.GUI.DelayHoldTime);

    sma = AddState(sma, 'Name', 'ITI', 'Timer', S.GUI.ITI/2,...
        'StateChangeConditions', {'Tup', 'ITI2'},...
        'OutputActions', {});

    sma = AddState(sma, 'Name', 'ITI2', 'Timer', S.GUI.ITI/2,...
        'StateChangeConditions', {'Tup', 'WaitForSamplePoke', 'Port1In', 'ScanPunish',...
        'Port2In', 'ScanPunish', 'Port3In', 'ScanPunish'},...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'ScanPunish', 'Timer', 0,...
        'StateChangeConditions', {'Port1Out', 'ITI2', 'Port2Out', 'ITI2', 'Port3Out', 'ITI2',},...
        'OutputActions', {'Valve8', 1});
    
    sma = AddState(sma, 'Name', 'WaitForSamplePoke', 'Timer', 0,...
        'StateChangeConditions', [WhichSampleIn, 'SampleOnHold', WrongPortsInSample(1), 'SampleOnHoldPunish',...
        WrongPortsInSample(2), 'SampleOnHoldPunish'],...
        'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'SampleOnHold', 'Timer', .05,...
        'StateChangeConditions', ['Tup', 'SampleOn', WhichSampleOut, 'WaitForSamplePoke'],...
        'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'SampleOnHoldPunish', 'Timer', .05,...
        'StateChangeConditions', ['Tup', 'SamplePunish', WrongPortsOutSample(1), 'WaitForSamplePoke',...
        WrongPortsOutSample(2), 'WaitForSamplePoke'],...
        'OutputActions', SampleLight);
%     
    sma = AddState(sma, 'Name', 'SampleOn', 'Timer', SampleValveTime,...
        'StateChangeConditions', {'Tup', 'WaitForDelayPoke'},...
        'OutputActions', [SampleLight, SampleValve]);
   
    %Early withdrawal states give no sample reward to prevent exploitation
    sma = AddState(sma, 'Name', 'WaitForSamplePokeEW', 'Timer', 0,...
        'StateChangeConditions', [WhichSampleIn, 'SampleOnHoldEW', WrongPortsInSample(1), 'SampleOnHoldPunishEW',...
        WrongPortsInSample(2), 'SampleOnHoldPunishEW'],...
        'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'SampleOnHoldEW', 'Timer', 0.05,...
        'StateChangeConditions', ['Tup', 'SampleOnEW', WhichSampleOut, 'WaitForSamplePokeEW'],...
        'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'SampleOnHoldPunishEW', 'Timer', 0.05,...
        'StateChangeConditions', ['Tup', 'SamplePunishEW', WrongPortsOutSample(1), 'WaitForSamplePokeEW',...
        WrongPortsOutSample(2), 'WaitForSamplePokeEW'],...
        'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'SampleOnEW', 'Timer', 0,...
        'StateChangeConditions', {'Tup', 'WaitForDelayPoke'},...
        'OutputActions', SampleLight); 

    sma = AddState(sma, 'Name', 'WaitForDelayPoke', 'Timer', 0,...
        'StateChangeConditions', [WhichDelayIn, 'DelayTimer', WrongPortsInDelay(1), 'BadDelayPoke'],...
        'OutputActions', DelayLight);
    
    sma = AddState(sma, 'Name', 'DelayTimer', 'Timer', 0,...
        'StateChangeConditions', {'Tup', 'DelayOnHold'},...
        'OutputActions', ['GlobalTimerTrig', 1, DelayLight]);
    
    sma = AddState(sma, 'Name', 'DelayOnHold', 'Timer', S.GUI.DelayHoldTime,...
        'StateChangeConditions', ['Tup', 'DelayOn', 'GlobalTimer1_End', 'DelayOn', WhichDelayOut, 'DelayWaitForReentry'],...
        'OutputActions', DelayLight);
    
    sma = AddState(sma, 'Name', 'DelayWaitForReentry', 'Timer', 1,...
        'StateChangeConditions', ['Tup', 'EarlyWithdrawal', 'GlobalTimer1_End', 'DelayOn', WhichDelayIn, 'DelayOnHold'],...
        'OutputActions', DelayLight);
    
    sma = AddState(sma, 'Name', 'DelayOn', 'Timer', DelayValveTime,...
        'StateChangeConditions', {'Tup', 'WaitForChoicePoke'},...
        'OutputActions', [DelayLight, DelayValve]);
    
    sma = AddState(sma, 'Name', 'WaitForChoicePoke', 'Timer', 0,...
        'StateChangeConditions', [WhichSampleIn, 'ChoiceOnHold', WrongPortsInDelay(1), 'ChoiceOnHoldPunish'],...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'ChoiceOnHold', 'Timer', .05,...
        'StateChangeConditions', ['Tup', 'ChoiceOn', WhichSampleOut, 'WaitForChoicePoke'],...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'ChoiceOnHoldPunish', 'Timer', .05,...
        'StateChangeConditions', ['Tup', 'Punish', WrongPortsOutDelay(1), 'WaitForChoicePoke'],...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'ChoiceOn', 'Timer', ChoiceValveTime,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', [SampleValve]);
    
    sma = AddState(sma, 'Name', 'SamplePunish', 'Timer', 0,...
        'StateChangeConditions', {WrongPortsOutSample(1), 'WaitForSamplePoke',...
        WrongPortsOutSample(2), 'WaitForSamplePoke'},...
        'OutputActions', {'Valve8', 1});
    
    sma = AddState(sma, 'Name', 'SamplePunishEW', 'Timer', 0,...
        'StateChangeConditions', {WrongPortsOutSample(1), 'WaitForSamplePokeEW',...
        WrongPortsOutSample(2), 'WaitForSamplePokeEW'},...
        'OutputActions', {'Valve8', 1});
    
    if RepeatTrial
        sma = AddState(sma, 'Name', 'Punish', 'Timer', S.GUI.PunishTime,...
            'StateChangeConditions', {'Tup', 'ITI2'},...
            'OutputActions', {'Valve8', 1});
    else
        
        sma = AddState(sma, 'Name', 'Punish', 'Timer', S.GUI.PunishTime,...
            'StateChangeConditions', {'Tup', 'exit'},...
            'OutputActions', {'Valve8', 1});
        
    end
    
    sma = AddState(sma, 'Name', 'EarlyWithdrawal', 'Timer', 3,...
        'StateChangeConditions', {'Tup', 'EarlyWithdrawalTimeout'},...
        'OutputActions', {'Valve8', 1});
    
    
    sma = AddState(sma, 'Name', 'BadDelayPoke', 'Timer', 3,...
        'StateChangeConditions', {'Tup', 'WaitForSamplePokeEW'},...
        'OutputActions', {'Valve8', 1});
    
    sma = AddState(sma, 'Name', 'EarlyWithdrawalTimeout', 'Timer', S.GUI.EarlyWithdrawalTimeout,...
        'StateChangeConditions', {'Tup', 'WaitForSamplePokeEW'},...
        'OutputActions', {});
    
    SendStateMatrix(sma);
    
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial);
        BpodSystem.Data.GUI(currentTrial) = S.GUI;
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
    
    if ~isnan(Data.RawEvents.Trial{x}.States.Punish(1)) && ~isnan(Data.RawEvents.Trial{x}.States.ChoiceOn(1))
        Outcomes(x) = 2;
    elseif ~isnan(Data.RawEvents.Trial{x}.States.Punish(1))
        Outcomes(x) = 0;
    elseif ~isnan(Data.RawEvents.Trial{x}.States.ChoiceOn(1))
        Outcomes(x) = 1;
    end
end
BpodSystem.Data.SessionPerformance = Outcomes;
SaveBpodSessionData;
accuracy = 100*(nnz(Outcomes)/numel(Outcomes));
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes);
sgtitle(BpodSystem.ProtocolFigures.OutcomePlotFig,[ replace(BpodSystem.GUIData.SubjectName,'_',' '), '  Accuracy: ', num2str(accuracy),'%'])


        
    
    
 