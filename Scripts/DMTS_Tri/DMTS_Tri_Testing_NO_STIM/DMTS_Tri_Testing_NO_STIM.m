function DMTS_Tri_Testing_NO_STIM

%The training protocol for a 3 port spatial working memory task. This
%script introduces punishments, extended delay period and early
%withdrawals, as well as trial repeats.

% Hardware setup
% Pule pal: USB computer to pulsepal
% 2 BNCs, output 1 and 2 to blackrock (analog input 2) and laser (blue,450 for ChR2)
global BpodSystem

if exist('PulsePalSystem', 'var')
    EndPulsePal
end
PulsePal()


S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.SampleReward = 1;     %μl
    S.GUI.DelayReward = 2;      
    S.GUI.ChoiceReward = 6;     
    S.GUI.ITI = 5;             %seconds
    S.GUI.DelayHoldTime = 0;    
    S.GUI.DelayMaxHold = 0;
    S.GUI.EarlyIncrement = 1;
    S.GUI.TimeIncrement = 1; %Start this value at .05 and increase up to 1
    S.GUI.EarlyWithdrawalTimeout = 5;
    S.GUI.PunishTime = 10;
    S.GUI.SamplingFreq = 44100; %Sampling rate of wave player module (using max supported frequency)
    S.GUI.SoundDuration = .25; % Duration of sound (s)
    S.GUI.SinePitch = 14000; % Frequency of test tone
end

ts.trialStart = {'Wire1', 1}; %65529
ts.sampleOn = {'Wire2', 1};%65530
ts.sampleReward = {'Wire1', 1, 'Wire2', 1};%65531
ts.delayStart = {'Wire3', 1};%65532
ts.delayReward = {'Wire1', 1, 'Wire3', 1};%65533
ts.choiceReward = {'Wire2', 1, 'Wire3', 1};%65534
ts.choicePunish = {'Wire1', 1, 'Wire2', 1, 'Wire3', 1};%65535

%% Define trials
OptoTimeOut = 30; % After opto stim has lasted too long, the pre-repeat timeout
MaxStimOn = 30;
ports = [1 2 3];
AllPortsIn = {'Port1In', 'Port2In', 'Port3In'};
AllPortsOut = {'Port1Out', 'Port2Out', 'Port3Out'};
numTT = 6;
trialsPerType = 20;
MaxTrials = numTT * trialsPerType;
TrialTypes = zeros(1, MaxTrials);
StimTypes = TrialTypes;
for fill = 1:trialsPerType % blocks in blocks (smallest blocks randomized here)
    block = randperm(numTT);
    TrialTypes(fill*numTT-(numTT-1):fill*numTT) = block;
end

for fill = 1:4 %(outer blocks randomized here)
    block = [zeros(1,6), ones(1,6), 2*ones(1,6), 3*ones(1,6), 4*ones(1,6)]; % opto stim conditions, 0 means no stim
    shuff_idx = randperm(30);
    block = block(shuff_idx);
    StimTypes(fill*30-(30-1):fill*30) = block;
    TrialTypes_shuff = TrialTypes(fill*30-(30-1):fill*30);
    TrialTypes(fill*30-(30-1):fill*30) = TrialTypes_shuff(shuff_idx);
end
StimTypes = zeros(1, MaxTrials); % This makes all trials No Stim trials
% paramMat = cell(1,2);
% disp('Load first opto param file')
% param_1_filename = uigetfile();
% disp(['Selected: ', param_1_filename]);
% paramMat{1} = load(param_1_filename);
% disp('Load second opto param file')
% param_2_filename = uigetfile();
% disp(['Selected: ', param_2_filename]);
% % paramMat{2} = load(param_2_filename);
% BpodSystem.Data.Laser_params_1 = param_1_filename;
% BpodSystem.Data.Laser_params_2 = param_2_filename;
BpodSystem.Data.TrialTypes = []; 

%% Lookback at previous 3 sessions for trial repeats
dataPath = fileparts(BpodSystem.Path.CurrentDataFile);
cd(dataPath)
matDir = dir('*.mat');
numSessions = numel(matDir);
allTrials = [];
allCorrect = [];


%% Initialize plots
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [50 340 1000 400],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
sgtitle(replace(BpodSystem.GUIData.SubjectName,'_','  '))
BpodSystem.GUIHandles.TrialTypeOutcomePlot = axes('Position', [.075 .3 .89 .6]);
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'init',TrialTypes);
BpodNotebook('init');
BpodParameterGUI('init', S); % Initialize parameter GUI plugin
% BpodSystem.SoftCodeHandlerFunction = 'DMTS_Tri_Opto_SoftCode';

