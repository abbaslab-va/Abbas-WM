function repeatData = DMTS_tri_training_repeats(parserArray)

repeatedPunishAll = cellfun(@(x) arrayfun(@(y) y.state_times('Punish', 'outcome', 'Repeat'), x, 'uni', 0), parserArray, 'uni', 0);
% repeatedCorrectAll = cellfun(@(x) arrayfun(@(y) y.state_times('ChoiceOn', 'outcome', 'Repeat'), x, 'uni', 0), parserArray, 'uni', 0);
% repeatedPunishLeft = cellfun(@(x) arrayfun(@(y) y.state_times('Punish', 'outcome', 'Repeat', 'trialType', 'Left'), x, 'uni', 0), parserArray, 'uni', 0);
% repeatedPunishRight = cellfun(@(x) arrayfun(@(y) y.state_times('Punish', 'outcome', 'Repeat', 'trialType', 'Right'), x, 'uni', 0), parserArray, 'uni', 0);

repeatBySession = cellfun(@(x) cellfun(@(y) numel(y), x), repeatedPunishAll, 'uni', 0);
repeatData = align_training_data(parserArray, repeatBySession);

meanRepeatPunish = mean(repeatData, 2, 'omitnan');        
semRepeatPunish = std(repeatData, 0, 2, 'omitnan')./sqrt(sum(~isnan(repeatData), 2));
shaded_error_plot(1:numel(meanRepeatPunish), meanRepeatPunish, semRepeatPunish, [0 0 0], [.2 .2 .2], .3);
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
% repeatCorrectByTrial = cellfun(@(x) numel(x), repeatedCorrectAll);
% repeatPunishByTrialLeft = cellfun(@(x) numel(x), repeatedPunishLeft);
% repeatPunishByTrialRight = cellfun(@(x) numel(x), repeatedPunishRight);
% trainingBiasIdx(isnan(trainingBiasIdx)) = 0;
% for sub = 1:numFilteredSubs
%     % figure
%     % plot(repeatPunishByTrial(sub, :))
%     % yyaxis right
%     % plot(absoluteBias(sub, :))
%     figure
%     plot(repeatPunishByTrialLeft(sub, :))
%     yyaxis right
%     plot(trainingBiasIdx(sub, :))
%     figure
%     plot(repeatPunishByTrialRight(sub, :))
%     yyaxis right
%     plot(trainingBiasIdx(sub, :))
end