function dummy_script


%%Template script -- used to build new bpod behavior scripts

global BpodSystem


S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.ITI = 1;     
    S.GUI.SamplingFreq = 44100; %Sampling rate of wave player module (using max supported frequency)
    S.GUI.SoundDuration = .25; % Duration of sound (s)
    S.GUI.SinePitch = 14000; % Frequency of test tone
end

%% Define trials
numTrialTypes = 1;
MaxTrials = numTrialTypes*100;
TrialTypes = zeros(1, MaxTrials);
for fill = 1:MaxTrials/numTrialTypes
    block = randperm(numTrialTypes);
    TrialTypes(fill*1:fill*numTrialTypes) = block;
end
BpodSystem.Data.TrialTypes = []; 

%% Initialize plots
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [50 340 1000 400],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.TrialTypeOutcomePlot = axes('Position', [.075 .3 .89 .6]);
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'init',TrialTypes);
BpodNotebook('init');
BpodParameterGUI('init', S); % Initialize parameter GUI plugin

%% Test analog output module

if (isfield(BpodSystem.ModuleUSB, 'AudioPlayer1'))
    AudioPlayerUSB = BpodSystem.ModuleUSB.AudioPlayer1;
else
    error('Error: To run this protocol, you must first pair the AudioPlayer1 module with its USB port. Click the USB config button on the Bpod console.')
end
A = BpodAudioPlayer(AudioPlayerUSB);
% SF = S.GUI.SamplingFreq;
SF = A.Info.maxSamplingRate; % Use max supported sampling rate

SampleTone = GenerateSineWave(SF, S.GUI.SinePitch, S.GUI.SoundDuration)*.6; % Sampling freq (hz), Sine frequency (hz), duration (s)
% A.SamplingRate = SF;
A.BpodEvents = 'On';
A.TriggerMode = 'Master';
A.loadSound(1, SampleTone);
% Set Bpod serial message library with correct codes to trigger sounds 1-4 on analog output channels 1-2
analogPortIndex = find(strcmp(BpodSystem.Modules.Name, 'AudioPlayer1'));
if isempty(analogPortIndex)
    error('Error: Bpod AudioPlayer module not found. If you just plugged it in, please restart Bpod.')
end
LoadSerialMessages('AudioPlayer1', {['P' 0], ['P' 1], ['P' 2], ['P' 3]});

%% Main trial loop
for currentTrial = 1:MaxTrials
    
    S = BpodParameterGUI('sync', S);

    switch TrialTypes(currentTrial)
        case 1
           
    end
   
    sma = NewStateMatrix(); % Assemble state matrix
    
    %Waiting for first choice, sample start (needs valve calibration)
    
    sma = AddState(sma, 'Name', 'ITI', 'Timer', S.GUI.ITI,...
        'StateChangeConditions', {'Tup', 'PlaySound'},...
        'OutputActions', {});

    sma = AddState(sma, 'Name', 'PlaySound', 'Timer', S.GUI.SoundDuration,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'AudioPlayer1', 1});
    
    SendStateMatrix(sma);
    
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial);
        BpodSystem.Data.GuiVals(currentTrial) = S.GUI;
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
    
    if ~isnan(Data.RawEvents.Trial{x}.States.ITI(1))
        Outcomes(x) = 1;
    end
end
BpodSystem.Data.SessionPerformance = Outcomes;
SaveBpodSessionData;
TrialTypeOutcomePlot(BpodSystem.GUIHandles.TrialTypeOutcomePlot,'update',Data.nTrials+1,TrialTypes,Outcomes);
        
    
    
 