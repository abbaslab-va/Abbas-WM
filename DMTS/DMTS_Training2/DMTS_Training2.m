function DMTS_Training2

%The training protocol for a 4 port spatial working memory task. This
%script introduces punishments, extended delay period and early
%withdrawals, as well as trial repeats.

global BpodSystem


S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.SampleReward = 1;     %μl
    S.GUI.DelayReward = 1;      
    S.GUI.ChoiceReward = 5;     
    S.GUI.ITI = 10;             %seconds
    S.GUI.DelayHoldTime = 0;    
    S.GUI.TimeIncrement = 0.05; %Start this value at .05 and increase up to 1
    S.GUI.EarlyWithdrawalTimeout = 30;
    S.GUI.PunishTime = 20;
    S.GUI.SamplingFreq = 44100; %Sampling rate of wave player module (using max supported frequency)
    S.GUI.SoundDuration = .5; % Duration of sound (s)
    S.GUI.SinePitch = 10000; % Frequency of test tone
end

%% Define trials
ports = [1 3 5 7];
AllPortsIn = {'Port1In', 'Port3In', 'Port5In', 'Port7In'};
AllPortsOut = {'Port1Out', 'Port3Out', 'Port5Out', 'Port7Out'};
numTT = 12;
trialsPerType = 20;
MaxTrials = numTT * 2 * trialsPerType;
TrialTypes = zeros(1, MaxTrials);
for fill = 1:trialsPerType
    block = zeros(1, 2*numTT);
    choiceOn = randperm(numTT);
    choiceOff = choiceOn + numTT;
    block(1:2:(2*numTT - 1)) = choiceOn;
    block(2:2:2*numTT) = choiceOff;
    TrialTypes(fill*2*numTT-(2*numTT-1):fill*2*numTT) = block;
end
BpodSystem.Data.TrialTypes = []; 
%% Initialize teensy audio module and load sound

if (isfield(BpodSystem.ModuleUSB, 'TeensyAudio1'))
    TeensyAudioUSB = BpodSystem.ModuleUSB.TeensyAudio1;
else
    error('Error: To run this protocol, you must first pair the TeensyAudio1 module with its USB port. Click the USB config button on the Bpod console.')
end

T = TeensyAudioPlayer(TeensyAudioUSB);

SF = S.GUI.SamplingFreq;
SampleTone = GenerateSineWave(SF, S.GUI.SinePitch, S.GUI.SoundDuration)*.6; % Sampling freq (hz), Sine frequency (hz), duration (s)
% Program sound server
T.load(1, SampleTone);
analogPortIndex = find(strcmp(BpodSystem.Modules.Name, 'TeensyAudio1'));
if isempty(analogPortIndex)
    error('Error: Bpod TeensyAudio module not found. If you just plugged it in, please restart Bpod.')
