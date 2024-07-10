% Modular script for analyses of DMTS_tri behavior data.
% Lowell Bartlett  ***  7/10/2024


%% Initialize pipeline
% Create class objects by filtering pre-organized data
[trainingParser, testingSessions] = DMTS_tri_pipeline_init;
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

%% Calculate training performance
eraFraction = 1/3;
numTrainingSessionsAll = cellfun(@(x) numel(x), trainingParser, 'uni', 0);
earlySessionsIdx = cellfun(@(x) round(1:x*eraFraction), ...
    numTrainingSessionsAll, 'uni', 0);
midSessionsIdx = cellfun(@(x) x(end) + 1:x(end) * 2, earlySessionsIdx, 'uni', 0);
lateSessionsIdx = cellfun(@(x, y) x(end) + 1:y, midSessionsIdx, numTrainingSessionsAll, 'uni', 0);
earlySessions = cellfun(@(x, y) x(y), trainingParser, earlySessionsIdx, 'uni', 0);
midSessions = cellfun(@(x, y) x(y), trainingParser, midSessionsIdx, 'uni', 0);
lateSessions = cellfun(@(x, y) x(y), trainingParser, lateSessionsIdx, 'uni', 0);
% DMTS_tri_training_performance