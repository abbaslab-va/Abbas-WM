

function CLAS_testing_OG

%%% 3/23 for males I took out the tup in chirp1 state. It now once again
%%% waites for a port out, I also added punish light and tine out of 5
%%% seconds.   changed trial time to 25 seconds 





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
    S.GUI.ForageReward = 1.5; %ul
    S.GUI.ChirpReward = 3; 
    S.GUI.ITI = 5; % How long the mouse must poke in the center to activate the goal portngjhg
    S.GUI.ResponseTime = 5; % How long until the mouse must make a choice, or forefeit the trial
    %S.GUI.SweepUpLow=10000;
    %S.GUI.SweepUpHigh=14000;
    S.GUI.SinePitch = 12000; % Frequency of test tone
    S.GUI.SoundDuration = 0.5;
    S.GUI.SamplingFreq = 44100;
    S.GUI.PunishTime=5;
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
    indices = randperm(16);
    block=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 ] ;
   % block=[10 10 10 10 10 10 10 10 14 14 14 14 14 12 14 14] ;
%    
    for shuffle=1:16
        pick(shuffle)=block(indices(shuffle));
    end     
    TrialTypes(fill*16-15:fill*16) = pick; 

end 
% indices2=randperm(18);
%     block=[7 8 9 10 11 12 7 8 9 10 11 12 7 8 9 10 11 12];
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
SF = S.GUI.SamplingFreq;
Chirp = GenerateSineWave(SF, S.GUI.SinePitch, S.GUI.SoundDuration)*0.5; % Sampling freq (hz), Sine frequency (hz), duration (s)
% Program sound server
T.load(1, Chirp);
analogPortIndex = find(strcmp(BpodSystem.Modules.Name, 'TeensyAudio1'));
if isempty(analogPortIndex)
    error('Error: Bpod TeensyAudio module not found. If you just plugged it in, please restart Bpod.')
end


%%% Set Noise in audacity to 0.03
%%% chirp 20to1= 0.3
%%%Chiro1to5 = 0.005
%%% 
 %%Chirp20to1=audioread('SNR_03102022_0.5s.wav');
 %%%Chirp20to1=audioread('newCHIRP_SNR20to1_4X_2SEC.wav');
 %%%Chirp1to1=audioread('newCHIRP_SNR1to1.wav');
 %%Noise=audioread('NOISE_03102022.wav');
%%% Noise1to5=audioread('Noise_1to5.wav');
 Silence=zeros(1,44100);
%%%% 
%%% 
%%%T.load(1, Noise);
%%%T.load(2, Chirp20to1);
T.load(2, Silence);
%%%T.load(4,  Chirp1to1);
%%%T.load(5,   Noise1to5);




%% Main trial loop

BpodSystem.SoftCodeHandlerFunction = 'CLAS_phase1_v2_FUN';
global visited

