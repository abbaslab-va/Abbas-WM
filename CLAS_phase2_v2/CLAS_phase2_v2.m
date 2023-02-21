

function CLAS_phase2_v2

% SETUP
% You will need:
% - A Bpod MouseBox (or equivalent) configured with 3 ports.
% > Connect the left port in the box to Bpod Port#1.
% > Connect the center port in the box to Bpod Port#2.
% > Connect the right port in the box to Bpod Port#3.
% > Make sure the liquid calibration tables for ports 1 and 3 have 
%   calibration curves with several points surrounding 3ul.

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.ForageReward = 3; %ul
    S.GUI.ChirpReward = 8; 
    S.GUI.ITI = 10; % How long the mouse must poke in the center to activate the goal port
    S.GUI.ResponseTime = 5; % How long until the mouse must make a choice, or forefeit the trial
    S.GUI.SweepUpLow=10000;
    S.GUI.SweepUpHigh=14000;
    S.GUI.SoundDuration = 1;
    S.GUI.SamplingFreq = 44100;
    S.GUI.PunishTime=10;
    S.GUI.PuffTime=0.25; 
    S.GUI.DrinkGrace=1.5;
    S.GUI.TrialTime=30;
 
    
end
%%
if (isfield(BpodSystem.ModuleUSB, 'TeensyAudio1'))
    TeensyAudioUSB = BpodSystem.ModuleUSB.TeensyAudio1;
else
    error('Error: To run this protocol, you must first pair the TeensyAudio1 module with its USB port. Click the USB config button on the Bpod console.')
end


%% Define trials
MaxTrials = 200;
TrialTypes = zeros(1, 100);
for fill = 1:100
    indices = randperm(8);
    block=[1 2 3 4 5 6 7 8] ;
   
    for shuffle=1:8
        pick(shuffle)=block(indices(shuffle));
    end     
    TrialTypes(fill*8-7:fill*8) = pick; 

end 
% indices2=randperm(10);
%     block=[1 1 1 1 1 2 2 2 2 2];
%     pickBegin=block(indices2);
% TrialTypes=[pickBegin TrialTypes];

BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.

%% Initialize plots
BpodSystem.ProtocolFigures.TrialTypeOutcomePlotFig = figure('Position', [50 540 1000 200],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.TrialTypeOutcomePlot = axes('Position', [.075 .3 .89 .6]);
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'init',TrialTypes);
BpodNotebook('init');
BpodParameterGUI('init', S); % Initialize parameter GUI plugin
 

%% %% Create an instance of the TeensyAudioPlayer module 
T = TeensyAudioPlayer(TeensyAudioUSB);
LoadSerialMessages('ValveModule1',{['O' 3],['C' 3]})
%% Define stimuli and send to Teensy
% SF = S.GUI.SamplingFreq;
% t = linspace(0, S.GUI.SoundDuration, S.GUI.SoundDuration*S.GUI.SamplingFreq);
% UpSweep = chirp(t, S.GUI.SweepUpLow, t(end), S.GUI.SweepUpHigh);



% Set Noise in audacity to 0.03
% chirp 20to1= 0.3
%Chiro1to5 = 0.005
% 
 Chirp20to1=audioread('SNR_03102022_0.5s.wav');
 %Chirp20to1=audioread('newCHIRP_SNR20to1_4X_2SEC.wav');
 %Chirp1to1=audioread('newCHIRP_SNR1to1.wav');
 Noise=audioread('NOISE_03102022.wav');
% Noise1to5=audioread('Noise_1to5.wav');
 Silence=zeros(1,44100);
% 
% 
T.load(1, Noise);
T.load(2, Chirp20to1);
T.load(3, Silence);
% 
analogPortIndex = find(strcmp(BpodSystem.Modules.Name, 'TeensyAudio1'));
if isempty(analogPortIndex)
    error('Error: Bpod TeensyAudio module not found. If you just plugged it in, please restart Bpod.')
end

%% Main trial loop

BpodSystem.SoftCodeHandlerFunction = 'CLAS_phase1_v2_FUN';
global visited

for currentTrial = 1:MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
BpodSystem.Data.PortsVisited= zeros(1,6);

