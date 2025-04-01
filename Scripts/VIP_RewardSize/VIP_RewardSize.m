function VIP_RewardSize

global BpodSystem
global Outcomes
%% Resolve AudioPlayer USB port

S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
% if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings

    S.GUI.CenterReward = 1; %ul
    S.GUI.SmallReward = 0.05; %ul
    S.GUI.LargeReward = 10; %ul
    S.GUI.RewardDelay = 0.01; % How long the mouse must poke in the center to activate the goal port
    S.GUI.ResponseTime = 7; % How long until the mouse must make a choice, or forefeit the trial
    S.GUI.DelayTime = 0; % How long the mouse waits between sample and test
    S.GUI.PunishTime = 5; %Length of punishment
    S.GUI.CerePlexRefreshRate = 0;
    S.GUI.ITI = 3; %Time between end of trial to start of next one
    
% end

%% Define trials

MaxTrials = 900;
TrialTypes = ones(1, 900);
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.

%% Initialize plots
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [50 340 1000 400],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.TrialTypeOutcomePlot = axes('Position', [.075 .3 .89 .6]);
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'init',TrialTypes);
BpodNotebook('init');
BpodParameterGUI('init', S); % Initialize parameter GUI plugin

%% Main trial loop    

RandomPort = randperm(3);
WhichCenterPort = {'Port1In', 'Port2In', 'Port3In'};
WhichCenterValve = {'Valve1', 'Valve2', 'Valve3'};
WhichLight = {'PWM1', 'PWM2', 'PWM3'};
WhichPortOut = {'Port1Out', 'Port2Out', 'Port3Out'};
WhichCenterValveTime = [1 2 3];

CenterRewardPoke = WhichCenterPort{RandomPort(1)};
CenterReward = GetValveTimes(S.GUI.CenterReward, WhichCenterValveTime(RandomPort(1)));
CenterValve = WhichCenterValve{RandomPort(1)};

LargeRewardPoke = WhichCenterPort{RandomPort(2)};
LargeReward = GetValveTimes(S.GUI.LargeReward, WhichCenterValveTime(RandomPort(2)));
LargeValve = WhichCenterValve{RandomPort(2)};

SmallRewardPoke = WhichCenterPort{RandomPort(3)};
SmallReward = GetValveTimes(S.GUI.SmallReward, WhichCenterValveTime(RandomPort(3)));
SmallValve = WhichCenterValve{RandomPort(3)};

WhichLightCenter = WhichLight{RandomPort(1)};
WhichLightLarge = WhichLight{RandomPort(2)};
WhichLightSmall = WhichLight{RandomPort(3)};

WhichCenterPortOut = WhichPortOut{RandomPort(1)};

correctswitches = 0
count = 0
TotalCount = 0
for currentTrial = 1:100
    
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin

    % Assemble state matrix
    sma = NewStateMatrix(); 
    
    %ITI with no active lights/ports
    sma = AddState(sma, 'Name', 'ITI', 'Timer', S.GUI.ITI,...
        'StateChangeConditions', {'Tup', 'WaitForInitPoke'},...
        'OutputActions', {});
    
    %first state just sends a signal to the state machine in order to timestamp trial start
%     sma = AddState(sma, 'Name', 'TrialStart', 'Timer', S.GUI.CerePlexRefreshRate,...
%         'StateChangeConditions', {'Tup', 'WaitForInitPoke'},...
%         'OutputActions', {'Wire1', 1});
    
    %second state, waiting for first choice
    sma = AddState(sma, 'Name', 'WaitForInitPoke', 'Timer', 0,...
        'StateChangeConditions', {CenterRewardPoke, 'RewardDelay'}, 'OutputActions',...
        {WhichLightCenter, 80});
    
    %If mouse holds in back port long enough then go to reward state
    sma = AddState(sma, 'Name', 'RewardDelay', 'Timer', S.GUI.RewardDelay,...
        'StateChangeConditions', {WhichCenterPortOut, 'WaitForInitPoke', 'Tup', 'InitReward'},...
        'OutputActions', {WhichLightCenter, 80});

    %Back Port Reward State - Amount of water diepensed is based on the valve time from the port
    %calibration curve
    sma = AddState(sma, 'Name', 'InitReward', 'Timer', CenterReward,...
        'StateChangeConditions', {'Tup', 'ChoicePhase'},...
        'OutputActions', {CenterValve, 1});
    

    %Waiting for mouse to choose a choice port
    sma = AddState(sma, 'Name', 'ChoicePhase', 'Timer', 0,...
        'StateChangeConditions', {LargeRewardPoke, 'LargeReward', SmallRewardPoke, 'SmallReward'},...
        'OutputActions', {WhichLightLarge, 80, WhichLightSmall, 80}); 

    %Giving Large reward and starting new trial
    sma = AddState(sma, 'Name', 'LargeReward', 'Timer', LargeReward,...
        'StateChangeConditions',{'Tup', 'exit'},...
        'OutputActions', {LargeValve, 1});
    
    %Giving Small reward and starting new trial
    sma = AddState(sma, 'Name', 'SmallReward', 'Timer', 5,...
        'StateChangeConditions',{'Tup', 'exit'},...
        'OutputActions', {});


    SendStateMatrix(sma);
    
   
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial); % Adds the trial type of the current trial to data
        UpdateTrialTypeOutcomePlot(TrialTypes, BpodSystem.Data);
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end
    
    %Adaptive Reward size - switches the port that the large reward is on
    %after 7 consecutive large rewards
    
    if Outcomes(currentTrial) == 1
        
        count = count + 1
        TotalCount = TotalCount + 1
        correctswitches
        
        if count == 7

            priorLargeValve = LargeValve;
            priorSmallValve = SmallValve;
            LargeValve = priorSmallValve;
            SmallValve = priorLargeValve;
            
            priorLargeRewardPoke = LargeRewardPoke;
            priorSmallRewardPoke = SmallRewardPoke;
            LargeRewardPoke = priorSmallRewardPoke;
            SmallRewardPoke = priorLargeRewardPoke;

%             LargeReward = SmallReward;
%             LargeValve = SmallValve;
%             tempLargeReward = LargeReward;
%             
%             SmallReward = tempLargeReward;
%             SmallValve = tempLargeValve;
            
            count = 0
            correctswitches = correctswitches+1
                    
        end  
        
    elseif Outcomes(currentTrial) ~= 1
        
        count = 0
        
    end
    
end

SendSlackNotification('https://hooks.slack.com/services/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', 'Session End')

function UpdateTrialTypeOutcomePlot(TrialTypes, Data)

global BpodSystem
global Outcomes

Outcomes = zeros(1,Data.nTrials);

for x = 1:Data.nTrials
    
    if ~isnan(Data.RawEvents.Trial{x}.States.LargeReward(1))
        Outcomes(x) = 1;
    else
        Outcomes(x) = 0;
    end
    
end
BpodSystem.Data.SessionPerformance = Outcomes;
SaveBpodSessionData;
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes);