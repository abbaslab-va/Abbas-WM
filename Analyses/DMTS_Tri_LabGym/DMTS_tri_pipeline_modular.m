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

% trainingSideBias = DMTS_tri_training_side_bias(trainingSessions);
% trainingPerformanceBias = DMTS_tri_training_performance_bias(trainingSessions);
diffByTrainingEra = DMTS_tri_training_decision_speed(trainingSessions);


%% Testing bias

testingSideBias = DMTS_tri_testing_side_bias(testingSessions);
choiceDiff = DMTS_tri_testing_decision_speed(testingSessions);

%% Combined bias

DMTS_tri_combined_diff(diffByTrainingEra, choiceDiff)

%% Testing video