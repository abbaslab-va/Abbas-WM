function performanceSessions = DMTS_tri_training_performance(parserArray, varargin)

% Divides a bpod parser array into 3 eras and returns means and sem
    presets = PresetManager(varargin{:});
    eraFraction = 1/3;
    numTrainingSessionsAll = cellfun(@(x) numel(x), parserArray, 'uni', 0);
    earlySessionsIdx = cellfun(@(x) round(1:x*eraFraction), ...
        numTrainingSessionsAll, 'uni', 0);
    midSessionsIdx = cellfun(@(x) x(end) + 1:x(end) * 2, earlySessionsIdx, 'uni', 0);
    lateSessionsIdx = cellfun(@(x, y) x(end) + 1:y, midSessionsIdx, numTrainingSessionsAll, 'uni', 0);
    earlySessions = cellfun(@(x, y) x(y), parserArray, earlySessionsIdx, 'uni', 0);
    midSessions = cellfun(@(x, y) x(y), parserArray, midSessionsIdx, 'uni', 0);
    lateSessions = cellfun(@(x, y) x(y), parserArray, lateSessionsIdx, 'uni', 0);
    earlyPerformance = cellfun(@(x) percent_correct(x, presets), earlySessions, 'uni', 0);
    midPerformance = cellfun(@(x) percent_correct(x, presets), midSessions, 'uni', 0);
    latePerformance = cellfun(@(x) percent_correct(x, presets), lateSessions, 'uni', 0);
    earlyMean = mean(cellfun(@(x) mean(x), earlyPerformance)) * 100;
    earlySEM = mean(cellfun(@(x) std(x)/sqrt(numel(x)), earlyPerformance)) * 100;
    midMean = mean(cellfun(@(x) mean(x), midPerformance)) * 100;
    midSEM = mean(cellfun(@(x) std(x)/sqrt(numel(x)), midPerformance)) * 100;
    lateMean = mean(cellfun(@(x) mean(x), latePerformance)) * 100;
    lateSEM = mean(cellfun(@(x) std(x)/sqrt(numel(x)), latePerformance)) * 100;
    performanceSessions = struct('means', struct('early', earlyMean, 'mid', midMean, 'late', lateMean), ...
        'sem', struct('early', earlySEM, 'mid', midSEM, 'late', lateSEM));

    performanceAll = cellfun(@(x) percent_correct(x, presets), parserArray, 'uni', 0);
    trainingDates = cellfun(@(x) arrayfun(@(y) datetime(y.session.Info.SessionDate), x, 'uni', 0), parserArray, 'uni', 0);
    allDates = [];
    for i = 1:numel(trainingDates)
        allDates = [allDates, [trainingDates{i}{:}]];
    end
    uniqueDates = unique(allDates);
    numDates = numel(uniqueDates);
    numAnimals = numel(parserArray);
    alignedPerformanceAll = nan(numDates, numAnimals);
    for i = 1:numAnimals
        [~, loc] = ismember([trainingDates{i}{:}], uniqueDates);
        alignedPerformanceAll(loc, i) = performanceAll{i};
    end
    performanceSessions(1).all = alignedPerformanceAll;
end

function sessionPerformance = percent_correct(parserArray, presets)
    [numTT, numCorrect] = arrayfun(@(y) y.performance('preset', presets), parserArray, 'uni', 0);
    sessionPerformance = cellfun(@(x, y) sum(x)/sum(y), numCorrect, numTT);
end