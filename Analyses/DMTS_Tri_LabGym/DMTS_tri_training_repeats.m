function repeatData = DMTS_tri_training_repeats(parserArray, delayBins, trialized, delayColors)
% Plots trial repeats according to the training era, and returns the data in a structure
% If trialized is false, it counts multiple repeats within a trial
% separately. If true, it counts trials that had any number of repeats.

repeatedPunishAll = cellfun(@(x) arrayfun(@(y) ...
    y.state_times('Punish', 'outcome', 'Repeat', 'trialized', trialized), ...
    x, 'uni', 0), parserArray, 'uni', 0);
repeatedTrials = cellfun(@(x) arrayfun(@(y) ...
    y.trial_intersection_BpodParser('outcome', 'Repeat'), ...
    x, 'uni', 0), parserArray, 'uni', 0);
delayTimes = cellfun(@(x) ...
    arrayfun(@(y) DMTS_tri_delay_length(y, 'binRanges', delayBins), ...
    x, 'uni', 0), parserArray, 'uni', 0);
repeatedDelayTimes = cellfun(@(w, x) cellfun(@(y, z) y(z), w, x, 'uni', 0), delayTimes, repeatedTrials, 'uni', 0);
numRepeatsByDelay = cellfun(@(x) cellfun(@(y) cellfun(@(z) ...
    sum(~isnan(discretize(y, z))), delayBins), ...
    x, 'uni', 0), repeatedDelayTimes, 'uni', 0);

numTrialsByDelay = cellfun(@(x) cellfun(@(y) cellfun(@(z) ...
    sum(~isnan(discretize(y, z))), delayBins), ...
    x, 'uni', 0), delayTimes, 'uni', 0);

repeatProportion = cellfun(@(w, x) cellfun(@(y, z) ...
    y./z, w, x, 'uni', 0), numRepeatsByDelay, numTrialsByDelay, 'uni', 0);
repeatByDelayCells = arrayfun(@(x) ...
    cellfun(@(y) cellfun(@(z) z(:, x), y), ...
    repeatProportion, 'uni', 0), ...
    1:numel(delayBins), 'uni', 0);
repeatByDelayAligned = cellfun(@(x) ...
    align_training_data(parserArray, x), ...
    repeatByDelayCells, 'uni', 0);
repeatProportionByEra = cellfun(@(x) ...
    DMTS_tri_results_by_era(x), ...
    repeatByDelayAligned, 'uni', 0);

repeatByDelayMeans = ...
    [cellfun(@(x) x.early.mean, repeatProportionByEra); ...
    cellfun(@(x) x.mid.mean, repeatProportionByEra); ...
    cellfun(@(x) x.late.mean, repeatProportionByEra)];
repeatByDelayError = ...
    [cellfun(@(x) x.early.sem, repeatProportionByEra); ...
    cellfun(@(x) x.mid.sem, repeatProportionByEra); ...
    cellfun(@(x) x.late.sem, repeatProportionByEra)];
figure

figH = bar(repeatByDelayMeans);

figH(1).FaceColor = delayColors{1};
figH(2).FaceColor = delayColors{2};
figH(3).FaceColor = delayColors{3};
figH(1).EdgeColor = delayColors{1};
figH(2).EdgeColor = delayColors{2};
figH(3).EdgeColor = delayColors{3};

hold on
barX = arrayfun(@(x) x.XEndPoints', figH, 'uni', 0);
barX = cat(2, barX{:});
errorbar(barX', repeatByDelayMeans', repeatByDelayError','vertical', 'Color', 'k', 'LineStyle', 'none')
xticklabels({"Early", "Mid", "Late", "Testing"})
clean_DMTS_figs
legend({'0-3 sec', '3-5 sec', '5-7 sec'})
repeatBySession = cellfun(@(x) cellfun(@(y) numel(y), x), repeatedPunishAll, 'uni', 0);


repeatData = align_training_data(parserArray, repeatBySession);

meanRepeatPunish = mean(repeatData, 2, 'omitnan');        
semRepeatPunish = std(repeatData, 0, 2, 'omitnan')./sqrt(sum(~isnan(repeatData), 2));
shaded_error_plot(1:numel(meanRepeatPunish), meanRepeatPunish, semRepeatPunish, [0 0 0], [.2 .2 .2], .3);
xlim([0 numel(meanRepeatPunish)])
clean_DMTS_figs

repeatByEra = DMTS_tri_results_by_era(repeatData);
meanByEra = [repeatByEra.early.mean, repeatByEra.mid.mean, repeatByEra.late.mean];
semByEra = [repeatByEra.early.sem, repeatByEra.mid.sem, repeatByEra.late.sem];
figure
bar(meanByEra, 'k', 'FaceAlpha', .6, 'EdgeAlpha', .6);
hold on
errorbar(meanByEra, semByEra, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
xticklabels({"Early", "Mid", "Late"})
clean_DMTS_figs