end
%% Initialize plots
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [50 340 1000 400],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.TrialTypeOutcomePlot = axes('Position', [.075 .3 .89 .6]);
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'init',TrialTypes);
BpodNotebook('init');
BpodParameterGUI('init', S); % Initialize parameter GUI plugin
%% Main trial loop
for currentTrial = 1:MaxTrials
        
    if S.GUI.DelayHoldTime < 3
        S.GUI.DelayHoldTime = S.GUI.DelayHoldTime + S.GUI.TimeIncrement;
    end
    S = BpodParameterGUI('sync', S);
    currentTT = TrialTypes(currentTrial);
    if currentTT > numTT
        currentTT = currentTT - numTT;
    end
    sampleGroup = ceil(currentTT*4/(numTT));
    switch sampleGroup
        case 1
            SampleLight = {'PWM1', 50}; SampleValve = {'Valve1', 1};
            ChoiceLight = SampleLight;
            WhichSampleIn = {'Port1In'}; WhichSampleOut = {'Port1Out'};
            SampleValveTime = GetValveTimes(S.GUI.SampleReward, 1);
            ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 1);
        case 2
            SampleLight = {'PWM3', 50}; SampleValve = {'Valve3', 1};
            ChoiceLight = SampleLight;
            WhichSampleIn = {'Port3In'}; WhichSampleOut = {'Port3Out'};
            SampleValveTime = GetValveTimes(S.GUI.SampleReward, 3);
            ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 3);
        case 3
            SampleLight = {'PWM5', 50}; SampleValve = {'Valve5', 1};
            ChoiceLight = SampleLight;
            WhichSampleIn = {'Port5In'}; WhichSampleOut = {'Port5Out'};
            SampleValveTime = GetValveTimes(S.GUI.SampleReward, 5);
            ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 5);
        case 4
            SampleLight = {'PWM7', 50}; SampleValve = {'Valve7', 1};
            ChoiceLight = SampleLight;
            WhichSampleIn = {'Port7In'}; WhichSampleOut = {'Port7Out'};
            SampleValveTime = GetValveTimes(S.GUI.SampleReward, 7);
            ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 7);
    end
    if TrialTypes(currentTrial) > numTT
        RepeatTrial = 0;
        ChoiceLight = {};
    else
        RepeatTrial = 1;
    end
    notDelay = ports(sampleGroup);
    activeDelayPorts = ports(ports ~= notDelay);
    DelayPortIdx = mod(TrialTypes(currentTrial), 3) + 1;
    DelayPort = activeDelayPorts(DelayPortIdx);
    DelayLight = {sprintf('PWM%s', string(DelayPort)), 50}; 
    WhichDelayIn = {sprintf('Port%sIn', string(DelayPort))};
    WhichDelayOut = {sprintf('Port%sOut', string(DelayPort))};
    DelayValve = {sprintf('Valve%s', string(DelayPort)), 1}; 
    DelayValveTime = GetValveTimes(S.GUI.DelayReward, DelayPort);
    
    WrongPortsInSample = setdiff(AllPortsIn, WhichSampleIn);
    WrongPortsOutSample = setdiff(AllPortsOut, WhichSampleOut);
    WrongPortsInDelay = setdiff(WrongPortsInSample, WhichDelayIn);
    WrongPortsOutDelay = setdiff(WrongPortsOutSample, WhichDelayOut);
    
    sma = NewStateMatrix(); % Assemble state matrix
        
    sma = AddState(sma, 'Name', 'ITI', 'Timer', S.GUI.ITI,...
        'StateChangeConditions', {'Tup', 'ITI2'},...
        'OutputActions', {});

    sma = AddState(sma, 'Name', 'ITI2', 'Timer', S.GUI.ITI-5,...
        'StateChangeConditions', {'Tup', 'WaitForSamplePoke', 'Port1In', 'ScanPunish',...
        'Port2In', 'ScanPunish', 'Port3In', 'ScanPunish', 'Port4In', 'ScanPunish',...
        'Port5In', 'ScanPunish', 'Port7In', 'ScanPunish'},...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'ScanPunish', 'Timer', 0,...
        'StateChangeConditions', {'Port1Out', 'ITI2', 'Port2Out', 'ITI2', 'Port3Out', 'ITI2',...
        'Port4Out', 'ITI2', 'Port5Out', 'ITI2', 'Port7Out', 'ITI2'},...
        'OutputActions', {'Valve6', 1});
    
    sma = AddState(sma, 'Name', 'WaitForSamplePoke', 'Timer', 0,...
        'StateChangeConditions', [WhichSampleIn, 'SampleOnHold', WrongPortsInSample(1), 'SampleOnHoldPunish',...
        WrongPortsInSample(2), 'SampleOnHoldPunish', WrongPortsInSample(3), 'SampleOnHoldPunish'],...
        'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'SampleOnHold', 'Timer', .05,...
        'StateChangeConditions', ['Tup', 'SampleOn', WhichSampleOut, 'WaitForSamplePoke'],...
        'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'SampleOnHoldPunish', 'Timer', .05,...
        'StateChangeConditions', ['Tup', 'SamplePunish', WrongPortsOutSample(1), 'WaitForSamplePoke',...
        WrongPortsOutSample(2), 'WaitForSamplePoke', WrongPortsOutSample(3), 'WaitForSamplePoke'],...
        'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'SampleOn', 'Timer', SampleValveTime,...
        'StateChangeConditions', {'Tup', 'WaitForDelayPoke'},...
        'OutputActions', [SampleLight, SampleValve, 'TeensyAudio1', 1]);    
    
    %Early withdrawal states give no sample reward to prevent exploitation
    sma = AddState(sma, 'Name', 'WaitForSamplePokeEW', 'Timer', 0,...
        'StateChangeConditions', [WhichSampleIn, 'SampleOnHoldEW', WrongPortsInSample(1), 'SampleOnHoldPunishEW',...
        WrongPortsInSample(2), 'SampleOnHoldPunishEW', WrongPortsInSample(3), 'SampleOnHoldPunishEW'],...
        'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'SampleOnHoldEW', 'Timer', 0.05,...
        'StateChangeConditions', ['Tup', 'SampleOnEW', WhichSampleOut, 'WaitForSamplePokeEW'],...
        'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'SampleOnHoldPunishEW', 'Timer', 0.05,...
        'StateChangeConditions', ['Tup', 'SamplePunishEW', WrongPortsOutSample(1), 'WaitForSamplePokeEW',...
        WrongPortsOutSample(2), 'WaitForSamplePokeEW', WrongPortsOutSample(3), 'WaitForSamplePokeEW'],...
        'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'SampleOnEW', 'Timer', 0,...
        'StateChangeConditions', {'Tup', 'WaitForDelayPoke'},...
        'OutputActions', [SampleLight, 'TeensyAudio1', 1]); 

    sma = AddState(sma, 'Name', 'WaitForDelayPoke', 'Timer', 0,...
        'StateChangeConditions', [WhichDelayIn, 'DelayTimer'],...
        'OutputActions', DelayLight);
    
    sma = AddState(sma, 'Name', 'DelayTimer', 'Timer', 0,...
        'StateChangeConditions', {'Tup', 'DelayOnHold'},...
        'OutputActions', ['GlobalTimerTrig', 1, DelayLight]);
    
    sma = AddState(sma, 'Name', 'DelayOnHold', 'Timer', S.GUI.DelayHoldTime,...
        'StateChangeConditions', ['Tup', 'DelayOn', 'GlobalTimer1_End', 'DelayOn', WhichDelayOut, 'DelayWaitForReentry'],...
        'OutputActions', DelayLight);
    
    sma = AddState(sma, 'Name', 'DelayWaitForReentry', 'Timer', 0.75,...
        'StateChangeConditions', ['Tup', 'EarlyWithdrawal', 'GlobalTimer1_End', 'DelayOn', WhichDelayIn, 'DelayOnHold'],...
        'OutputActions', DelayLight);
    
    sma = AddState(sma, 'Name', 'DelayOn', 'Timer', DelayValveTime,...
        'StateChangeConditions', {'Tup', 'WaitForChoicePoke'},...
        'OutputActions', [DelayLight, DelayValve]);
    
    sma = AddState(sma, 'Name', 'WaitForChoicePoke', 'Timer', 0,...
        'StateChangeConditions', [WhichSampleIn, 'ChoiceOnHold', WrongPortsInDelay(1), 'ChoiceOnHoldPunish',...
        WrongPortsInDelay(2), 'ChoiceOnHoldPunish'],...
        'OutputActions', ChoiceLight);
    
    sma = AddState(sma, 'Name', 'ChoiceOnHold', 'Timer', .05,...
        'StateChangeConditions', ['Tup', 'ChoiceOn', WhichSampleOut, 'WaitForChoicePoke'],...
        'OutputActions', ChoiceLight);
    
    sma = AddState(sma, 'Name', 'ChoiceOnHoldPunish', 'Timer', .1,...
        'StateChangeConditions', ['Tup', 'Punish', WrongPortsOutDelay(1), 'WaitForChoicePoke',...
        WrongPortsOutDelay(2), 'WaitForChoicePoke'],...
        'OutputActions', ChoiceLight);
    
    sma = AddState(sma, 'Name', 'ChoiceOn', 'Timer', ChoiceValveTime,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', [ChoiceLight, SampleValve]);
    
    sma = AddState(sma, 'Name', 'SamplePunish', 'Timer', 3,...
        'StateChangeConditions', {'Tup', 'WaitForSamplePoke'},...
        'OutputActions', {'Valve6', 1});
    
    sma = AddState(sma, 'Name', 'SamplePunishEW', 'Timer', 3,...
        'StateChangeConditions', {'Tup', 'WaitForSamplePokeEW'},...
        'OutputActions', {'Valve6', 1});
    
    if RepeatTrial
    
        sma = AddState(sma, 'Name', 'Punish', 'Timer', S.GUI.PunishTime,...
            'StateChangeConditions', {'Tup', 'ITI2'},...
            'OutputActions', {'Valve6', 1});
    else
        
        sma = AddState(sma, 'Name', 'Punish', 'Timer', S.GUI.PunishTime,...
            'StateChangeConditions', {'Tup', 'exit'},...
            'OutputActions', {'Valve6', 1});
        
    end
    
    sma = AddState(sma, 'Name', 'EarlyWithdrawal', 'Timer', 3,...
        'StateChangeConditions', {'Tup', 'EarlyWithdrawalTimeout'},...
        'OutputActions', {'Valve6', 1});
    
    sma = AddState(sma, 'Name', 'EarlyWithdrawalTimeout', 'Timer', S.GUI.EarlyWithdrawalTimeout,...
        'StateChangeConditions', {'Tup', 'WaitForSamplePokeEW'},...
        'OutputActions', {});
    
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
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes);
        
    
    
 