visited=zeros(1,6);


switch TrialTypes(currentTrial)
    case 1 
      PickDur=7
      PickNoise=1
      PickChirp=2
    case 2
      PickDur=8
      PickNoise=1
      PickChirp=2
    case 3
      PickDur=10  
      PickNoise=1
      PickChirp=2
    case 4
      PickDur=12
      PickNoise=1
      PickChirp=2  
    case 5
      PickDur=14 
      PickNoise=1
      PickChirp=2
    case 6 
      PickDur=16
      PickNoise=1
      PickChirp=2
    case 7 % forage only trials 
      PickDur=100
      PickNoise=1
      PickChirp=2   
    case 8 % forage only trials 
      PickDur=100
      PickNoise=1
      PickChirp=2       
end 
          
        sma = NewStateMachine(); % Initialize new state machine description
        
        sma=SetGlobalTimer(sma,'TimerID',1,'Duration',PickDur)
        sma=SetGlobalTimer(sma,'TimerID',2,'Duration',S.GUI.TrialTime)
               

        sma = AddState(sma, 'Name', 'ITI', ...
            'Timer',S.GUI.ITI,...
            'StateChangeConditions', {'Tup','TriggerTimers1'},...
            'OutputActions',{'TeensyAudio1',3});
        
        sma = AddState(sma, 'Name', 'TriggerTimers1', ...
            'Timer',0,...
            'StateChangeConditions', {'Tup','TriggerTimers2'},...
            'OutputActions',{'GlobalTimerTrig',2});
        
        sma = AddState(sma, 'Name', 'TriggerTimers2', ...
            'Timer',0,...
            'StateChangeConditions', {'Tup','WaitForFirstPoke'},...
            'OutputActions',{'GlobalTimerTrig',1});

        sma = AddState(sma, 'Name', 'WaitForFirstPoke', ...
            'Timer',0,...
            'StateChangeConditions', {'Port1In','Port1InMark','Port2In','Port2InMark','Port3In','Port3InMark','Port4In','Port4InMark','Port5In','Port5InMark','GlobalTimer2_End','exit','GlobalTimer1_End','Chirp1'},...
            'OutputActions',{'TeensyAudio1',PickNoise,'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});
        
        sma = AddState(sma, 'Name', 'Port1InMark', ...
            'Timer',0,...
            'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','WaitForPoke','GlobalTimer2_End','exit'},...
            'OutputActions',{'SoftCode',1});
        
        sma = AddState(sma, 'Name', 'Port2InMark', ...
            'Timer',0,...
            'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','WaitForPoke','GlobalTimer2_End','exit'},...
            'OutputActions',{'SoftCode',2});

        sma = AddState(sma, 'Name', 'Port3InMark', ...
            'Timer',0,...
            'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','WaitForPoke','GlobalTimer2_End','exit'},...
            'OutputActions',{'SoftCode',3});

        sma = AddState(sma, 'Name', 'Port4InMark', ...
            'Timer',0,...
            'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','WaitForPoke','GlobalTimer2_End','exit'},...
            'OutputActions',{'SoftCode',4});

        sma = AddState(sma, 'Name', 'Port5InMark', ...
            'Timer',0,...
            'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','WaitForPoke','GlobalTimer2_End','exit'},...
            'OutputActions',{'SoftCode',5});

        sma = AddState(sma, 'Name', 'WaitForPoke', ...
            'Timer',0,...
            'StateChangeConditions', {'GlobalTimer1_End','Chirp1','SoftCode1', 'Reward1','SoftCode2', 'Reward2','SoftCode3', 'Reward3','SoftCode4', 'Reward4','SoftCode5', 'Reward5','GlobalTimer2_End','exit'},...
            'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});

        sma = AddState(sma, 'Name', 'Reward1', ...
                'Timer',0,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Port1In','Reward1_1','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});

        sma = AddState(sma, 'Name', 'Reward1_1', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,1),...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','DrinkGrace1','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'Valve1',1,'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});  

        sma = AddState(sma, 'Name', 'Reward2', ...
                'Timer',0,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Port2In','Reward2_1','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20,'PWM7', 20});

        sma = AddState(sma, 'Name', 'Reward2_1', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,2),...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','DrinkGrace2','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'Valve2',1,'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});

        sma = AddState(sma, 'Name', 'Reward3', ...
                'Timer',0,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Port3In','Reward3_1','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});

        sma = AddState(sma, 'Name', 'Reward3_1', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,3),...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','DrinkGrace3','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'Valve3',1,'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});

        sma = AddState(sma, 'Name', 'Reward4', ...
                'Timer',0,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Port4In','Reward4_1','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});

        sma = AddState(sma, 'Name', 'Reward4_1', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,4),...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','DrinkGrace4','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'Valve4',1,'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});

        sma = AddState(sma, 'Name', 'Reward5', ...
                'Timer',0,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Port5In','Reward5_1','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});

        sma = AddState(sma, 'Name', 'Reward5_1', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,5),...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','DrinkGrace5','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'Valve5',1,'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});
        
        sma = AddState(sma, 'Name', 'DrinkGrace1', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','Port1InMark','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20}); 
            
        sma = AddState(sma, 'Name', 'DrinkGrace2', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','Port2InMark','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20}); 
              
        sma = AddState(sma, 'Name', 'DrinkGrace3', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','Port3InMark','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20}); 
              
        sma = AddState(sma, 'Name', 'DrinkGrace4', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','Port4InMark','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20}); 
            
        sma = AddState(sma, 'Name', 'DrinkGrace5', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','Port5InMark','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20}); 
            
        sma = AddState(sma, 'Name', 'Chirp1', ...
                'Timer',1,...
                'StateChangeConditions', {'Tup','ChirpPlay','Port1Out','ChirpPlay','Port2Out','ChirpPlay','Port3Out','ChirpPlay','Port4Out','ChirpPlay','Port5Out','ChirpPlay','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20 'PWM7', 20});
             
        sma = AddState(sma, 'Name', 'ChirpPlay', ...
                'Timer',0.5,...
                'StateChangeConditions', {'Tup','WaitForChirp','Port7In','Reward','GlobalTimer2_End','exit'},...
                'OutputActions',{'TeensyAudio1',PickChirp,'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});

        sma = AddState(sma, 'Name', 'WaitForChirp', ...
                'Timer',1.0,...
                'StateChangeConditions', {'Tup','ChirpPlay','Port7In','Reward','GlobalTimer2_End','exit'},...
                'OutputActions',{'TeensyAudio1',PickNoise,'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});
         
        sma = AddState(sma, 'Name', 'Reward', ...
                'Timer',GetValveTimes(S.GUI.ChirpReward,7),...
                'StateChangeConditions', {'Tup','DrinkGrace7','GlobalTimer2_End','exit'},...
                'OutputActions',{'Valve7',1,'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});
             
        sma = AddState(sma, 'Name', 'DrinkGrace7', ...
                'Timer',1,...
                'StateChangeConditions', {'Port7Out','WaitForFirstPoke','Tup','WaitForFirstPoke','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});
                
        sma = AddState(sma, 'Name', 'Punish', ...
                'Timer',S.GUI.PunishTime,...
                'StateChangeConditions', {'Tup','exit','GlobalTimer2_End','exit'},...
                'OutputActions',{'Valve6',1});


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
    
        
end



function UpdateTrialTypeOutcomePlot(TrialTypes, Data)
% Determine outcomes from state data and score as the TrialTypeOutcomePlot
% plugin expects
global BpodSystem
Outcomes = zeros(1,Data.nTrials);
for x = 1:Data.nTrials
    if ~isnan(Data.RawEvents.Trial{x}.States.Punish(1))
        Outcomes(x) = 0;
        
    elseif ~isnan(Data.RawEvents.Trial{x}.States.Reward(1))
        Outcomes(x) = 1;
        
    elseif ~isnan(Data.RawEvents.Trial{x}.States.Reward(1))
        Outcomes(x) = 1;
        
    elseif Data.TrialTypes(x)==7 || Data.TrialTypes(x)==8 
        Outcomes(x) = 1;
    else 
        Outcomes(x) = 3;
    end
end
BpodSystem.Data.SessionPerformance = Outcomes;
SaveBpodSessionData;
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes);
