function [ewStruct, ewBySessionAligned] = DMTS_tri_training_early_withdrawals(trainingSessions, delayBins, trialized)

% Number of early withdrawals per training day
ewCountAll = cellfun(@(x) ...
    arrayfun(@(y) y.state_times('EarlyWithdrawal', 'trialized', true), ...
    x, 'uni', 0), trainingSessions, 'uni', 0);
ewByTrial = cellfun(@(x) cellfun(@(y) cellfun(@(z) numel(z), y), x, 'uni', 0), ewCountAll, 'uni', 0);
if trialized
    ewBySession = cellfun(@(x) cellfun(@(y) nnz(y), x), ewByTrial, 'uni', 0);
else
    ewBySession = cellfun(@(x) cellfun(@(y) sum(y), x), ewByTrial, 'uni', 0);
end
% ewBySession = cellfun(@(x) cellfun(@(y) sum(y), x), ewByTrial, 'uni', 0);
ewBySessionAligned = align_training_data(trainingSessions, ewBySession);
ewBySessionMeans = mean(ewBySessionAligned, 2, 'omitnan');
ewBySessionSEM = std(ewBySessionAligned, 0, 2, 'omitnan')./sqrt(sum(~isnan(ewBySessionAligned), 2));
shaded_error_plot(1:size(ewBySessionAligned, 1), ewBySessionMeans, ewBySessionSEM, 'k', 'k', .3);
xlim([0 numel(ewBySessionMeans)])
clean_DMTS_figs

% Early withdrawals according to delay length
[~, ewByDelay] = cellfun(@(x) ...
    arrayfun(@(y) DMTS_tri_delay_length(y, 'calcType', 'proportion', 'binRanges', delayBins, 'trialized', trialized), ...
    x, 'uni', 0), trainingSessions, 'uni', 0);
ewByDelay = cellfun(@(x) cat(1, x{:}), ewByDelay, 'uni', 0);
ewByDelayCells = arrayfun(@(x) ...
    cellfun(@(y) y(:, x), ewByDelay, ...
    'uni', 0), 1:numel(delayBins), 'uni', 0);
ewByDelayAligned = cellfun(@(x) ...
    align_training_data(trainingSessions, x), ...
    ewByDelayCells, 'uni', 0);
ewStruct = cellfun(@(x) ...
    DMTS_tri_results_by_era(x), ...
    ewByDelayAligned, 'uni', 0);
% ewMeans = ...
%     [cellfun(@(x) x.early.mean, ewProportion); ...
%     cellfun(@(x) x.mid.mean, ewProportion); ...
%     cellfun(@(x) x.late.mean, ewProportion)];
% ewError = ...
%     [cellfun(@(x) x.early.sem, ewProportion); ...
%     cellfun(@(x) x.mid.sem, ewProportion); ...
%     cellfun(@(x) x.late.sem, ewProportion)];
% figure
% figH = bar(ewMeans);
% figH(1).FaceColor = delayColors{1};
% figH(2).FaceColor = delayColors{2};
% figH(3).FaceColor = delayColors{3};
% figH(1).EdgeColor = delayColors{1};
% figH(2).EdgeColor = delayColors{2};
% figH(3).EdgeColor = delayColors{3};
% hold on
% barX = arrayfun(@(x) x.XEndPoints', figH, 'uni', 0);
% barX = cat(2, barX{:});
% errorbar(barX', ewMeans', ewError','vertical', 'Color', 'k', 'LineStyle', 'none')
% clean_DMTS_figs
