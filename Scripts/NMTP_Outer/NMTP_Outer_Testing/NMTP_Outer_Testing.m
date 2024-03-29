function NMTP_Outer_Testing


%The first training in a series of protocols for a 6 port
%stimulus-focused working memory task. Training 1 will familiarize the
%subject with poking to dispense reward as well as holding for reward.

global BpodSystem
% 
% enableRepeats = questdlg('Enable Repeats?', 'Repeat option', 'Yes', 'No', 'No');
% switch enableRepeats
%     case 'Yes'   
%         repeatsEnabled = 1;
%     case 'No'
%         repeatsEnabled = 0;
% end
repeatsEnabled = 1;
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.SampleReward = 0; %μl
    S.GUI.SampleHoldTime = .2;
    S.GUI.DelayReward = 0; %μl
%     S.GUI.DelayHoldTime = 2.3;    
    S.GUI.DelayHoldTime = 0;
    S.GUI.ChoiceReward = 7; %μl
    S.GUI.ChoiceHoldTime = 0.2;
    S.GUI.PunishTime = 10;
    S.GUI.ITI = 5; 
    S.GUI.EarlyWithdrawalTimeout = 1;
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

TimeTaken = zeros(1, 1000);
RepeatTrial = 1;

%% Main trial loop
for currentTrial = 1:MaxTrials
    if S.GUI.DelayHoldTime < 5
        S.GUI.DelayHoldTime = S.GUI.DelayHoldTime + .5;
    elseif S.GUI.DelayHoldTime > 5
        S.GUI.DelayHoldTime = 5;
    end
    
    if S.GUI.ChoiceHoldTime < 0.2
        S.GUI.ChoiceHoldTime = S.GUI.ChoiceHoldTime + .05;
        S.GUI.SampleHoldTime = S.GUI.ChoiceHoldTime;
    end
    S = BpodParameterGUI('sync', S);

        AllPortsIn = {'Port1In', 'Port2In', 'Port3In', 'Port4In', 'Port5In'};
        AllPortsOut = {'Port1Out', 'Port2Out', 'Port3Out', 'Port4Out', 'Port5Out'};
    switch TrialTypes(currentTrial)
        case 1
            SampleLight = {'PWM1', 50}; WhichSampleIn = {'Port1In'}; WhichSampleOut = {'Port1Out'};
            SampleValve = {'Valve1', 1}; SampleValveTime = GetValveTimes(S.GUI.SampleReward, 1);
            ChoiceLight = {'PWM3', 50}; WhichChoiceIn = {'Port3In'}; WhichChoiceOut = {'Port3Out'};
            ChoiceValve = {'Valve3', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 3);
        case 2
            SampleLight = {'PWM1', 50}; WhichSampleIn = {'Port1In'}; WhichSampleOut = {'Port1Out'};
            SampleValve = {'Valve1', 1}; SampleValveTime = GetValveTimes(S.GUI.SampleReward, 1);
            ChoiceLight = {'PWM5', 50}; WhichChoiceIn = {'Port5In'}; WhichChoiceOut = {'Port5Out'};
            ChoiceValve = {'Valve5', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 5);
