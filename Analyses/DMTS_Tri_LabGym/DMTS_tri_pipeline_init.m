function [trainingSessions, testingSessions] = DMTS_tri_pipeline_init()
% Initializes the pipeline for DMTS_tri behavior paper
% Returns a BpodParser array for training and an ExpManager for testing.
% Data has already been collected by CompileLocalData and make_LabGym_ExpManager

minThresh = 65;     % Minimum percent performance threshold
I = INI;
I.read('F:\LabGym\DMTS_Tri\matlab\config.ini');
load("F:\LabGym\DMTS_Tri\matlab\labGymSessions.mat", "labGymSessions")
load("F:\LabGym\DMTS_Tri\matlab\BehaviorDataModified.mat", "BehaviorData")
taskName = 'DMTS_Tri_Training2';
subNamesUnfiltered = labGymSessions.metadata.subjects;
subSessions = cellfun(@(x) labGymSessions.subset('animal', x), subNamesUnfiltered, 'uni', 0);
% Calculate performance in testing and identify animals with at least 3
% sessions above the minimum threshold
[testingNumTT, testingNumCorrect] = arrayfun(@(x) ...
    x.outcomes, labGymSessions.sessions, 'uni', 0);
testingPercentCorrect = cellfun(@(x, y) ...
    100*sum(x)/sum(y), testingNumCorrect, testingNumTT);
goodSessionsAnimals = cellfun(@(x) ...
    testingPercentCorrect(x) > minThresh, subSessions, 'uni', 0);
goodAnimals = cellfun(@(x) ...
    numel(find(x)) >= 3, goodSessionsAnimals);
badSessions = cellfun(@(x) ...
    false(1, numel(x)), goodSessionsAnimals(~goodAnimals), 'uni', 0);
goodSessionsAnimals(~goodAnimals) = badSessions;
goodSessionsAll = cat(2, goodSessionsAnimals{:});
% Trim testing sessions
testingSessions = labGymSessions;
testingDates = arrayfun(@(x) ...
    datetime(x.bpod.session.Info.SessionDate), labGymSessions.sessions);
testingDatesByAnimal = cellfun(@(x) ...
    testingDates(x), subSessions, 'uni', 0);
testingDatesByAnimal = testingDatesByAnimal(goodAnimals);
testingSessions.sessions = testingSessions.sessions(goodSessionsAll);
testingSessions.metadata.subjects = subNamesUnfiltered(goodAnimals);
% Get training sessions from filtered animals and make BpodParser arrays
trainingSessions = make_BpodParser_training_array(BehaviorData, taskName, I);
trainingSessions = trainingSessions(goodAnimals);
trainingDates = cellfun(@(x) arrayfun(@(y) ...
    datetime(y.session.Info.SessionDate), x), ...
    trainingSessions, 'uni', 0);
% Remove sessions from training data that were recorded for testing
duplicateSessions = cellfun(@(x, y) ...
    ismember(x, y), trainingDates, testingDatesByAnimal', 'uni', 0);
firstTestingSession = cellfun(@(x) ...
    find(x, 1, 'first') - 1, duplicateSessions, 'uni', 0);
trainingSessions = cellfun(@(x, y) x(1:y), ...
    trainingSessions, firstTestingSession, 'uni', 0);