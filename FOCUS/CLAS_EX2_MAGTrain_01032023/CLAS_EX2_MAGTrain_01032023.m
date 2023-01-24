

function CLAS_EX2_MAGTrain_01032023

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
    S.GUI.ChirpReward = 6; 
    S.GUI.ITI = 10; % How long the mouse must poke in the center to activate the goal port
    S.GUI.ResponseTime = 5; % How long until the mouse must make a choice, or forefeit the trial
    S.GUI.SweepUpLow=10000;
    S.GUI.SweepUpHigh=14000;
    S.GUI.SoundDuration = 1;
    S.GUI.SamplingFreq = 44100;
    S.GUI.PunishTime=5;
    S.GUI.PuffTime=0.25; 
    S.GUI.DrinkGrace=1.5;
    S.GUI.TrialTime=60;
 
    
end
%%
% if (isfield(BpodSystem.ModuleUSB, 'TeensyAudio1'))
%     TeensyAudioUSB = BpodSystem.ModuleUSB.TeensyAudio1;
% else
%     error('Error: To run this protocol, you must first pair the TeensyAudio1 module with its USB port. Click the USB config button on the Bpod console.')
% end


%% Define trials
MaxTrials = 200;
TrialTypes = zeros(1, 100);
for fill = 1:100
    indices = randperm(8);
    block=[1 1 1 1 1 1 1 1] ;
   
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
% T = TeensyAudioPlayer(TeensyAudioUSB);
%LoadSerialMessages('ValveModule1',{['O' 3],['C' 3]})
%% Define stimuli and send to Teensy
% SF = S.GUI.SamplingFreq;
% t = linspace(0, S.GUI.SoundDuration, S.GUI.SoundDuration*S.GUI.SamplingFreq);
% UpSweep = chirp(t, S.GUI.SweepUpLow, t(end), S.GUI.SweepUpHigh);



% 
% Chirp20to1=audioread('ChirpSNR20to1.wav');
% Noise20to1=audioread('NoiseSNR20to1.wav');
% Silence=zeros(1,44100);
% 
% 
% T.load(1, Noise20to1);
% T.load(2, Chirp20to1);
% T.load(3, Silence);
% 
% 
% analogPortIndex = find(strcmp(BpodSystem.Modules.Name, 'TeensyAudio1'));
% if isempty(analogPortIndex)
%     error('Error: Bpod TeensyAudio module not found. If you just plugged it in, please restart Bpod.')
% end

%% Main trial loop

BpodSystem.SoftCodeHandlerFunction = 'CLAS_EX2_MAGTrain_01032023_FUN';
global visited

for currentTrial = 1:MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
BpodSystem.Data.PortsVisited= zeros(1,6);

visited=zeros(1,6);

          
        sma = NewStateMachine(); % Initialize new state machine description
        
          %sma=SetGlobalTimer(sma,'TimerID',1,'Duration',PickDur)
          sma=SetGlobalTimer(sma,'TimerID',2,'Duration',S.GUI.TrialTime)
               

         sma = AddState(sma, 'Name', 'ITI', ...
            'Timer',S.GUI.ITI,...
            'StateChangeConditions', {'Tup','Prime','GlobalTimer2_End','exit'},...
            'OutputActions',{'GlobalTimerTrig',2});
                    
