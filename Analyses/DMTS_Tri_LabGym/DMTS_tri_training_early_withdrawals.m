function DMTS_tri_training_early_withdrawals(trainingSessions)

% Number of early withdrawals per training day
ewCountAll = cellfun(@(x) ...
    arrayfun(@(y) y.state_times('EarlyWithdrawal', 'trialized', true), ...
    x, 'uni', 0), trainingSessions, 'uni', 0);
ewByTrial = cellfun(@(x) cellfun(@(y) cellfun(@(z) numel(z), y), x, 'uni', 0), ewCountAll, 'uni', 0);
ewBySession = cellfun(@(x) cellfun(@(y) sum(y), x), ewByTrial, 'uni', 0);
ewBySessionAligned = align_training_data(trainingSessions, ewBySession);
ewBySessionMeans = mean(ewBySessionAligned, 2, 'omitnan');
ewBySessionSEM = std(ewBySessionAligned, 0, 2, 'omitnan')./sqrt(sum(~isnan(ewBySessionAligned), 2));
shaded_error_plot(1:size(ewBySessionAligned, 1), ewBySessionMeans, ewBySessionSEM, 'k', 'k', .3);
clean_DMTS_figs

% Early withdrawals according to delay length
[~, ewByDelay] = cellfun(@(x) ...
    arrayfun(@(y) DMTS_tri_delay_length(y), ...
    x, 'uni', 0), trainingSessions, 'uni', 0);
ewByDelay = cellfun(@(x) cat(1, x{:}), ewByDelay, 'uni', 0);
ewByDelayCells = arrayfun(@(x) ...
    cellfun(@(y) y(:, x), ewByDelay, ...
    'uni', 0), 1:5, 'uni', 0);
ewByDelayAligned = cellfun(@(x) ...
    align_training_data(trainingSessions, x), ...
    ewByDelayCells, 'uni', 0);
ewByDelayMeans = cellfun(@(x) mean(x, 2, 'omitnan'), ewByDelayAligned, 'uni', 0);
ewByDelayAll = cat(2, ewByDelayMeans{:})