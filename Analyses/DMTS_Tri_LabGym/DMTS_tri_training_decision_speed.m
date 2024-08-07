function eraDiff = DMTS_tri_training_decision_speed(parserArray, plotEras, biasType)

    [preferredTimeToChoice, nonPreferredTimeToChoice] = cellfun(@(x) ...
        arrayfun(@(y) DMTS_tri_time_to_choice(y, biasType), x), parserArray, 'uni', 0);
    preferredTimeAligned = align_training_data(parserArray, preferredTimeToChoice);
    nonPreferredTimeAligned = align_training_data(parserArray, nonPreferredTimeToChoice);
    % preferredAll = [preferredTimeToChoice{:}];
    % nonPreferredAll = [nonPreferredTimeToChoice{:}];
    eraDiff.preferred = DMTS_tri_results_by_era(preferredTimeAligned);
    eraDiff.nonPreferred = DMTS_tri_results_by_era(nonPreferredTimeAligned);
    eraNames = fields(eraDiff.preferred);
    if ~plotEras
        return
    end
    for e = 1:numel(eraNames)
        era = eraNames{e};
        figure
        eraMeans = [eraDiff.preferred.(era).mean eraDiff.nonPreferred.(era).mean];
        eraSEM = [eraDiff.preferred.(era).sem eraDiff.nonPreferred.(era).sem];
        bar(eraMeans, 'k', 'FaceAlpha', .6, 'EdgeAlpha', .6);
        hold on
        errorbar([1, 2], eraMeans, eraSEM, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
        clean_DMTS_figs
    end
end