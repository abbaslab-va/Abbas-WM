
trainingNumTrials = cellfun(@(x) ...
    arrayfun(@(y) y.session.nTrials, x), ...
    trainingSessions, 'uni', 0);
trainingNumTrials = align_training_data(trainingSessions, trainingNumTrials);
ewTrainingMeanAll = mean(trainingEWData, 2, 'omitnan');
ewTrainingMeanTrialized = mean(trainingEWDataTrialized, 2, 'omitnan');
ewTrainingIntensity = mean(trainingEWData./trainingEWDataTrialized, 2, 'omitnan');
ewTrainingTrialRatio = mean(trainingEWDataTrialized./trainingNumTrials, 2, 'omitnan');
figure
bubblechart(1:numel(ewTrainingMeanTrialized), ewTrainingMeanTrialized, ewTrainingIntensity)
figure
bubblechart(1:numel(ewTrainingMeanTrialized), ewTrainingMeanTrialized, ewTrainingTrialRatio)

testingNumTrials = arrayfun(@(x) x.bpod.session.nTrials, testingSessions.sessions);
ewTestingAll
ewTestingTrialized
ewTestingIntensity
ewTestingTrialRatio