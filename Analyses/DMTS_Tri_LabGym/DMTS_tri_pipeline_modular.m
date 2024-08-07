% Modular script for analyses of DMTS_tri behavior data.
% Lowell Bartlett  ***  7/10/2024

%% Initialize pipeline

% Create colormap to be used in figures
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
% Create class objects by filtering pre-organized data
[trainingSessions, testingSessions] = DMTS_tri_pipeline_init;
%% Training performance

trainingPerformance = DMTS_tri_training_performance(trainingSessions);

trainingPerfGroupFig = DMTS_tri_training_plot_group(trainingPerformance);

%% Testing performance

testingPerformance = DMTS_tri_testing_performance(testingSessions);

animalPerfFig = DMTS_tri_testing_plot_individual(testingPerformance);
[sampleAnimalFig, sampleSessionFig] = DMTS_tri_testing_plot(testingPerformance.samplePort, sampleColor);
[delayAnimalFig, delaySessionFig] = DMTS_tri_testing_plot(testingPerformance.delayPort, delayColor);
[directionAnimalFig, directionSessionFig] = DMTS_tri_testing_plot(testingPerformance.directional, {leftColor rightColor});
[delayLengthAnimalFig, delayLengthSessionFig] = DMTS_tri_testing_plot(testingPerformance.delayLength, 'k');

%% Combined performance

DMTS_tri_combined_performance(trainingPerformance, testingPerformance);

%% Training repeats

trainingRepeats = DMTS_tri_training_repeats(trainingSessions);

%% Training bias

perfBiasRelationship = DMTS_bias_through_training(trainingSessions, 'perf');
sideBiasRelationship = DMTS_bias_through_training(trainingSessions, 'side');
diffByTrainingEraPerfBias = DMTS_tri_training_decision_speed(trainingSessions, false, 'perf');
diffByTrainingEraSideBias = DMTS_tri_training_decision_speed(trainingSessions, false, 'side');

%% Testing bias

left_vs_right_bias_diff(testingSessions, 'perf', leftColor, rightColor);
left_vs_right_bias_diff(testingSessions, 'side', leftColor, rightColor);
choiceDiffPerfBias = DMTS_tri_testing_decision_speed(testingSessions, 'perf');
choiceDiffSideBias = DMTS_tri_testing_decision_speed(testingSessions, 'side');
%% Combined bias

DMTS_tri_combined_diff(diffByTrainingEraPerfBias, choiceDiffPerfBias)
DMTS_tri_combined_diff(diffByTrainingEraSideBias, choiceDiffSideBias)
%% Bias metric comparison

trainingSideBias = DMTS_tri_training_side_bias(trainingSessions);
trainingPerformanceBias = DMTS_tri_training_performance_bias(trainingSessions);
compare_bias_metrics(trainingSideBias, trainingPerformanceBias);
%% Testing video
for subNo = 1:8
    combined_behavior_and_position(testingSessions, subNo)
end
% combined_behavior_and_position(testingSessions, 1)
% combined_behavior_and_position(testingSessions, 7)filteredSessions([17, 29]) = [];
