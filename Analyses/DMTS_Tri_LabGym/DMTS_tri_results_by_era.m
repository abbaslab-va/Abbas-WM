function eraStruct = DMTS_tri_results_by_era(trainingSessions)

% Input a data matrix of N x S, where N is the number of sessions and S is
% the number of subjects. The struct will contain means and sem for early,
% mid, and late eras of the data.

    eraFraction = 1/3;
    numTrainingSessionsAll = size(trainingSessions, 1);
    sessionsPerEra = floor(numTrainingSessionsAll*eraFraction);
    earlySessionsIdx = 1:sessionsPerEra;
    earlySessions = trainingSessions(earlySessionsIdx, :);
    [eraStruct.early.mean, eraStruct.early.sem] = calculate_averages(earlySessions);
    midSessionsIdx = sessionsPerEra + 1:sessionsPerEra * 2;
    midSessions = trainingSessions(midSessionsIdx, :);
    [eraStruct.mid.mean, eraStruct.mid.sem] = calculate_averages(midSessions);
    lateSessionsIdx = 2 * sessionsPerEra + 1:numTrainingSessionsAll;
    lateSessions = trainingSessions(lateSessionsIdx, :);
    [eraStruct.late.mean, eraStruct.late.sem] = calculate_averages(lateSessions);
end

function [meanVal, SEM] = calculate_averages(dataMat)
    meanVal = mean(dataMat, 'all', 'omitnan');
    SEM = std(dataMat, 0, 'all', 'omitnan')./sqrt(sum(~isnan(dataMat), 'all'));
end