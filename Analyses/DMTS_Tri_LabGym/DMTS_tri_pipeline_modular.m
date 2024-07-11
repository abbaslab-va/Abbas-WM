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
leftColor = behaviorColormap(4, :);
rightColor = behaviorColormap(8, :);
% Create class objects by filtering pre-organized data
[trainingParser, testingSessions] = DMTS_tri_pipeline_init;
%% Training performance

trainingPerformance = DMTS_tri_training_performance(trainingParser);

%% Testing Performance
[performanceByAnimal, performanceBySession] = DMTS_tri_testing_performance(testingSessions);

