function performanceSessions = DMTS_tri_training_performance(parserArray, varargin)

% Divides a bpod parser array into 3 eras and returns means and sem, as
% well as the aligned performance data per animal.
    presets = PresetManager(varargin{:});
    performanceSessions = perf_by_era(parserArray, presets);
    performanceAll = cellfun(@(x) percent_correct(x, presets), parserArray, 'uni', 0);
    alignedPerformanceAll = align_training_data(parserArray, performanceAll);
    performanceSessions(1).all = alignedPerformanceAll;
end

function eraPerformance = perf_by_era(parserArray, presets)
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
    earlyMean = mean(cellfun(@(x) mean(x, 'omitnan'), earlyPerformance));
    earlySEM = mean(cellfun(@(x) std(x, 'omitnan')/sqrt(numel(find(~isnan(x)))), earlyPerformance));
    midMean = mean(cellfun(@(x) mean(x, 'omitnan'), midPerformance));
    midSEM = mean(cellfun(@(x) std(x, 'omitnan')/sqrt(numel(find(~isnan(x)))), midPerformance));
    lateMean = mean(cellfun(@(x) mean(x, 'omitnan'), latePerformance));
    lateSEM = mean(cellfun(@(x) std(x, 'omitnan')/sqrt(numel(find(~isnan(x)))), latePerformance));
    eraPerformance = struct('means', struct('early', earlyMean, 'mid', midMean, 'late', lateMean), ...
        'sem', struct('early', earlySEM, 'mid', midSEM, 'late', lateSEM));
end

function sessionPerformance = percent_correct(parserArray, presets)
    [numTT, numCorrect] = arrayfun(@(y) y.performance('preset', presets), parserArray, 'uni', 0);
    sessionPerformance = cellfun(@(x, y) 100*sum(x)/sum(y), numCorrect, numTT);
end