for currentTrial = 1:MaxTrials
    currentTrial
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
    %case 1:6 Chirp with laser ON
    case 1 
        PickDur=7
        PickDur2=2
        PickChirp=1
        LazerON={'BNC1',1}
        time1=2
        time2=1
        time3=1
        chirptrial='Abort'
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        rtime=1
      
    case 2
        PickDur=8
        PickDur2=3
     
        PickChirp=1
        LazerON={'BNC1',1}
        time1=2
        time2=1
        time3=1
        chirptrial='Abort'
        rtime=1
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        
   
    case 3
        PickDur=10
        PickDur2=5
  
        PickChirp=1
        LazerON={'BNC1',1}
        time1=2
        time2=1
        time3=1
        chirptrial='Abort'
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        rtime=1
      
      
    
    case 4
        PickDur=12
        PickDur2=4
       % PickNoise=1
        PickChirp=1
        LazerON={'BNC1',1}
        time1=2
        time2=1
        time3=1
        chirptrial='Abort'
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        rtime=1
      
      
    case 5 
        PickDur=7
        PickDur2=3
        %PickNoise=1
        PickChirp=1
        LazerON={'BNC1',1}
        time1=2
        time2=1
        time3=1
        chirptrial='Abort'
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        rtime=1
        
      
    case 6
        PickDur=8
        PickDur2=5
       % PickNoise=1
        PickChirp=1
        LazerON={'BNC1',1}
        time1=2
        time2=1
        time3=1
        chirptrial='Abort'
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        rtime=1
        
    
     
     
     % case 7:12 Chirp with laser OFF
    case 7
        PickDur= 7
        PickDur2=2
        %PickNoise=1
        PickChirp=1
        LazerON={}
        time1=2
        time2=1
        time3=1
        chirptrial='Abort'
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        rtime=1
        
    
    case 8
        PickDur=8
        PickDur2=3
       % PickNoise=1
        PickChirp=1
        LazerON={}
        time1=2
        time2=1
        time3=1
        chirptrial='Abort'
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        rtime=1
        
      
      
    case 9
        PickDur=10
        PickDur2=1
        %PickNoise=1
        PickChirp=1
        LazerON={}
        time1=2
        time2=1
        time3=1
        chirptrial='Abort'
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        rtime=1
      
    
    case 10
        PickDur=12
        PickDur2=5
        %PickNoise=1
        PickChirp=1
        LazerON={}
        time1=2
        time2=1
        time3=1
        chirptrial='Abort'
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        rtime=1
        
        
    case 11
        PickDur=7
        PickDur2=4
        %PickNoise=1
        PickChirp=1
        LazerON={}
        time1=2
        time2=1
        time3=1
        chirptrial='Abort'
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        rtime=1
      
            
    case 12
        PickDur=8
        %PickNoise=1
        PickChirp=1
        LazerON={}
        time1=2
        time2=1
        time3=1
        chirptrial='Abort'
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        rtime=1
      
    
       % Case 13 &14 NO CHIRP LASER ON 
    case 13
        PickDur=8
       % PickNoise=1
        PickChirp=2
        LazerON={'BNC1',1}
        time1=.1
        time2=.1
        time3=.1
        chirptrial='Reward'
        rewardtime1=0
        rtime=0
      

    case 14
        PickDur=10
       % PickNoise=1
        PickChirp=2
        LazerON={'BNC1',1}
        time1=0.1
        time2=0.1
        time3=.1
        chirptrial='Reward'
        rewardtime1=0
        rtime=0
        
   % case 15 and 16 No chirp LASER OFF      
    case 15
        PickDur=8
        %PickNoise=1
        PickChirp=2
        LazerON={}
        time1=.1
        time2=.1
        time3=.1
        chirptrial='Reward'
        rewardtime1=0
        rtime=0
       
    case 16
        PickDur=10
       % PickNoise=1
        PickChirp=2
        LazerON={}
        time1=.1
        time2=.1
        time3=.1
        chirptrial='Reward'
        rewardtime1=0
        rtime=0
      
        
         
end 
          
        sma = NewStateMachine(); % Initialize new state machine description
        
          sma=SetGlobalTimer(sma,'TimerID',1,'Duration',PickDur)
          sma=SetGlobalTimer(sma,'TimerID',2,'Duration',S.GUI.TrialTime)
        
               
%First Wire (65529) Stamps begining on Trial Start (Start of ITI)
        %First Wire (65529) Stamps begining on Trial Start (Start of ITI)
         sma = AddState(sma, 'Name', 'ITI', ...
            'Timer',S.GUI.ITI,...
            'StateChangeConditions', {'Tup','WaitForAPoke'},...
            'OutputActions',{'Wire1',1});
        %Added a tup for DOI
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
        
        %     