%         case 3 
%             SampleLight = {'PWM3', 50}; WhichSampleIn = {'Port3In'}; WhichSampleOut = {'Port3Out'};
%             SampleValve = {'Valve3', 1}; SampleValveTime = GetValveTimes(S.GUI.SampleReward, 3);
%             ChoiceLight = {'PWM1', 50}; WhichChoiceIn = {'Port1In'}; WhichChoiceOut = {'Port1Out'};
%             ChoiceValve = {'Valve1', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 1);
%         case 4
%             SampleLight = {'PWM3', 50}; WhichSampleIn = {'Port3In'}; WhichSampleOut = {'Port3Out'};
%             SampleValve = {'Valve3', 1}; SampleValveTime = GetValveTimes(S.GUI.SampleReward, 3);
%             ChoiceLight = {'PWM5', 50}; WhichChoiceIn = {'Port5In'}; WhichChoiceOut = {'Port5Out'};
%             ChoiceValve = {'Valve5', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 5);
        case 3
            SampleLight = {'PWM5', 50}; WhichSampleIn = {'Port5In'}; WhichSampleOut = {'Port5Out'};
            SampleValve = {'Valve5', 1}; SampleValveTime = GetValveTimes(S.GUI.SampleReward, 5);
            ChoiceLight = {'PWM1', 50}; WhichChoiceIn = {'Port1In'}; WhichChoiceOut = {'Port1Out'};
            ChoiceValve = {'Valve1', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 1);
        case 4
            SampleLight = {'PWM5', 50}; WhichSampleIn = {'Port5In'}; WhichSampleOut = {'Port5Out'};
            SampleValve = {'Valve5', 1}; SampleValveTime = GetValveTimes(S.GUI.SampleReward, 5);
            ChoiceLight = {'PWM3', 50}; WhichChoiceIn = {'Port3In'}; WhichChoiceOut = {'Port3Out'};
            ChoiceValve = {'Valve3', 1}; ChoiceValveTime = GetValveTimes(S.GUI.ChoiceReward, 3);
    end
    WrongPortsInSample = setdiff(AllPortsIn, WhichSampleIn);
    WrongPortsOutSample = setdiff(AllPortsOut, WhichSampleOut);
    WrongPortsInChoice = setdiff(AllPortsIn, WhichChoiceIn);
    WrongPortsOutChoice = setdiff(AllPortsOut, WhichChoiceOut);
    
    sma = NewStateMatrix(); % Assemble state matrix
    sma = SetGlobalTimer(sma, 1, S.GUI.DelayHoldTime);
    
    %Waiting for first choice, sample start (needs valve calibration)
    
       sma = AddState(sma, 'Name', 'ITI', 'Timer', 3,...
        'StateChangeConditions', {'Tup', 'ITI2'},...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'ITI2', 'Timer', S.GUI.ITI-3,...
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
        WrongPortsInSample(2), 'SampleOnHoldPunish', WrongPortsInSample(3), 'SampleOnHoldPunish',...
        WrongPortsInSample(4), 'SampleOnHoldPunish'], 'OutputActions', [SampleLight, 'Wire1', 1]);
    
 
    sma = AddState(sma, 'Name', 'SampleOnHold', 'Timer', S.GUI.SampleHoldTime,...
        'StateChangeConditions', ['Tup', 'SampleOn', WhichSampleOut, 'WaitForSamplePoke'],...
        'OutputActions', [SampleLight]);
    
    sma = AddState(sma, 'Name', 'SampleOnHoldPunish', 'Timer', S.GUI.SampleHoldTime,...
        'StateChangeConditions', ['Tup', 'SamplePunish', WrongPortsOutSample(1), 'WaitForSamplePoke',...
        WrongPortsOutSample(2), 'WaitForSamplePoke', WrongPortsOutSample(3), 'WaitForSamplePoke',... 
        WrongPortsOutSample(4), 'WaitForSamplePoke'], 'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'SampleOn', 'Timer', SampleValveTime,...
        'StateChangeConditions', {'Tup', 'WaitForDelayPoke'},...
        'OutputActions', [SampleLight, SampleValve, 'Wire2', 1]);
    
    %added to stop mice from shortcutting reward through early withdrawals
    sma = AddState(sma, 'Name', 'WaitForSamplePokeEW', 'Timer', 0,...
        'StateChangeConditions', [WhichSampleIn, 'SampleOnHoldEW', WrongPortsInSample(1), 'SampleOnHoldPunishEW',...
        WrongPortsInSample(2), 'SampleOnHoldPunishEW', WrongPortsInSample(3), 'SampleOnHoldPunishEW',...
        WrongPortsInSample(4), 'SampleOnHoldPunishEW'], 'OutputActions', [SampleLight, 'Wire1', 1]);
    
 
    sma = AddState(sma, 'Name', 'SampleOnHoldEW', 'Timer', S.GUI.SampleHoldTime,...
        'StateChangeConditions', ['Tup', 'SampleOnEW', WhichSampleOut, 'WaitForSamplePokeEW'],...
        'OutputActions', [SampleLight]);
    
    sma = AddState(sma, 'Name', 'SampleOnHoldPunishEW', 'Timer', S.GUI.SampleHoldTime,...
        'StateChangeConditions', ['Tup', 'SamplePunishEW', WrongPortsOutSample(1), 'WaitForSamplePokeEW',...
        WrongPortsOutSample(2), 'WaitForSamplePokeEW', WrongPortsOutSample(3), 'WaitForSamplePokeEW',... 
        WrongPortsOutSample(4), 'WaitForSamplePokeEW'], 'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'SampleOnEW', 'Timer', 0,...
        'StateChangeConditions', {'Tup', 'WaitForDelayPoke'},...
        'OutputActions', [SampleLight, 'Wire2', 1]);
       
    %Sample poke comes .2 seconds before Wire 2