%% For First Day only 
        sma = AddState(sma, 'Name', 'Prime', ...
            'Timer',0,...
            'StateChangeConditions', {'Tup','Dispense'},...
            'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50 'PWM7', 50});
        
        
        sma = AddState(sma, 'Name', 'Dispense', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,1),...
                'StateChangeConditions', {'Tup','WaitForFirstPoke','GlobalTimer2_End','exit'},...
                'OutputActions',{'Valve1',1,'Valve2',1,'Valve3',1,'Valve4',1,'Valve5',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50 'PWM7', 50});  
        
        sma = AddState(sma, 'Name', 'WaitForFirstPoke', ...
            'Timer',0,...
            'StateChangeConditions', {'Port1In','Port1InMark','Port2In','Port2InMark','Port3In','Port3InMark','Port4In','Port4InMark','Port5In','Port5InMark','GlobalTimer2_End','exit'},...
            'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50 'PWM7', 50});     
            
   
         sma = AddState(sma, 'Name', 'Port1InMark', ...
            'Timer',0,...
            'StateChangeConditions', {'Tup','WaitForPoke','GlobalTimer2_End','exit'},...
            'OutputActions',{'SoftCode',1});
        
        
        sma = AddState(sma, 'Name', 'Port2InMark', ...
            'Timer',0,...
            'StateChangeConditions', {'Tup','WaitForPoke','GlobalTimer2_End','exit'},...
            'OutputActions',{'SoftCode',2});
        
        
        sma = AddState(sma, 'Name', 'Port3InMark', ...
            'Timer',0,...
            'StateChangeConditions', {'Tup','WaitForPoke','GlobalTimer2_End','exit'},...
            'OutputActions',{'SoftCode',3});
        
      
        
        sma = AddState(sma, 'Name', 'Port4InMark', ...
            'Timer',0,...
            'StateChangeConditions', {'Tup','WaitForPoke','GlobalTimer2_End','exit'},...
            'OutputActions',{'SoftCode',4});
        
   
        
        sma = AddState(sma, 'Name', 'Port5InMark', ...
            'Timer',0,...
            'StateChangeConditions', {'Tup','WaitForPoke','GlobalTimer2_End','exit'},...
            'OutputActions',{'SoftCode',5});
             
        

        sma = AddState(sma, 'Name', 'WaitForPoke', ...
            'Timer',0,...
            'StateChangeConditions', {'SoftCode1', 'Reward1','SoftCode2', 'Reward2','SoftCode3', 'Reward3','SoftCode4', 'Reward4','SoftCode5', 'Reward5','GlobalTimer2_End','exit'},...
            'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});

        sma = AddState(sma, 'Name', 'Reward1', ...
                'Timer',0,...
                'StateChangeConditions', {'Port1In','Reward1_1','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});
            
         
         sma = AddState(sma, 'Name', 'Reward1_1', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,1),...
                'StateChangeConditions', {'Tup','DrinkGrace1','GlobalTimer2_End','exit'},...
                'OutputActions',{'Valve1',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50 'PWM7', 50});


         sma = AddState(sma, 'Name', 'Reward2', ...
                'Timer',0,...
                'StateChangeConditions', {'Port2In','Reward2_1','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50,'PWM7', 50});


         sma = AddState(sma, 'Name', 'Reward2_1', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,2),...
                'StateChangeConditions', {'Tup','DrinkGrace2','GlobalTimer2_End','exit'},...
                'OutputActions',{'Valve2',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50. 'PWM7', 50});



         sma = AddState(sma, 'Name', 'Reward3', ...
                'Timer',0,...
                'StateChangeConditions', {'Port3In','Reward3_1','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50. 'PWM7', 50});


            sma = AddState(sma, 'Name', 'Reward3_1', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,3),...
                'StateChangeConditions', {'Tup','DrinkGrace3','GlobalTimer2_End','exit'},...
                'OutputActions',{'Valve3',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});


         sma = AddState(sma, 'Name', 'Reward4', ...
                'Timer',0,...
                'StateChangeConditions', {'Port4In','Reward4_1','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});


            sma = AddState(sma, 'Name', 'Reward4_1', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,4),...
                'StateChangeConditions', {'Tup','DrinkGrace4','GlobalTimer2_End','exit'},...
                'OutputActions',{'Valve4',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});
           

           sma = AddState(sma, 'Name', 'Reward5', ...
                'Timer',0,...
                'StateChangeConditions', {'Port5In','Reward5_1','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50 'PWM7', 50});


            sma = AddState(sma, 'Name', 'Reward5_1', ...
                'Timer',GetValveTimes(S.GUI.ForageReward,5),...
                'StateChangeConditions', {'Tup','DrinkGrace5','GlobalTimer2_End','exit'},...
                'OutputActions',{'Valve5',1,'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50});
            
      
        
            sma = AddState(sma, 'Name', 'DrinkGrace1', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'Port1Out','Port1InMark','Tup','Port1InMark','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50}); 
            
              sma = AddState(sma, 'Name', 'DrinkGrace2', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'Port2Out','Port2InMark','Tup','Port2InMark','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50}); 
              
            sma = AddState(sma, 'Name', 'DrinkGrace3', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'Port3Out','Port3InMark','Tup','Port3InMark','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50}); 
              
            sma = AddState(sma, 'Name', 'DrinkGrace4', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'Port4Out','Port4InMark','Tup','Port4InMark','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50}); 
            
            sma = AddState(sma, 'Name', 'DrinkGrace5', ...
                'Timer',S.GUI.DrinkGrace,...
                'StateChangeConditions', {'Port5Out','Port5InMark','Tup','Port5InMark','GlobalTimer2_End','exit'},...
                'OutputActions',{'PWM1', 50,'PWM2', 50,'PWM3', 50,'PWM4', 50,'PWM5', 50, 'PWM7', 50}); 

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
   try
    if ~isnan(Data.RawEvents.Trial{x}.States.PunishBackVisit(1))
        Outcomes(x) = 0;
        
    elseif ~isnan(Data.RawEvents.Trial{x}.States.TimedOut(1))  
        Outcomes(x) = 3;
    else 
        Outcomes(x)= 1;
    end
   catch
   end
end
BpodSystem.Data.SessionPerformance = Outcomes;
SaveBpodSessionData;
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes);
