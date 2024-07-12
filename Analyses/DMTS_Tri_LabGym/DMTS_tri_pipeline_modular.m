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

DMTS_tri_training_plot(trainingPerformance);
%% Testing Performance

testingPerformance = DMTS_tri_testing_performance(testingSessions);

[sampleAnimalFig, sampleSessionFig] = DMTS_tri_testing_plot(testingPerformance.samplePort, sampleColor);
[delayAnimalFig, delaySessionFig] = DMTS_tri_testing_plot(testingPerformance.delayPort, delayColor);
[directionAnimalFig, directionSessionFig] = DMTS_tri_testing_plot(testingPerformance.directional, {leftColor rightColor});
[delayLengthAnimalFig, delayLengthSessionFig] = DMTS_tri_testing_plot(testingPerformance.delayLength, 'k');
