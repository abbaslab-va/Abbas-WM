function Chase_the_Light

%The training protocol for a 4 port spatial working memory task. This
%script introduces punishments, extended delay period and early
%withdrawals, as well as trial repeats.

global BpodSystem

S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.reward_vol = 5;     %μl  
    S.GUI.ITI = 5;             %seconds
    S.Gui.PunishTime = 5       %seconds
end

%% Define trials
AllPortsIn = {'Port1In', 'Port2In', 'Port3In'};
AllPortsOut = {'Port1Out', 'Port2Out', 'Port3Out'};
numTT = 3;
trialsPerType = 100;
MaxTrials = numTT * trialsPerType;
TrialTypes = zeros(1, MaxTrials);
TrialTypes(1) = randi(3,1);
for i = 2:MaxTrials
    Available_trials = setdiff([1:3], TrialTypes(i-1));
    TrialTypes(i) = randsample(Available_trials,1);
end
BpodSystem.Data.TrialTypes = []; 
%% Initialize plots

BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [50 340 1000 400],'name','Duration plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.TrialDurationPlot = axes('Position', [.075 .3 .89 .6]);
xlabel(BpodSystem.GUIHandles.TrialDurationPlot,'Trial number')
ylabel(BpodSystem.GUIHandles.TrialDurationPlot,'Time to port (s)')
sgtitle(replace(BpodSystem.GUIData.SubjectName,'_','  '))
BpodNotebook('init');
BpodParameterGUI('init', S); % Initialize parameter GUI plugin
%% Main trial loop
for currentTrial = 1:MaxTrials
        
    S = BpodParameterGUI('sync', S);
    currentTT = TrialTypes(currentTrial);
   
    switch currentTT
        case 1 % Port #1 (Back) - Large reward
            SampleLight = {'PWM2', 50, 'PWM3', 50}; SampleValve = {'Valve1', 1};
            WhichSampleIn = {'Port1In'}; WhichSampleOut = {'Port1Out'};
            SampleValveTime = GetValveTimes(S.GUI.reward_vol, 1);
        case 2 % Port #2 (Right)
            SampleLight = {'PWM1', 50, 'PWM3', 50}; SampleValve = {'Valve2', 1};
            WhichSampleIn = {'Port2In'}; WhichSampleOut = {'Port2Out'};
            SampleValveTime = GetValveTimes(S.GUI.reward_vol, 2);
        case 3 % Port #3 (Left)
            SampleLight = {'PWM1', 50, 'PWM2', 50}; SampleValve = {'Valve3', 1};
            WhichSampleIn = {'Port3In'}; WhichSampleOut = {'Port3Out'};
            SampleValveTime = GetValveTimes(S.GUI.reward_vol, 3);
    end
    
    WrongPortsInSample = setdiff(AllPortsIn, WhichSampleIn);
    WrongPortsOutSample = setdiff(AllPortsOut, WhichSampleOut);
    
    sma = NewStateMatrix(); % Assemble state matrix
        
    sma = AddState(sma, 'Name', 'Trial_start_time', 'Timer', 0,...
        'StateChangeConditions', {'Tup', 'WaitForSamplePoke'},...
        'OutputActions', {'Wire1', 1});
    
    sma = AddState(sma, 'Name', 'WaitForSamplePoke', 'Timer', 0,...
        'StateChangeConditions', [WhichSampleIn, 'SampleOnHold', WrongPortsInSample(1), 'SampleOnHoldPunish',...
        WrongPortsInSample(2), 'SampleOnHoldPunish'],...
        'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'SampleOnHold', 'Timer', .05,...
        'StateChangeConditions', ['Tup', 'SampleReward', WhichSampleOut, 'WaitForSamplePoke'],...
        'OutputActions', SampleLight);

    sma = AddState(sma, 'Name', 'SampleOnHoldPunish', 'Timer', .05,...
        'StateChangeConditions', ['Tup', 'Punish', WrongPortsOutSample(1), 'WaitForSamplePoke',...
        WrongPortsOutSample(2), 'WaitForSamplePoke'],...
        'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'ITI', 'Timer', S.GUI.ITI/2,...
        'StateChangeConditions', {'Tup', 'ITI2'},...
        'OutputActions', {});

    sma = AddState(sma, 'Name', 'ITI2', 'Timer', S.GUI.ITI/2,...
        'StateChangeConditions', {'Tup', 'Trial_start_time', 'Port1In', 'ScanPunish',...
        'Port2In', 'ScanPunish', 'Port3In', 'ScanPunish'},...
        'OutputActions', {});

    sma = AddState(sma, 'Name', 'ScanPunish', 'Timer', 0,...
        'StateChangeConditions', {'Port1Out', 'ITI2', 'Port2Out', 'ITI2', 'Port3Out', 'ITI2',},...
        'OutputActions', {'Valve8', 1});

    if currentTrial < 6
    
        sma = AddState(sma, 'Name', 'Punish', 'Timer', 0,...
            'StateChangeConditions', {'Tup', 'WaitForSamplePoke'},...
            'OutputActions', [SampleLight, 'Wire3', 1]);

    elseif currentTrial > 5

        sma = AddState(sma, 'Name', 'Punish', 'Timer', S.GUI.PunishTime,...
            'StateChangeConditions', {'Tup', 'exit'},...
            'OutputActions', {'Valve8', 1, 'Wire3', 1});  
    
    end

    sma = AddState(sma, 'Name', 'SampleReward', 'Timer', SampleValveTime,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', [SampleLight, SampleValve, 'Wire2', 1]);

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
    Outcomes(x) = Data.RawEvents.Trial{x}.States.SampleReward(1) - Data.RawEvents.Trial{x}.States.ITI(2); % trial length
    % if ~isnan(Data.RawEvents.Trial{x}.States.ITI(2)) && ~isnan(Data.RawEvents.Trial{x}.States.SampleReward(1))
    %     Outcomes(x) = 2;
    % elseif ~isnan(Data.RawEvents.Trial{x}.States.Punish(1))
    %     Outcomes(x) = 0;
    % elseif ~isnan(Data.RawEvents.Trial{x}.States.ChoiceOn(1))
    %     Outcomes(x) = 1;
    % end
end
BpodSystem.Data.SessionPerformance = Outcomes;
SaveBpodSessionData;
hold(BpodSystem.GUIHandles.TrialDurationPlot,'on')
timePlot = plot(BpodSystem.GUIHandles.TrialDurationPlot, 1:BpodSystem.Data.nTrials, Outcomes(1:BpodSystem.Data.nTrials),'k');

T1_inds = find(TrialTypes(1:BpodSystem.Data.nTrials)==1);
T2_inds = find(TrialTypes(1:BpodSystem.Data.nTrials)==2);
T3_inds = find(TrialTypes(1:BpodSystem.Data.nTrials)==3);
if ~isempty(T1_inds)
t1Scatter = scatter(BpodSystem.GUIHandles.TrialDurationPlot, T1_inds, Outcomes(T1_inds), 'r','filled');
end

if ~isempty(T2_inds)
t2Scatter = scatter(BpodSystem.GUIHandles.TrialDurationPlot, T2_inds, Outcomes(T2_inds), 'g','filled');
end

if ~isempty(T3_inds)
t3Scatter = scatter(BpodSystem.GUIHandles.TrialDurationPlot, T3_inds, Outcomes(T3_inds), 'b','filled');
end
if exist('t1Scatter', 'var') && exist ('t2Scatter', 'var') && exist('t3Scatter', 'var')
    legend(BpodSystem.GUIHandles.TrialDurationPlot, [timePlot, t1Scatter, t2Scatter, t3Scatter],"", "Back (high)", "Right", "Left")
%     if BpodSystem.GUIHandles.TrialDurationPlot.YLim(2) >30
%         BpodSystem.GUIHandles.TrialDurationPlot.YLim(2)= 30;
%     end
end
