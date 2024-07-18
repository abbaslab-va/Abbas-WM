function eraDiff = DMTS_tri_training_decision_speed(parserArray)

    [preferredTimeToChoice, nonPreferredTimeToChoice] = cellfun(@(x) ...
        arrayfun(@(y) DMTS_tri_time_to_choice(y), x), parserArray, 'uni', 0);
    preferredTimeAligned = align_training_data(parserArray, preferredTimeToChoice);
    nonPreferredTimeAligned = align_training_data(parserArray, nonPreferredTimeToChoice);
    % preferredAll = [preferredTimeToChoice{:}];
    % nonPreferredAll = [nonPreferredTimeToChoice{:}];
    eraDiff = diff_by_era(preferredTimeAligned, nonPreferredTimeAligned);
    eraNames = fields(eraDiff);
    for e = 1:numel(eraNames)
        era = eraNames{e};
        figure
        eraMeans = [eraDiff.(era).preferred.mean eraDiff.(era).nonPreferred.mean];
        eraSEM = [eraDiff.(era).preferred.sem eraDiff.(era).nonPreferred.sem];
        bar(eraMeans, 'k', 'FaceAlpha', );
        hold on
        errorbar([1, 2], eraMeans, eraSEM, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
        clean_DMTS_figs
    end
end

function eraDiff = diff_by_era(preferred, nonPreferred)
    eraFraction = 1/3;
    numTrainingSessionsAll = size(preferred, 1);
    sessionsPerEra = floor(numTrainingSessionsAll*eraFraction);
    earlySessionsIdx = 1:sessionsPerEra;
    earlyPreferred = preferred(earlySessionsIdx, :);
    earlyNonPreferred = nonPreferred(earlySessionsIdx, :);
    [eraDiff.early.preferred.mean, eraDiff.early.preferred.sem] = calculate_averages(earlyPreferred);
    [eraDiff.early.nonPreferred.mean, eraDiff.early.nonPreferred.sem] = calculate_averages(earlyNonPreferred);
    midSessionsIdx = sessionsPerEra + 1:sessionsPerEra * 2;
    midPreferred = preferred(midSessionsIdx, :);
    midNonPreferred = nonPreferred(midSessionsIdx, :);
    [eraDiff.mid.preferred.mean, eraDiff.mid.preferred.sem] = calculate_averages(midPreferred);
    [eraDiff.mid.nonPreferred.mean, eraDiff.mid.nonPreferred.sem] = calculate_averages(midNonPreferred);
    lateSessionsIdx = 2 * sessionsPerEra + 1:numTrainingSessionsAll;
    latePreferred = preferred(lateSessionsIdx, :);
    lateNonPreferred = nonPreferred(lateSessionsIdx, :);
    [eraDiff.late.preferred.mean, eraDiff.late.preferred.sem] = calculate_averages(latePreferred);
    [eraDiff.late.nonPreferred.mean, eraDiff.late.nonPreferred.sem] = calculate_averages(lateNonPreferred);
end

function [meanVal, SEM] = calculate_averages(dataMat)
    meanVal = mean(dataMat, 'all', 'omitnan');
    SEM = std(dataMat, 0, 'all', 'omitnan')./sqrt(sum(~isnan(dataMat), 'all'));
end