%% Main trial loop
for currentTrial = 1:MaxTrials
% %     repeated = 0;
   
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
    current_stim = StimTypes(currentTrial);
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
    
    switch current_stim
        case 0 % No Stim
            sampleTimerTrig = {};
            sampleStim = {};
            sampleStop = {};
            delayStim = {};
            delayStop = {};
        % case 1 % Sample Stim 1
        %     sampleTimerTrig = {'GlobalTimerTrig', 2};
        %     sampleStim = {'BNC1', 1, 'SoftCode', 1};
        %     sampleStop = {'SoftCode', 2};
        %     delayStim = {};
        %     delayStop = {};
        %     currParams = paramMat{1}.ParameterMatrix;
        %     ProgramPulsePal(currParams);
        % case 2 % Delay Stim 1
        %     sampleTimerTrig = {};
        %     sampleStim = {};
        %     sampleStop = {};
        %     delayStim = {'BNC1', 1, 'SoftCode', 1};
        %     delayStop = {'SoftCode', 2};
        %     currParams = paramMat{1}.ParameterMatrix;
        %     ProgramPulsePal(currParams);
        % case 3 % Sample Stim 2
        %     sampleTimerTrig = {'GlobalTimerTrig', 2};
        %     sampleStim = {'BNC1', 1, 'SoftCode', 1};
        %     sampleStop = {'SoftCode', 2};
        %     delayStim = {};
        %     delayStop = {};
        %     currParams = paramMat{2}.ParameterMatrix;
        %     ProgramPulsePal(currParams);
        % case 4 % Delay Stim 2
        %     sampleTimerTrig = {};
        %     sampleStim = {};
        %     sampleStop = {};
        %     delayStim = {'BNC1', 1, 'SoftCode', 1};
        %     delayStop = {'SoftCode', 2};
        %     currParams = paramMat{2}.ParameterMatrix;
        %     ProgramPulsePal(currParams);
    end
    notSamp = isempty(sampleStim);
    notDel= isempty(delayStim);
    if ~notSamp
        disp(['Trial: ', num2str(currentTrial), ' SAMPLE STIM'])
    end
    if ~notDel
        disp(['Trial: ', num2str(currentTrial), ' DELAY STIM'])
    end
    if (notDel+notSamp)==2
        disp(['Trial: ', num2str(currentTrial), ' NO STIM'])
    end
    WrongPortsInSample = setdiff(AllPortsIn, WhichSampleIn);
    WrongPortsOutSample = setdiff(AllPortsOut, WhichSampleOut);
    WrongPortsInDelay = setdiff(WrongPortsInSample, WhichDelayIn);
    WrongPortsOutDelay = setdiff(WrongPortsOutSample, WhichDelayOut);
    
    sma = NewStateMatrix(); % Assemble state matrix
    sma = SetGlobalTimer(sma, 1, S.GUI.DelayHoldTime);
    sma = SetGlobalTimer(sma, 2, MaxStimOn); % Timer for sample stim to reset trial % Go to a new timeout before restarting trial

    sma = AddState(sma, 'Name', 'ITI', 'Timer', S.GUI.ITI/2,...
        'StateChangeConditions', {'Tup', 'ITI2'},...
        'OutputActions', ts.trialStart);

    sma = AddState(sma, 'Name', 'ITI2', 'Timer', S.GUI.ITI/2,...
        'StateChangeConditions', {'Tup', 'SampleStimTimer', 'Port1In', 'ScanPunish',...
        'Port2In', 'ScanPunish', 'Port3In', 'ScanPunish'},...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'ScanPunish', 'Timer', 0,...
        'StateChangeConditions', {'Port1Out', 'ITI2', 'Port2Out', 'ITI2', 'Port3Out', 'ITI2',},...
        'OutputActions', {'Valve8', 1});

    sma = AddState(sma, 'Name', 'SampleStimTimer', 'Timer', 0,...
        'StateChangeConditions', {'Tup', 'WaitForSamplePoke'},...
        'OutputActions', sampleTimerTrig);
 
     sma = AddState(sma, 'Name', 'SampleStimTimerEW', 'Timer', 0,...
        'StateChangeConditions', {'Tup', 'WaitForSamplePokeEW'},...
        'OutputActions', sampleTimerTrig);   

        % When sample on hold starts, if it's a sample-stim trial, trigger stim
    % start and 30-s stim timeout w/trial abort
    sma = AddState(sma, 'Name', 'WaitForSamplePoke', 'Timer', 0,...
        'StateChangeConditions', [WhichSampleIn, 'SampleOnHold', 'GlobalTimer2_End', 'SampleStimTimeout', WrongPortsInSample(1), 'SampleOnHoldPunish',...
        WrongPortsInSample(2), 'SampleOnHoldPunish'],...
        'OutputActions', [SampleLight, sampleStim, ts.sampleOn]); % add output action for sample_opto(curr_trial), and start global timer for timeout of stim
    

    sma = AddState(sma, 'Name', 'SampleOnHold', 'Timer', .05,...
        'StateChangeConditions', ['Tup', 'SampleOn', 'GlobalTimer2_End', 'SampleStimTimeout', WhichSampleOut, 'WaitForSamplePoke'],...
        'OutputActions', [SampleLight, sampleStim]);
    
    sma = AddState(sma, 'Name', 'SampleOnHoldPunish', 'Timer', .05,...
        'StateChangeConditions', ['Tup', 'SamplePunish', 'GlobalTimer2_End', 'SampleStimTimeout', WrongPortsOutSample(1), 'WaitForSamplePoke',...
        WrongPortsOutSample(2), 'WaitForSamplePoke'],...
        'OutputActions', [SampleLight, sampleStim]);

    % Probably end the stim here     
    sma = AddState(sma, 'Name', 'SampleOn', 'Timer', SampleValveTime,...
        'StateChangeConditions', {'Tup', 'WaitForDelayPoke', 'GlobalTimer2_End', 'SampleStimTimeout'},...
        'OutputActions', [SampleLight, SampleValve, sampleStim, ts.sampleReward]);    
    
    %Early withdrawal states give no sample reward to prevent exploitation
    sma = AddState(sma, 'Name', 'WaitForSamplePokeEW', 'Timer', 0,...
        'StateChangeConditions', [WhichSampleIn, 'SampleOnHoldEW', 'GlobalTimer2_End', 'SampleStimTimeout', WrongPortsInSample(1), 'SampleOnHoldPunishEW',...
        WrongPortsInSample(2), 'SampleOnHoldPunishEW'],...
        'OutputActions', [SampleLight, sampleStim]);
    
    sma = AddState(sma, 'Name', 'SampleOnHoldEW', 'Timer', 0.05,...
        'StateChangeConditions', ['Tup', 'SampleOnEW', 'GlobalTimer2_End', 'SampleStimTimeout', WhichSampleOut, 'WaitForSamplePokeEW'],...
        'OutputActions', [SampleLight, sampleStim]);
    
    sma = AddState(sma, 'Name', 'SampleOnHoldPunishEW', 'Timer', 0.05,...
        'StateChangeConditions', ['Tup', 'SamplePunishEW', 'GlobalTimer2_End', 'SampleStimTimeout', WrongPortsOutSample(1), 'WaitForSamplePokeEW',...
        WrongPortsOutSample(2), 'WaitForSamplePokeEW'],...
        'OutputActions', [SampleLight, sampleStim]);
    
    sma = AddState(sma, 'Name', 'SampleOnEW', 'Timer', 0,...
        'StateChangeConditions', {'Tup', 'WaitForDelayPoke', 'GlobalTimer2_End', 'SampleStimTimeout'},...
        'OutputActions', [SampleLight, sampleStim, ts.sampleReward]); 

    sma = AddState(sma, 'Name', 'WaitForDelayPoke', 'Timer', 0,...
        'StateChangeConditions', [ WhichDelayIn, 'DelayTimer', 'GlobalTimer2_End', 'SampleStimTimeout', WrongPortsInDelay(1), 'BadDelayPoke'],...
        'OutputActions', [DelayLight, sampleStim]);
    
    % Trigger sample off
    sma = AddState(sma, 'Name', 'DelayTimer', 'Timer', 0,...
        'StateChangeConditions', {'Tup', 'DelayOnHold'},...
        'OutputActions', ['GlobalTimerTrig', 1, sampleStop, ts.delayStart]); % trigger
    
    sma = AddState(sma, 'Name', 'DelayOnHold', 'Timer', S.GUI.DelayHoldTime,...
        'StateChangeConditions', ['Tup', 'DelayOn', 'GlobalTimer1_End', 'DelayOn', WhichDelayOut, 'DelayWaitForReentry'],...
        'OutputActions', [DelayLight, delayStim]);
    
    sma = AddState(sma, 'Name', 'DelayWaitForReentry', 'Timer', 1,...
        'StateChangeConditions', ['Tup', 'EarlyWithdrawal', 'GlobalTimer1_End', 'DelayOn', WhichDelayIn, 'DelayOnHold'],...
        'OutputActions', [DelayLight, delayStim]);
    
    sma = AddState(sma, 'Name', 'DelayOn', 'Timer', DelayValveTime,...
        'StateChangeConditions', {'Tup', 'WaitForChoicePoke'},...
        'OutputActions', [DelayLight, DelayValve, delayStop, ts.delayReward]);
    
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
        'OutputActions', [SampleValve, ts.choiceReward]);
    
    sma = AddState(sma, 'Name', 'SamplePunish', 'Timer', 0,...
        'StateChangeConditions', {WrongPortsOutSample(1), 'WaitForSamplePoke',...
        WrongPortsOutSample(2), 'WaitForSamplePoke', 'GlobalTimer2_End', 'SampleStimTimeout'},...
        'OutputActions', ['Valve8', 1, sampleStim]);
    
    sma = AddState(sma, 'Name', 'SamplePunishEW', 'Timer', 0,...
        'StateChangeConditions', {WrongPortsOutSample(1), 'WaitForSamplePokeEW',...
        WrongPortsOutSample(2), 'WaitForSamplePokeEW', 'GlobalTimer2_End', 'SampleStimTimeout'},...
        'OutputActions', ['Valve8', 1, sampleStim]);
    

    sma = AddState(sma, 'Name', 'Punish', 'Timer', S.GUI.PunishTime,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', ['Valve8', 1, ts.choicePunish]);
        
    
    sma = AddState(sma, 'Name', 'EarlyWithdrawal', 'Timer', 3,...
        'StateChangeConditions', {'Tup', 'EarlyWithdrawalTimeout'},...
        'OutputActions', ['Valve8', 1, delayStop]);
    
    
    sma = AddState(sma, 'Name', 'BadDelayPoke', 'Timer', 3,...
        'StateChangeConditions', {'Tup', 'WaitForSamplePokeEW', 'GlobalTimer2_End', 'SampleStimTimeout'},...
        'OutputActions', ['Valve8', 1, sampleStim]);
    
    sma = AddState(sma, 'Name', 'EarlyWithdrawalTimeout', 'Timer', S.GUI.EarlyWithdrawalTimeout,...
        'StateChangeConditions', {'Tup', 'SampleStimTimerEW'},...
        'OutputActions', {});

    
     sma = AddState(sma, 'Name', 'SampleStimTimeout', 'Timer', OptoTimeOut,...
        'StateChangeConditions', {'Tup', 'ITI2'},...
        'OutputActions', sampleStop);
    
    SendStateMatrix(sma);
    
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial);
        BpodSystem.Data.StimTypes(currentTrial) = StimTypes(currentTrial);
        BpodSystem.Data.GUI(currentTrial) = S.GUI;
        try
        UpdateTrialTypeOutcomePlot(TrialTypes, BpodSystem.Data);
        catch
        end
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end
end

if currentTrial == MaxTrials
    disp('Done with all 120 trials, 24 per 5 stim types (stim 1/2) x(sample/delay) + no stim')
end

function UpdateTrialTypeOutcomePlot(TrialTypes, Data)
global BpodSystem
Outcomes = zeros(1,Data.nTrials);
for x = 1:Data.nTrials
    
    if ~isnan(Data.RawEvents.Trial{x}.States.Punish(1))
        Outcomes(x) = 0;
    elseif ~isnan(Data.RawEvents.Trial{x}.States.ChoiceOn(1))
        Outcomes(x) = 1;
    end
end
BpodSystem.Data.SessionPerformance = Outcomes;
SaveBpodSessionData;
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes);
accuracy = 100*(nnz(Outcomes)/numel(Outcomes));
sgtitle(BpodSystem.ProtocolFigures.OutcomePlotFig,[ replace(BpodSystem.GUIData.SubjectName,'_',' '), '  Accuracy: ', num2str(accuracy),'%'])
        
    
    
 