% sma = AddState(sma, 'Name', 'Prime1', ...
%     'Timer',GetValveTimes(S.GUI.ForageReward,1),...
%     'StateChangeConditions', {'Tup','Prime2'},...
%     'OutputActions',{'Valve1',1});
%     
% sma = AddState(sma, 'Name', 'Prime2', ...
%     'Timer',GetValveTimes(S.GUI.ForageReward,2),...
%     'StateChangeConditions', {'Tup','Prime3'},...
%     'OutputActions',{'Valve2',1});
% 
% sma = AddState(sma, 'Name', 'Prime3', ...
%    'Timer',GetValveTimes(S.GUI.ForageReward,3),...
%     'StateChangeConditions', {'Tup','Prime4'},...
%     'OutputActions',{'Valve3',1});
% 
% sma = AddState(sma, 'Name', 'Prime4', ...
%     'Timer',GetValveTimes(S.GUI.ForageReward,4),...
%     'StateChangeConditions', {'Tup','Prime5'},...
%     'OutputActions',{'Valve4',1});
% 
% sma = AddState(sma, 'Name', 'Prime5', ...
%     'Timer',GetValveTimes(S.GUI.ForageReward,5),...
%     'StateChangeConditions', {'Tup','WaitForFirstPoke'},...
%     'OutputActions',{'Valve5',1});



          sma = AddState(sma, 'Name', 'WaitForFirstPoke', ...
            'Timer',0,...
            'StateChangeConditions', {'Port1In','Port1InMark','Port2In','Port2InMark','Port3In','Port3InMark','Port4In','Port4InMark','Port5In','Port5InMark','GlobalTimer2_End','exit','GlobalTimer1_End','Chirp1'},...
            'OutputActions',{'PWM1', 20,'PWM2', 20,'PWM3', 20,'PWM4', 20,'PWM5', 20, 'PWM7', 20});
        
        
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
        
          
%         sma = AddState(sma, 'Name', 'Port6InMark', ...
%             'Timer',0,...
%             'StateChangeConditions', {'Tup','WaitForPoke','GlobalTimer2_End','exit'},...
%             'OutputActions',{'SoftCode',6});
% %         
        
 %Wire 1 & 2=65531= Reward Forage Port        

        sma = AddState(sma, 'Name', 'WaitForPoke', ...
            'Timer',0,...
            'StateChangeConditions', {'GlobalTimer1_End','Chirp1','SoftCode1', 'Reward1','SoftCode2', 'Reward2','SoftCode3', 'Reward3','SoftCode4', 'Reward4','SoftCode5', 'Reward5','GlobalTimer2_End','exit'},...
            'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});

        sma = AddState(sma, 'Name', 'Reward1', ...
                'Timer',0,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Port1In','Reward1_1','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});

        sma = AddState(sma, 'Name', 'Reward1_1', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,1),...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','DrinkGrace1','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'Valve1',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50,'Wire1',1,'Wire2',1});  

         sma = AddState(sma, 'Name', 'Reward2', ...
                'Timer',0,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Port2In','Reward2_1','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50,'PWM7', 50});


         sma = AddState(sma, 'Name', 'Reward2_1', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,2),...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','DrinkGrace2','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'Valve2',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50,'Wire1',1,'Wire2',1});



         sma = AddState(sma, 'Name', 'Reward3', ...
                'Timer',0,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Port3In','Reward3_1','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});


            sma = AddState(sma, 'Name', 'Reward3_1', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,3),...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','DrinkGrace3','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'Valve3',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50,'Wire1',1,'Wire2',1});




         sma = AddState(sma, 'Name', 'Reward4', ...
                'Timer',0,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Port4In','Reward4_1','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});


            sma = AddState(sma, 'Name', 'Reward4_1', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,4),...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','DrinkGrace4','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'Valve4',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50,'Wire1',1,'Wire2',1});
           

           sma = AddState(sma, 'Name', 'Reward5', ...
                'Timer',0,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Port5In','Reward5_1','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});


            sma = AddState(sma, 'Name', 'Reward5_1', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,5),...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','DrinkGrace5','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'Valve5',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50,'Wire1',1,'Wire2',1});
            
