

function CLAS_training_OG_1

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
    S.GUI.ChirpReward = 5; 
    S.GUI.ITI = 3; % How long the mouse must poke in the center to activate the goal portngjhg
    S.GUI.ResponseTime = 5; % How long until the mouse must make a choice, or forefeit the trial
    %S.GUI.SweepUpLow=10000;
    %S.GUI.SweepUpHigh=14000;
    S.GUI.SinePitch = 10000; % Frequency of test tone
    S.GUI.SoundDuration = 0.5;
    S.GUI.SamplingFreq = 44100;
    S.GUI.PunishTime=1;
    S.GUI.PuffTime=0.25; 
    S.GUI.DrinkGrace=0.5;
    S.GUI.TrialTime=20;
 
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
    block=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16] ;
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

switch TrialTypes(currentTrial)
    %case 1:6 Chirp with laser ON
    case 1 
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1;
        PickDur=3;
        
      case 2 
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1;
        PickDur=3;
        
       case 3 
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1;
        PickDur=7;
        
       case 4 
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1;
            PickDur=7;
         case 5 
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1;
            PickDur=10;
        
           case 6 
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1;
            PickDur=10;
        
          case 7 
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1;
            PickDur=4;
        
           case 8 
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1;
            PickDur=4;
        
           case 9 
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1;
            PickDur=2;
        
           case 10 
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1;
        PickDur=2;
             case 11 
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1;
        PickDur=2;
             case 12 
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1;
        PickDur=3;
             case 13 
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1;
        PickDur=7;
             case 14 
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1;
        PickDur=10;
             case 15 
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1;
        PickDur=10;
             case 16
        rewardtime1=GetValveTimes(S.GUI.ChirpReward,7)
        PickChirp=1
        PickDur=4;
      
end 
          
        sma = NewStateMachine(); % Initialize new state machine description
         sma=SetGlobalTimer(sma,'TimerID',1,'Duration',PickDur)
          sma=SetGlobalTimer(sma,'TimerID',2,'Duration',S.GUI.TrialTime)

        
               
%First Wire (65529) Stamps begining on Trial Start (Start of ITI)
         sma = AddState(sma, 'Name', 'ITI', ...
            'Timer',S.GUI.ITI,...
            'StateChangeConditions', {'Tup','TriggerTimers1'},...
            'OutputActions',{});
        
        
           sma = AddState(sma, 'Name', 'TriggerTimers1', ...
            'Timer',0,...
            'StateChangeConditions', {'Tup','TriggerTimers2'},...
            'OutputActions',{'GlobalTimerTrig',2});
        
        sma = AddState(sma, 'Name', 'TriggerTimers2', ...
            'Timer',0,...
            'StateChangeConditions', {'Tup','AllLights'},...
            'OutputActions',{'GlobalTimerTrig',1});
        
         sma = AddState(sma, 'Name', 'AllLights', ...
            'Timer',0,...
            'StateChangeConditions', {'GlobalTimer1_End','ChirpPlay'},...
            'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});
            
                 
        
         sma = AddState(sma, 'Name', 'ChirpPlay', ...
                'Timer',0.5,...
                'StateChangeConditions', {'Tup','WaitForBackPoke'},...
                'OutputActions',{'TeensyAudio1',PickChirp,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});
            
            
        
        
         sma = AddState(sma, 'Name', 'WaitForBackPoke', ...
            'Timer',3,...
            'StateChangeConditions', {'Port7In','Reward','Tup','Abort'},...
            'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});
        

% % % Wire 3 denotes the Reward Back Port(65532)                       
%         
            sma = AddState(sma, 'Name', 'Reward', ...
                'Timer',rewardtime1,...
                'StateChangeConditions', {'Tup','WaitForEnd'},...
                'OutputActions',{'Valve7',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});
            
            sma = AddState(sma, 'Name', 'Abort', ...
                'Timer',0,...
                'StateChangeConditions', {'Tup','WaitForEnd'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});
            
            
                    %    
    sma = AddState(sma, 'Name', 'WaitForEnd', ...
            'Timer',0,...
            'StateChangeConditions', {'GlobalTimer2_End','exit'},...
            'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});
            
%             
%             
          
%


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

    if ~isnan(Data.RawEvents.Trial{x}.States.Reward(1))
        Outcomes(x) = 1;
        
    else 
        Outcomes(x) =0;
    end
end
BpodSystem.Data.SessionPerformance = Outcomes;
SaveBpodSessionData;
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes);
