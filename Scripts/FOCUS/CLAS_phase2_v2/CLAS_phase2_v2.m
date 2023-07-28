

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
    S.GUI.ForageReward = 1; %ul
    S.GUI.ChirpReward = 8; 
    S.GUI.ITI = 5; % How long the mouse must poke in the center to activate the goal port
    S.GUI.ResponseTime = 5; % How long until the mouse must make a choice, or forefeit the trial
    S.GUI.SweepUpLow=10000;
    S.GUI.SweepUpHigh=14000;
    S.GUI.SoundDuration = 1;
    S.GUI.SamplingFreq = 44100;
    S.GUI.PunishTime=1;
    S.GUI.PuffTime=0.25; 
    S.GUI.DrinkGrace=0.5;
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
%LoadSerialMessages('ValveModule1',{['O' 3],['C' 3]})
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
 %Noise=audioread('noise(0.01)_03242023.wav');
% Noise1to5=audioread('Noise_1to5.wav');
% Silence=zeros(1,44100);
% 
% 
%T.load(1, Noise);
T.load(2, Chirp20to1);
%T.load(3, Silence);
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
random={'Port1In', 'Port2In','Port3In','Port4In','Port5In'};
PortPicks=randsample(random,2); 

PortIn=PortPicks{1};
PortIn2=PortPicks{2};

if PortIn=='Port1In'
    Valve='Valve1';
    Port=1; 
elseif PortIn=='Port2In'
    Valve='Valve2';
    Port=2; 
elseif PortIn=='Port3In'
    Valve='Valve3';
    Port=3 ;
elseif PortIn=='Port4In'
    Valve='Valve4';
    Port=4;
elseif PortIn=='Port5In'
    Valve='Valve5';
    Port=5;
end 



if PortIn2=='Port1In'
    Valve2='Valve1';
    Port2=1 ;
elseif PortIn2=='Port2In'
    Valve2='Valve2';
    Port2=2 ;
elseif PortIn2=='Port3In'
    Valve2='Valve3';
    Port2=3 ;
elseif PortIn2=='Port4In'
    Valve2='Valve4';
    Port2=4;
elseif PortIn2=='Port5In'
    Valve2='Valve5';
    Port2=5;
end 


switch TrialTypes(currentTrial)
    case 1 
      PickDur=7
      PickChirp=2
      time1=2
      time2=2
      time3=2
    case 2
      PickDur=8
      PickChirp=2
      time1=2
      time2=2
      time3=2
    case 3
      PickDur=10  
      PickChirp=2
      time1=2
      time2=2
      time3=2
    case 4
      PickDur=12
      PickChirp=2
      time1=2
      time2=2
      time3=2
    case 5
      PickDur=7 
      PickChirp=2
      time1=2
      time2=2
      time3=2
    case 6 
      PickDur=8
      PickChirp=2
      time1=2
      time2=2
      time3=2
    case 7 % forage only trials 
      PickDur=100
      PickChirp=2
      time1=.1
      time2=.1
      time3=.1
    case 8 % forage only trials 
      PickDur=100
      PickChirp=2  
      time1=.1
      time2=.1
      time3=.1
end 
          
        sma = NewStateMachine(); % Initialize new state machine description
        
        sma=SetGlobalTimer(sma,'TimerID',1,'Duration',PickDur)
        sma=SetGlobalTimer(sma,'TimerID',2,'Duration',S.GUI.TrialTime)
               

        sma = AddState(sma, 'Name', 'ITI', ...
            'Timer',S.GUI.ITI,...
            'StateChangeConditions', {'Tup','WaitForAPoke'},...
            'OutputActions',{});
        
