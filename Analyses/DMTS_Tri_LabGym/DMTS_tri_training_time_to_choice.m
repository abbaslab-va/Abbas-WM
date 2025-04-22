function timeByEra = DMTS_tri_training_time_to_choice(parserArray, plotEras, biasType, delayLen)
% Plots the preferred and non-preferred time to choice throughout the three training eras,
% and returns the structure with the means and SEM.

if ~exist('delayLen', 'var')
    delayLen = [0 7];
end

[preferredCorrect, preferredIncorrect, nonPreferredCorrect, nonPreferredIncorrect] = cellfun(@(x) ...
    arrayfun(@(y) DMTS_tri_time_to_choice_raw(y, biasType, delayLen), x), parserArray, 'uni', 0);
preferredCorrectAligned = align_training_data(parserArray, preferredCorrect);
preferredIncorrectAligned = align_training_data(parserArray, preferredIncorrect);
nonPreferredCorrectAligned = align_training_data(parserArray, nonPreferredCorrect);
nonPreferredIncorrectAligned = align_training_data(parserArray, nonPreferredIncorrect);
timeByEra.preferredCorrect = DMTS_tri_results_by_era(preferredCorrectAligned);
timeByEra.preferredIncorrect = DMTS_tri_results_by_era(preferredIncorrectAligned);
timeByEra.nonPreferredCorrect = DMTS_tri_results_by_era(nonPreferredCorrectAligned);
timeByEra.nonPreferredIncorrect = DMTS_tri_results_by_era(nonPreferredIncorrectAligned);
eraNames = fields(timeByEra.preferredCorrect);
if ~plotEras
    return
end
for e = 1:numel(eraNames)
    era = eraNames{e};
    figure
    eraMeans = [timeByEra.preferredCorrect.(era).mean timeByEra.preferredIncorrect.(era).mean ...
        timeByEra.nonPreferredCorrect.(era).mean timeByEra.nonPreferred.(era).mean];
    eraSEM = [timeByEra.preferred.(era).sem timeByEra.nonPreferredIncorrect.(era).sem];
    bar(eraMeans, 'k', 'FaceAlpha', .6, 'EdgeAlpha', .6);
    hold on
    errorbar([1, 2], eraMeans, eraSEM, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
    clean_DMTS_figs
end