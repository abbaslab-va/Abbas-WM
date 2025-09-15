function Light_Dark_Switch

%The training protocol for a 4 port spatial working memory task. This
%script introduces punishments, extended delay period and early
%withdrawals, as well as trial repeats.

global BpodSystem


S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.Large_reward_vol = 7;     %μl
    S.GUI.Small_reward_vol = 0;     %μl  
    S.GUI.ITI = 1;             %seconds
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

correctswitches = 0
count = 0
TotalCount = 0
currentblock = randperm(2)-1;

Chase_Light = [{'PWM1', 100}, {'PWM2', 100}, {'PWM3', 100}]
Chase_Dark = [{'PWM2', 100, 'PWM3', 100}, {'PWM1', 100, 'PWM3', 100}, {'PWM1', 100, 'PWM2', 100}]

for currentTrial = 1:MaxTrials
        
    S = BpodParameterGUI('sync', S);
    currentTT = TrialTypes(currentTrial);
   
    if currentblock == 0

        SampleLight = Chase_Light(currentTT)

    elseif currentblock == 1

        SampleLight = Chase_Dark(currentTT)

    end

    switch currentTT
        case 1 % Port #1 (Back) - Large reward
            SampleValve = {'Valve1', 1};
            WhichSampleIn = {'Port1In'}; WhichSampleOut = {'Port1Out'};
            SampleValveTime = GetValveTimes(S.GUI.Large_reward_vol, 1);
        case 2 % Port #2 (Right)
            SampleValve = {'Valve2', 1};
            WhichSampleIn = {'Port2In'}; WhichSampleOut = {'Port2Out'};
            SampleValveTime = GetValveTimes(S.GUI.Small_reward_vol, 2);
        case 3 % Port #3 (Left)
            SampleValve = {'Valve3', 1};
            WhichSampleIn = {'Port3In'}; WhichSampleOut = {'Port3Out'};
            SampleValveTime = GetValveTimes(S.GUI.Small_reward_vol, 3);
    end
    
    
    sma = NewStateMatrix(); % Assemble state matrix
        
    sma = AddState(sma, 'Name', 'ITI', 'Timer', S.GUI.ITI,...
        'StateChangeConditions', {'Tup', 'Trial_start_time'},...
        'OutputActions', {});

    sma = AddState(sma, 'Name', 'Trial_start_time', 'Timer', 0,...
        'StateChangeConditions', {'Tup', 'WaitForSamplePoke'},...
        'OutputActions', {'Wire1', 1});
    

    sma = AddState(sma, 'Name', 'WaitForSamplePoke', 'Timer', 0,...
        'StateChangeConditions', [WhichSampleIn, 'SampleOnHold'],...
        'OutputActions', SampleLight);
    
    sma = AddState(sma, 'Name', 'SampleOnHold', 'Timer', .05,...
        'StateChangeConditions', ['Tup', 'SampleReward', WhichSampleOut, 'WaitForSamplePoke'],...
        'OutputActions', SampleLight);
    
    
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

    if Outcomes(currentTrial) == 1
    
        
        count = count + 1
        TotalCount = TotalCount + 1
        correctswitches
        
        if count == 7

            currentblock = ~currentblock
            
            count = 0
            correctswitches = correctswitches+1
                    
        end  
        
    elseif Outcomes(currentTrial) ~= 1
        
        count = 0
        
    end

end

function UpdateTrialTypeOutcomePlot(TrialTypes, Data)
global BpodSystem
global Outcomes
Outcomes = zeros(1,Data.nTrials);

for x = 1:Data.nTrials
    
    if ~isnan(Data.RawEvents.Trial{x}.States.SampleReward(1))
        Outcomes(x) = 1;
    else
        Outcomes(x) = 0;
    end
    
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