%         sma = AddState(sma, 'Name', 'Dispense', ...
%                 'Timer',GetValveTimes(S.GUI.ForageReward,1),...
%                 'StateChangeConditions', {'Tup','WaitForAPoke'},...
%                 'OutputActions',{'Valve1',1,'Valve2',1,'Valve3',1,'Valve4',1,'Valve5',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50 'PWM7', 50});  
% %         
%         
         sma = AddState(sma, 'Name', 'WaitForAPoke', ...
            'Timer',0,...
            'StateChangeConditions', {'Port1In','TriggerTimers1','Port2In','TriggerTimers1','Port3In','TriggerTimers1','Port4In','TriggerTimers1','Port5In','TriggerTimers1'},...
            'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});
        
        
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
            'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});
     
        
        
        sma = AddState(sma, 'Name', 'WaitForFirstPokeAfter', ...
            'Timer',0,...
            'StateChangeConditions', {'Port1In','Port1InMark','Port2In','Port2InMark','Port3In','Port3InMark','Port4In','Port4InMark','Port5In','Port5InMark','GlobalTimer2_End','exit','GlobalTimer1_End','Chirp1'},...
            'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});
        
        sma = AddState(sma, 'Name', 'Port1InMark', ...
            'Timer',0,...
            'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','WaitForPoke','GlobalTimer2_End','exit','GlobalTimer1_End','Chirp1'},...
            'OutputActions',{'SoftCode',1});
        
        sma = AddState(sma, 'Name', 'Port2InMark', ...
            'Timer',0,...
            'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','WaitForPoke','GlobalTimer2_End','exit','GlobalTimer1_End','Chirp1'},...
            'OutputActions',{'SoftCode',2});

        sma = AddState(sma, 'Name', 'Port3InMark', ...
            'Timer',0,...
            'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','WaitForPoke','GlobalTimer2_End','exit','GlobalTimer1_End','Chirp1'},...
            'OutputActions',{'SoftCode',3});

        sma = AddState(sma, 'Name', 'Port4InMark', ...
            'Timer',0,...
            'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','WaitForPoke','GlobalTimer2_End','exit','GlobalTimer1_End','Chirp1'},...
            'OutputActions',{'SoftCode',4});

        sma = AddState(sma, 'Name', 'Port5InMark', ...
            'Timer',0,...
            'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','WaitForPoke','GlobalTimer2_End','exit','GlobalTimer1_End','Chirp1'},...
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
                'Timer',0,...
                'StateChangeConditions', {'Port1Out','Laser','Port2Out','Laser','Port3Out','Laser','Port4Out','Laser','Port5Out','Laser','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20 'PWM7', 20});
        
        sma = AddState(sma, 'Name', 'Laser', ...
                'Timer',0.5,...
                'StateChangeConditions', {'Tup','ChirpPlay','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20 'PWM7', 20});   
            
             
        sma = AddState(sma, 'Name', 'ChirpPlay', ...
                'Timer',0.5,...
                'StateChangeConditions', {'Tup','Laser2','Port7In','Reward','GlobalTimer2_End','exit'},...
                'OutputActions',{'TeensyAudio1',PickChirp,'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});
%             
%         sma = AddState(sma, 'Name', 'ChirpPlay2', ...
%                 'Timer',0.5,...
%                 'StateChangeConditions', {'Tup','Laser2','Port7In','Reward','GlobalTimer2_End','exit'},...
%                 'OutputActions',{'TeensyAudio1',PickChirp,'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});
%             
        sma = AddState(sma, 'Name', 'Laser2', ...
                'Timer',0.5,...
                'StateChangeConditions', {'Tup','WaitForChirp1','Port7In','Reward','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});
            
            
        %%  
            
        sma = AddState(sma, 'Name', 'WaitForChirp1', ...
               'Timer',time1,...
                'StateChangeConditions', {'Tup','WaitForChirp2','Port7In','Reward','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});          
              
            
        sma = AddState(sma, 'Name', 'WaitForChirp2', ...
               'Timer',time2,...
                'StateChangeConditions', {'Tup','Abort','Port7In','Reward','GlobalTimer2_End','exit', PortIn, 'ExtraFrontIn'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20}); 
            
            
              
        sma = AddState(sma, 'Name', 'WaitForChirp3', ...
               'Timer',time3,...
                'StateChangeConditions', {'Tup','Abort','Port7In','Reward','GlobalTimer2_End','exit', PortIn2,'ExtraFrontIn2'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});    
            
             
        sma = AddState(sma, 'Name', 'ExtraFrontIn', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,Port),...
                'StateChangeConditions', {'Tup','ExtraFrontGrace','GlobalTimer2_End','exit'},...
                'OutputActions',{Valve,1,'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});
            
            
        sma = AddState(sma, 'Name', 'ExtraFrontGrace', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'Tup','WaitForChirp3','GlobalTimer2_End','exit','Port7In','Reward'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20}); 
            
           
          
             sma = AddState(sma, 'Name', 'ExtraFrontIn2', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,Port2),...
                'StateChangeConditions', {'Tup','ExtraFrontGrace2','GlobalTimer2_End','exit'},...
                'OutputActions',{Valve2,1,'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4',20,'PWM5', 20, 'PWM7', 20,'Wire1',1,'Wire2',1});
            
             sma = AddState(sma, 'Name', 'ExtraFrontGrace2', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'Tup','Abort','GlobalTimer2_End','exit','Port7In','Reward'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3',20,'PWM4', 20,'PWM5', 20, 'PWM7', 20}); 
            
    
            
            
            
            
            
% 
%         sma = AddState(sma, 'Name', 'WaitForChirp', ...
%                 'Timer',3.0,...
%                 'StateChangeConditions', {'Tup','WaitForFirstPokeAfter','Port7In','Reward','GlobalTimer2_End','exit'},...
%                 'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 50});
%             
         
        sma = AddState(sma, 'Name', 'Reward', ...
                'Timer',GetValveTimes(S.GUI.ChirpReward,7),...
                'StateChangeConditions', {'Tup','DrinkGrace7','GlobalTimer2_End','exit'},...
                'OutputActions',{'Valve7',1,'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 50});
             
        sma = AddState(sma, 'Name', 'DrinkGrace7', ...
                'Timer',1,...
                'StateChangeConditions', {'Port7Out','WaitForFirstPokeAfter','Tup','WaitForFirstPokeAfter','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});
                
        sma = AddState(sma, 'Name', 'Punish', ...
                'Timer',S.GUI.PunishTime,...
                'StateChangeConditions', {'Tup','exit'},...
                'OutputActions',{});
            
                           
        sma = AddState(sma, 'Name', 'Abort', ...
                'Timer',0,...
                'StateChangeConditions', {'Tup','exit'},...
                'OutputActions',{});


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
    if ~isnan(Data.RawEvents.Trial{x}.States.Reward(1)) && ~isnan(Data.RawEvents.Trial{x}.States.Punish(1))
        % this is for when the  have a hit but then go back later on in the
        % trial and then get punished 
        Outcomes(x) = 1;
    elseif ~isnan(Data.RawEvents.Trial{x}.States.Punish(1))
        Outcomes(x) = 0;
         
    elseif ~isnan(Data.RawEvents.Trial{x}.States.Reward(1))
        Outcomes(x) = 1;
        
    elseif Data.TrialTypes(x)==7 || Data.TrialTypes(x)==8 
        Outcomes(x) = 1;
        % this meakes it so forage trials are correct 
    else
        Outcomes(x) = 3;

    end
end
BpodSystem.Data.SessionPerformance = Outcomes;
SaveBpodSessionData;
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes);
