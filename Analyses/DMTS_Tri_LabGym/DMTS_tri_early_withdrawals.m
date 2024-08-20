function [abortedTrials, reentriesPerCompletion] = DMTS_tri_early_withdrawals(trainingSessions)
% Currently does a lot of work. Counts the total number of early withdrawals, as well as
% binned according to the delay length. Plots average number of early
% withdrawals through training. Attempts to find a relationship between early withdrawals by delay
% and trial type preference, this is still a WIP.


ewCountAll = cellfun(@(x) ...
    arrayfun(@(y) y.state_times('EarlyWithdrawal', 'trialized', true), ...
    x, 'uni', 0), trainingSessions, 'uni', 0);
[~, ewByDelay] = cellfun(@(x) ...
    arrayfun(@(y) DMTS_tri_delay_length(y, 'calcType', 'proportion'), ...
    x, 'uni', 0), trainingSessions, 'uni', 0);
ewByDelayAligned = reshape_delay_arrays(ewByDelay, trainingSessions);
ewByTrial = cellfun(@(x) cellfun(@(y) cellfun(@(z) numel(z), y), x, 'uni', 0), ewCountAll, 'uni', 0);
ewBySession = cellfun(@(x) cellfun(@(y) sum(y), x), ewByTrial, 'uni', 0);
ewBySessionAligned = align_training_data(trainingSessions, ewBySession);
ewBySessionMeans = mean(ewBySessionAligned, 2, 'omitnan');
ewBySessionSEM = std(ewBySessionAligned, 0, 2, 'omitnan')./sqrt(sum(~isnan(ewBySessionAligned), 2));
shaded_error_plot(1:size(ewBySessionAligned, 1), ewBySessionMeans, ewBySessionSEM, 'k', 'k', .3);
clean_DMTS_figs


ewCountLeft = cellfun(@(x) ...
    arrayfun(@(y) y.state_times('EarlyWithdrawal', 'trialized', true, 'trialType', 'Left'), ...
    x, 'uni', 0), trainingSessions, 'uni', 0);
ewByTrialLeft = cellfun(@(x) cellfun(@(y) cellfun(@(z) numel(z), y), x, 'uni', 0), ewCountLeft, 'uni', 0);
ewBySessionLeft = cellfun(@(x) cellfun(@(y) sum(y), x), ewByTrialLeft, 'uni', 0);
ewBySessionAlignedLeft = align_training_data(trainingSessions, ewBySessionLeft);
[~, ewByDelayLeft] = cellfun(@(x) ...
    arrayfun(@(y) DMTS_tri_delay_length(y, 'calcType', 'proportion', 'trialType', 'Left'), ...
    x, 'uni', 0), trainingSessions, 'uni', 0);
ewByDelayAlignedLeft = reshape_delay_arrays(ewByDelayLeft, trainingSessions);

ewCountRight = cellfun(@(x) ...
    arrayfun(@(y) y.state_times('EarlyWithdrawal', 'trialized', true, 'trialType', 'Right'), ...
    x, 'uni', 0), trainingSessions, 'uni', 0);
ewByTrialRight = cellfun(@(x) cellfun(@(y) cellfun(@(z) numel(z), y), x, 'uni', 0), ewCountRight, 'uni', 0);
ewBySessionRight = cellfun(@(x) cellfun(@(y) sum(y), x), ewByTrialRight, 'uni', 0);
ewBySessionAlignedRight = align_training_data(trainingSessions, ewBySessionRight);
[~, ewByDelayRight] = cellfun(@(x) ...
    arrayfun(@(y) DMTS_tri_delay_length(y, 'calcType', 'proportion', 'trialType', 'Right'), ...
    x, 'uni', 0), trainingSessions, 'uni', 0);

ewByDelayAlignedRight = reshape_delay_arrays(ewByDelayRight, trainingSessions);

sideBiasData = DMTS_tri_training_side_bias(trainingSessions);
ewCountPreferred = nan(size(sideBiasData));
ewCountNonPreferred = nan(size(sideBiasData));

for d = 1:5
    figure
    scatter(ewByDelayAlignedLeft{d}, sideBiasData, 10, 'r', 'filled')
    hold on
    scatter(ewByDelayAlignedRight{d}, sideBiasData, 10, 'g', 'filled')
end

figure


disp('poop')
leftBias = sideBiasData < 0;
rightBias = sideBiasData > 0;
ewCountPreferred(leftBias) = ewBySessionAlignedLeft(leftBias);
ewCountPreferred(rightBias) = ewBySessionAlignedRight(rightBias);
ewCountNonPreferred(leftBias) = ewBySessionAlignedRight(leftBias);
ewCountNonPreferred(rightBias) = ewBySessionAlignedLeft(rightBias);

end
function ewBySub = reshape_delay_arrays(ewByDelay, trainingSessions)
    ewByDelay = cellfun(@(x) cat(1, x{:}), ewByDelay, 'uni', 0);
    ewByDelayCell = cellfun(@(x) arrayfun(@(y) x(:, y), 1:5, 'uni', 0), ewByDelay, 'uni', 0);
    ewByDelayCellCat = cat(1, ewByDelayCell{:});
    ewByDelaySplit = arrayfun(@(x) ewByDelayCellCat(:, x), 1:5, 'uni', 0);
    ewBySub = cellfun(@(x) align_training_data(trainingSessions, x), ewByDelaySplit, 'uni', 0);
end