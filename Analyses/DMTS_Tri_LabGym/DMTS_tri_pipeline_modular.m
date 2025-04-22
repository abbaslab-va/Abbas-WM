% Modular script for analyses of DMTS_tri behavior data.
% Lowell Bartlett  ***  7/10/2024

%% Initialize pipeline

% delayBins = {[0 3] [3.01 4] [4.01 5] [5.01 6] [6.01 7]};
delayBins = {[0 3], [3.0001 5] [5.0001 7.5]}; %Occasionally trials can be slightly over 7 for some reason
delayBinsDisc = [3 5 7];
% Create colormap to be used in figures

blueShades = brewermap(5, 'PuBu');
yellowShades = brewermap(6, 'YlOrBr');
behaviorColormap = brewermap(9, 'Set1');
behaviorColormap = ...
    [0 0 0;                  %     [NA - black
    behaviorColormap(2, :);  %     drink - blue
    behaviorColormap(6, :);  %     groom - black
    behaviorColormap(1, :);  %     left - red
    behaviorColormap(8, :);  %     poke - pink
    behaviorColormap(5, :);  %     rear - yellow
    behaviorColormap(9, :);  %     rest - grey
    behaviorColormap(3, :);  %     right - green
    behaviorColormap(7, :);  %     walk - brown
    ];
sampleColor = '#33DBFF';
delayColor = '#BD33FF';
leftColor = behaviorColormap(4, :);
rightColor = behaviorColormap(8, :);
zeroDelayColor = yellowShades(3, :);
shortDelayColor = yellowShades(4, :);
longDelayColor = yellowShades(5, :);
delayColors = {zeroDelayColor, shortDelayColor, longDelayColor};
% zeroDelayColor = blueShades(3, :);
% shortDelayColor = blueShades(4, :);
% longDelayColor = blueShades(5, :);
% Create class objects by filtering pre-organized data
[trainingSessions, testingSessions] = DMTS_tri_pipeline_init;

%% Make objects for both groups of mice based on turn to choice strat
variableTurningSubs = [1,2,4,5,6,8];
fixedTurningSubs = [3,7];
variableTurningTraining = trainingSessions(variableTurningSubs);
fixedTurningTraining = trainingSessions(fixedTurningSubs);
subNames = testingSessions.metadata.subjects;
variableTurningSubset = testingSessions.subset('animal', subNames(variableTurningSubs));
variableTurningTesting = ExpManager(BehDat(), []);
variableTurningTesting.copy(testingSessions);
variableTurningTesting.sessions = variableTurningTesting.sessions(variableTurningSubset);
variableTurningTesting.metadata.subjects = subNames(variableTurningSubs);
fixedTurningSubset = testingSessions.subset('animal', subNames(fixedTurningSubs));
fixedTurningTesting = ExpManager(BehDat(), []);
fixedTurningTesting.copy(testingSessions);
fixedTurningTesting.sessions = fixedTurningTesting.sessions(fixedTurningSubset);
fixedTurningTesting.metadata.subjects = subNames(fixedTurningSubs);
%% Training performance

trainingPerformance = DMTS_tri_training_performance(trainingSessions);
trainingPerformanceZero = DMTS_tri_training_performance(trainingSessions, 'delayLength', delayBins{1});
trainingPerformanceShort = DMTS_tri_training_performance(trainingSessions, 'delayLength', delayBins{2});
trainingPerformanceLong = DMTS_tri_training_performance(trainingSessions, 'delayLength', delayBins{3});


trainingPerfGroupFig = DMTS_tri_training_plot_group(trainingPerformance);
trainingPerfGroupFig = DMTS_tri_training_plot_group(trainingPerformanceZero);
trainingPerfGroupFig = DMTS_tri_training_plot_group(trainingPerformanceShort);
trainingPerfGroupFig = DMTS_tri_training_plot_group(trainingPerformanceLong);

%% Testing performance

testingPerformance = DMTS_tri_testing_performance(testingSessions);
animalPerfFig = DMTS_tri_testing_plot_individual(testingPerformance);
[sampleAnimalFig, sampleSessionFig] = DMTS_tri_testing_plot(testingPerformance.samplePort, sampleColor);
[delayAnimalFig, delaySessionFig] = DMTS_tri_testing_plot(testingPerformance.delayPort, delayColor);
[directionAnimalFig, directionSessionFig] = DMTS_tri_testing_plot(testingPerformance.directional, {leftColor rightColor});
[delayLengthAnimalFig, delayLengthSessionFig] = DMTS_tri_testing_plot(testingPerformance.delayLength, delayColors);

%% Combined performance

DMTS_tri_combined_performance(trainingPerformance, testingPerformance);

%% Training repeats and Early Withdrawals

trainingRepeats = DMTS_tri_training_repeats(trainingSessions, delayBins, false, delayColors);
trainingRepeatsTrialized = DMTS_tri_training_repeats(trainingSessions, delayBins, true, delayColors);


trainingRepeatsVariable = DMTS_tri_training_repeats(variableTurning, delayBins, true, delayColors);
trainingRepeatsFixed = DMTS_tri_training_repeats(fixedTurning, delayBins, true, delayColors);

trainingEW = DMTS_tri_training_early_withdrawals(trainingSessions, delayBins, false);
trainingEWTrialized = DMTS_tri_training_early_withdrawals(trainingSessions, delayBins, true);

%% Testing early withdrawals

testingEW = DMTS_tri_testing_early_withdrawals(testingSessions, delayBins, false);
testingEWTrialized = DMTS_tri_testing_early_withdrawals(testingSessions, delayBins, true);
DMTS_tri_combined_early_withdrawal(trainingEW, testingEW, delayColors)
DMTS_tri_combined_early_withdrawal(trainingEWTrialized, testingEWTrialized, delayColors)
%% Training bias (figure 4)

% perfBiasRelationship = DMTS_bias_through_training(trainingSessions, 'perf');
% sideBiasRelationship = DMTS_bias_through_training(trainingSessions, 'side', leftColor, rightColor);
% diffByTrainingEraPerfBias = DMTS_tri_training_decision_speed(trainingSessions, false, 'perf');
diffByTrainingEraSideBias = DMTS_tri_training_decision_speed(trainingSessions, false, 'side');
diffByTrainingEraSideBiasShortDelay = DMTS_tri_training_decision_speed(trainingSessions, false, 'side', [3 5]);
diffByTrainingEraSideBiasLongDelay = DMTS_tri_training_decision_speed(trainingSessions, false, 'side', [5.1 7]);
diffByTrainingEraSideBiasWarmupDelay = DMTS_tri_training_decision_speed(trainingSessions, false, 'side', [0 3]);
diffByTrainingEraVariable = DMTS_tri_training_decision_speed(variableTurningTraining, false, 'side');
diffByTrainingEraFixed = DMTS_tri_training_decision_speed(fixedTurningTraining, false, 'side');

%% Testing bias (figure 4)

% % left_vs_right_bias_diff(testingSessions, 'perf', leftColor, rightColor);
left_vs_right_bias_diff(testingSessions, 'side', leftColor, rightColor);
% % choiceDiffPerfBias = DMTS_tri_testing_decision_speed(testingSessions, 'perf');
choiceDiffSideBias = DMTS_tri_testing_decision_speed(testingSessions, 'side');
choiceDiffTestingVariable = DMTS_tri_testing_decision_speed(variableTurningTesting, 'side');
choiceDiffTestingFixed = DMTS_tri_testing_decision_speed(fixedTurningTesting, 'side');

choiceDiffSideBiasShortDelay = DMTS_tri_testing_decision_speed(testingSessions, 'side', [3 5]);
choiceDiffSideBiasLongDelay = DMTS_tri_testing_decision_speed(testingSessions, 'side', [5.1 7]);
choiceDiffSideBiasWarmupDelay = DMTS_tri_testing_decision_speed(testingSessions, 'side', [0 3]);
%% Combined bias

% DMTS_tri_combined_diff(diffByTrainingEraPerfBias, choiceDiffPerfBias)
DMTS_tri_combined_diff(diffByTrainingEraSideBias, choiceDiffSideBias)
DMTS_tri_combined_diff(diffByTrainingEraSideBiasWarmupDelay, choiceDiffSideBiasWarmupDelay)
DMTS_tri_combined_diff(diffByTrainingEraSideBiasShortDelay, choiceDiffSideBiasShortDelay)
DMTS_tri_combined_diff(diffByTrainingEraSideBiasLongDelay, choiceDiffSideBiasLongDelay)
DMTS_tri_combined_diff(diffByTrainingEraVariable, choiceDiffTestingVariable)
DMTS_tri_combined_diff(diffByTrainingEraFixed, choiceDiffTestingFixed)
%% Bias metric comparison

% trainingSideBias = DMTS_tri_training_side_bias(trainingSessions);
% trainingPerformanceBias = DMTS_tri_training_performance_bias(trainingSessions);
% compare_bias_metrics(trainingSideBias, trainingPerformanceBias);
%% Testing video (figure 3)

combined_behavior_and_position(testingSessions, 1)
combined_behavior_and_position(testingSessions, 2)
combined_behavior_and_position(testingSessions, 3)
combined_behavior_and_position(testingSessions, 7)

%% Training scan punish

DMTS_tri_training_scanning(trainingSessions)

%% Bias by delay

delayBiasTraining = DMTS_tri_training_bias_by_delay(trainingSessions, delayBins);
delayBiasTesting = DMTS_tri_testing_bias_by_delay(testingSessions, delayBins);
DMTS_tri_bias_by_delay_combined(delayBiasTraining, delayBiasTesting, delayColors)

%% Raw time to choice

trainingTimeToChoiceRaw = DMTS_tri_training_time_to_choice(trainingSessions, false, 'side');
testingTimeToChoiceRaw = DMTS_tri_testing_time_to_choice(testingSessions, false, 'side');

DMTS_tri_combined_raw_time_to_choice(trainingTimeToChoiceRaw, testingTimeToChoiceRaw)