%                   sma = AddState(sma, 'Name', 'Reward6', ...
%                 'Timer',0,...
%                 'StateChangeConditions', {'Port7In','Reward6_1','GlobalTimer2_End','exit'},...
%                 'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});
% 
% 
%             sma = AddState(sma, 'Name', 'Reward6_1', ...
%                 'Timer',GetValveTimes(S.GUI.ForageReward,7),...
%                 'StateChangeConditions', {'Tup','DrinkGrace6','GlobalTimer2_End','exit'},...
%                 'OutputActions',{'Valve7',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});

        
            sma = AddState(sma, 'Name', 'DrinkGrace1', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','Port1InMark','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50}); 
            
              sma = AddState(sma, 'Name', 'DrinkGrace2', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','Port2InMark','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50}); 
              
            sma = AddState(sma, 'Name', 'DrinkGrace3', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','Port3InMark','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50}); 
              
            sma = AddState(sma, 'Name', 'DrinkGrace4', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','Port4InMark','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50}); 
            
            sma = AddState(sma, 'Name', 'DrinkGrace5', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'GlobalTimer1_End','Chirp1','Tup','Port5InMark','GlobalTimer2_End','exit','Port7In','Punish'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50}); 
            
%              sma = AddState(sma, 'Name', 'DrinkGrace6', ...
%                 'Timer',S.GUI.DrinkGrace,...
%                 'StateChangeConditions', {'Tup','Port6InMark','GlobalTimer2_End','exit'},...
%                 'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50}); 
            
            %'Port1In','PunishFrontVisit','Port2In','PunishFrontVisit','Port3In','PunishFrontVisit','Port4In','PunishFrontVisit','Port5In','PunishFrontVisit'
            
            %FOR DOI I HAVE TO ADD A STATE TIMER
             sma = AddState(sma, 'Name', 'Chirp1', ...
                'Timer',0,...
                'StateChangeConditions', {'Port1Out','Laser','Port2Out','Laser','Port3Out','Laser','Port4Out','Laser','Port5Out','Laser','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50 'PWM7', 50});
         
            

             sma = AddState(sma, 'Name', 'Laser', ...
                'Timer',0.5,...
                'StateChangeConditions', {'Tup','Buffer','GlobalTimer2_End','exit'},...
                'OutputActions',[LazerON,'Wire2',1,'Wire3',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50]);
            
            sma = AddState(sma, 'Name', 'Buffer', ...
                'Timer',0,...
                'StateChangeConditions', {'Tup','ChirpPlay','GlobalTimer2_End','exit'},...
                'OutputActions',[LazerON,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50]);

% % % Wire 2 denotes the Playing of the Chirp (65530)   

             sma = AddState(sma, 'Name', 'ChirpPlay', ...
                'Timer',0.5,...
                'StateChangeConditions', {'Tup','Laser2','GlobalTimer2_End','exit','Port7In','Reward'},...
                'OutputActions',['TeensyAudio1',PickChirp,LazerON,'Wire2',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50]);
            
             sma = AddState(sma, 'Name', 'Laser2', ...
                'Timer',0.5,...
                'StateChangeConditions', {'Tup','WaitForChirp1','Port7In','Reward','GlobalTimer2_End','exit'},...
                'OutputActions',[LazerON,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50]);
            
             
             sma = AddState(sma, 'Name', 'WaitForChirp1', ...
               'Timer',time1,...
                'StateChangeConditions', {'Tup','WaitForChirp2','Port7In','Reward','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});          
              
            
            sma = AddState(sma, 'Name', 'WaitForChirp2', ...
               'Timer',time2,...
                'StateChangeConditions', {'Tup',chirptrial,'Port7In','Reward','GlobalTimer2_End','exit', PortIn, 'ExtraFrontIn'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});          
             
            sma = AddState(sma, 'Name', 'ExtraFrontIn', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,Port),...
                'StateChangeConditions', {'Tup','ExtraFrontGrace','GlobalTimer2_End','exit'},...
                'OutputActions',{Valve,1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50,'Wire1',1,'Wire2',1});
            
            
             sma = AddState(sma, 'Name', 'ExtraFrontGrace', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'Tup','WaitForChirp3','GlobalTimer2_End','exit','Port7In','Reward'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50}); 
            
           
            
             sma = AddState(sma, 'Name', 'WaitForChirp3', ...
               'Timer',time3,...
                'StateChangeConditions', {'Tup',chirptrial,'Port7In','Reward','GlobalTimer2_End','exit', PortIn2,'ExtraFrontIn2'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});    
            
             sma = AddState(sma, 'Name', 'ExtraFrontIn2', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,Port2),...
                'StateChangeConditions', {'Tup','ExtraFrontGrace2','GlobalTimer2_End','exit'},...
                'OutputActions',{Valve2,1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50,'Wire1',1,'Wire2',1});
            
             sma = AddState(sma, 'Name', 'ExtraFrontGrace2', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'Tup','Abort','GlobalTimer2_End','exit','Port7In','Reward'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50}); 
            
% % % Wire 3 denotes the Reward Back Port(65532)                       
%         
            sma = AddState(sma, 'Name', 'Reward', ...
                'Timer',rewardtime1,...
                'StateChangeConditions', {'Tup','DrinkGrace7','GlobalTimer2_End','exit'},...
                'OutputActions',{'Valve7',1,'Wire3',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});
%             
             sma = AddState(sma, 'Name', 'DrinkGrace7', ...
                'Timer',rtime,...
                'StateChangeConditions', {'Tup','WaitForFirstPoke','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});

% % CAN I HAVE A WIRE FOR ABORT??             
             sma = AddState(sma, 'Name', 'Abort', ...
                'Timer',0,...
                'StateChangeConditions', {'Tup','exit'},...
                'OutputActions',{});
% %Wire 1 and 3 (65533) denoting Wrong Back port visit.                
%                
            sma = AddState(sma, 'Name', 'Punish', ...
                'Timer',S.GUI.PunishTime,...
                'StateChangeConditions', {'Tup','exit','GlobalTimer2_End','exit'},...
                'OutputActions',{'Wire1',1,'Wire3',1,'Valve6',1});



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
            
            
%           if currentTrial > 30
%             LocalOutcomes = zeros(1,10);
%             fillno = 0;
%             for x = currentTrial-9:currentTrial
%                 fillno = fillno+1;
%                 if ~isnan(BpodSystem.Data.RawEvents.Trial{x}.States.Abort(1))
%                     LocalOutcomes(x) = 3;
%                 else
%                     LocalOutcomes(x)=1;
%                 end
%             end
%             if numel(find(LocalOutcomes==3))>=5
%                 break
%             end
%          end 

    
        
end



function UpdateTrialTypeOutcomePlot(TrialTypes, Data)
% Determine outcomes from state data and score as the TrialTypeOutcomePlot
% plugin expects
global BpodSystem
Outcomes = zeros(1,Data.nTrials);
for x = 1:Data.nTrials
    
        
   
    
    if ~isnan(Data.RawEvents.Trial{x}.States.Punish(1)) & ~isnan(Data.RawEvents.Trial{x}.States.Reward(1))
        Outcomes(x) = 1;
        
    elseif ~isnan(Data.RawEvents.Trial{x}.States.Abort(1))
        Outcomes(x) = 3;
    
    elseif ~isnan(Data.RawEvents.Trial{x}.States.Reward(1))
        Outcomes(x) = 1;
        
    elseif ~isnan(Data.RawEvents.Trial{x}.States.Punish(1))
        Outcomes(x) = 0;
    elseif  ~isnan(Data.RawEvents.Trial{x}.States.Punish(1))& Data.TrialTypes(currentTrial)<12
        Outcomes(x) =1;
    else
        Outcomes(x) = 3;
    end
end
BpodSystem.Data.SessionPerformance = Outcomes;
SaveBpodSessionData;
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes);