%     sma = AddState(sma, 'Name', 'SampleOn', 'Timer', 0,...
%         'StateChangeConditions', {'Tup', 'WaitForDelayPoke'},...
%         'OutputActions', {'Wire2', 1});
    
    sma = AddState(sma, 'Name', 'WaitForDelayPoke', 'Timer', 0,...
        'StateChangeConditions', {'Port7In', 'DelayTimer'},...
        'OutputActions', {'PWM7', 50});
    
    sma = AddState(sma, 'Name', 'DelayTimer', 'Timer', 0,...
        'StateChangeConditions', {'Tup', 'DelayOnHold'},...
        'OutputActions', {'GlobalTimerTrig', 1, 'PWM7', 50});
    
    sma = AddState(sma, 'Name', 'DelayOnHold', 'Timer', S.GUI.DelayHoldTime,...
        'StateChangeConditions', {'Tup', 'DelayOn', 'GlobalTimer1_End', 'DelayOn', 'Port7Out', 'DelayWaitForReentry'},...
        'OutputActions', {'PWM7', 50});
    
    sma = AddState(sma, 'Name', 'DelayWaitForReentry', 'Timer', 0.5,...
        'StateChangeConditions', {'Tup', 'EarlyWithdrawal', 'GlobalTimer1_End', 'DelayOn', 'Port7In', 'DelayOnHold'},...
        'OutputActions', {'PWM7', 50});
    
    %Go back 5 seconds from trial 5 onwards to find delay poke
    sma = AddState(sma, 'Name', 'DelayOn', 'Timer', GetValveTimes(S.GUI.DelayReward, 7),...
        'StateChangeConditions', {'Tup', 'WaitForChoicePoke'},...
        'OutputActions', {'PWM7', 50, 'Valve7', 1, 'Wire1', 1, 'Wire2', 1});
    
    sma = AddState(sma, 'Name', 'WaitForChoicePoke', 'Timer', 0,...
        'StateChangeConditions', [WhichChoiceIn, 'ChoiceOnHold', WrongPortsInChoice(1), 'ChoiceOnHoldPunish',...
        WrongPortsInChoice(2), 'ChoiceOnHoldPunish', WrongPortsInChoice(3), 'ChoiceOnHoldPunish',...
        WrongPortsInChoice(4), 'ChoiceOnHoldPunish'], 'OutputActions', [SampleLight ChoiceLight]);
    
    sma = AddState(sma, 'Name', 'ChoiceOnHold', 'Timer', ChoiceValveTime,...
        'StateChangeConditions', ['Tup', 'ChoiceOn', WhichChoiceOut, 'WaitForChoicePoke'],...
        'OutputActions', [SampleLight ChoiceLight]);
    
    sma = AddState(sma, 'Name', 'ChoiceOnHoldPunish', 'Timer', ChoiceValveTime,...
        'StateChangeConditions', ['Tup', 'Punish', WrongPortsOutChoice(1), 'WaitForChoicePoke',...
        WrongPortsOutChoice(2), 'WaitForChoicePoke', WrongPortsOutChoice(3), 'WaitForChoicePoke',...
        WrongPortsOutChoice(4), 'WaitForChoicePoke',], 'OutputActions', [SampleLight ChoiceLight]);
    
    %Choice poke comes 0.2 seconds before ChoiceOn
    sma = AddState(sma, 'Name', 'ChoiceOn', 'Timer', ChoiceValveTime,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', [ChoiceLight, ChoiceValve, 'Wire3', 1]);
    
    sma = AddState(sma, 'Name', 'SamplePunish', 'Timer', 3,...
        'StateChangeConditions', {'Tup', 'ITI2'},...
        'OutputActions', {'Valve6', 1});
    
    sma = AddState(sma, 'Name', 'SamplePunishEW', 'Timer', 3,...
        'StateChangeConditions', {'Tup', 'WaitForSamplePokeEW'},...
        'OutputActions', {'Valve6', 1});
    
    if RepeatTrial
    
        %(wrong) choice poke comes 0.2 seconds before Punish
        sma = AddState(sma, 'Name', 'Punish', 'Timer', S.GUI.PunishTime,...
            'StateChangeConditions', {'Tup', 'ITI2'},...
            'OutputActions', {'Valve6', 1, 'Wire3', 1, 'Wire1', 1});
    else
        
        sma = AddState(sma, 'Name', 'Punish', 'Timer', S.GUI.PunishTime,...
            'StateChangeConditions', {'Tup', 'exit'},...
            'OutputActions', {'Valve6', 1, 'Wire3', 1, 'Wire1', 1});
        
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
    if repeatsEnabled
        if currentTrial > 8
            LocalOutcomes = zeros(1,8);
            fillno = 0;
            for x = currentTrial-7:currentTrial
                fillno = fillno+1;
                if ~isnan(BpodSystem.Data.RawEvents.Trial{x}.States.Punish(1))
                    LocalOutcomes(fillno) = 0;
                elseif ~isnan(BpodSystem.Data.RawEvents.Trial{x}.States.ChoiceOn(1))
                    LocalOutcomes(fillno) = 1;
                end
            end
            LocalTrials = find(TrialTypes(currentTrial-7:currentTrial) == TrialTypes(currentTrial+1));
            Results = LocalOutcomes(LocalTrials);
            Percent = numel(find(Results))/numel(Results);
            if Percent < 0.5
                RepeatTrial = 1;
            else
                RepeatTrial = 0;
            end
        end
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
        
    
    
 