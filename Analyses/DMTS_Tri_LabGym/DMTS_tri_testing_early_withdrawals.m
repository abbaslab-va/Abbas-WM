function ewProportion = DMTS_tri_testing_early_withdrawals(testingSessions, delayBins)

ewCountAll = arrayfun(@(x) ...
    x.bpod.state_times('EarlyWithdrawal', 'trialized', true), ...
    testingSessions.sessions, 'uni', 0);
ewByTrial = cellfun(@(x) cellfun(@(y) cellfun(@(z) numel(z), y), x, 'uni', 0), ewCountAll, 'uni', 0);
ewBySession = cellfun(@(x) cellfun(@(y) sum(y), x), ewByTrial, 'uni', 0);
% ewBySessionMeans = mean(ewBySessionAligned, 2, 'omitnan');
% ewBySessionSEM = std(ewBySessionAligned, 0, 2, 'omitnan')./sqrt(sum(~isnan(ewBySessionAligned), 2));
% shaded_error_plot(1:size(ewBySessionAligned, 1), ewBySessionMeans, ewBySessionSEM, 'k', 'k', .3);
% clean_DMTS_figs

[delayTimes, ewByDelay] = arrayfun(@(x) ...
    DMTS_tri_delay_length(x.bpod), ...
    testingSessions.sessions, 'uni', 0);
ewByDelay = cat(1, ewByDelay{:});
numTrialsByDelay = cellfun(@(x) ...
    cellfun(@(y) sum(~isnan(discretize(x, y))), delayBins), ...
    delayTimes, 'uni', 0);
numTrialsByDelay = cat(1, numTrialsByDelay{:});
ewProportion = ewByDelay./numTrialsByDelay;