function ewProportion = DMTS_tri_testing_early_withdrawals(testingSessions, delayBins)

% OUTPUT:
%     ewProportion - a SxB matrix of early withdrawal proportions, 
%     where S is the number of sessions and B is the number of delayBins
%     Also plots a bar chart of mean and SEM across all sessions
% INPUT:
%     testingSessions - output from DMTS_tri_pipeline_init
%     delayBins - a cell array of 1x2 delay bin edges

ewCountAll = arrayfun(@(x) ...
    x.bpod.state_times('EarlyWithdrawal', 'trialized', true), ...
    testingSessions.sessions, 'uni', 0);
ewByTrial = cellfun(@(x) cellfun(@(y) numel(y), x), ewCountAll, 'uni', 0);
% ewBySession = cellfun(@(x) cellfun(@(y) sum(y), x), ewByTrial, 'uni', 0);
% ewBySessionMeans = mean(ewBySessionAligned, 2, 'omitnan');
% ewBySessionSEM = std(ewBySessionAligned, 0, 2, 'omitnan')./sqrt(sum(~isnan(ewBySessionAligned), 2));
% shaded_error_plot(1:size(ewBySessionAligned, 1), ewBySessionMeans, ewBySessionSEM, 'k', 'k', .3);
% clean_DMTS_figs

[delayTimes, ewByDelay] = arrayfun(@(x) ...
    DMTS_tri_delay_length(x.bpod, 'binRanges', delayBins), ...
    testingSessions.sessions, 'uni', 0);
ewByDelay = cat(1, ewByDelay{:});
numTrialsByDelay = cellfun(@(x) ...
    cellfun(@(y) sum(~isnan(discretize(x, y))), delayBins), ...
    delayTimes, 'uni', 0);
numTrialsByDelay = cat(1, numTrialsByDelay{:});
ewProportion = ewByDelay./numTrialsByDelay;

ewMeans = mean(ewProportion, 1);
ewSEM = std(ewProportion, 1)./sqrt(size(ewProportion, 1));
figure
bar(ewMeans, 'FaceColor', 'k', 'FaceAlpha', .6)
hold on
errorbar(1:numel(delayBins), ewMeans, ewSEM, 'vertical', 'LineStyle', 'none', 'LineWidth', 1.5, 'Color', 'k')
clean_DMTS_figs
