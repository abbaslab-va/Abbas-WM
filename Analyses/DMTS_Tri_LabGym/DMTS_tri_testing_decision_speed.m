function choiceDiff = DMTS_tri_testing_decision_speed(managerObj, biasType)

    [preferredTimeToChoice, nonPreferredTimeToChoice] = arrayfun(@(x) ...
        DMTS_tri_time_to_choice(x.bpod, biasType), managerObj.sessions);
    [choiceDiff.preferred.mean, choiceDiff.preferred.sem] = calculate_averages(preferredTimeToChoice);
    [choiceDiff.nonPreferred.mean, choiceDiff.nonPreferred.sem] = calculate_averages(nonPreferredTimeToChoice);
    testingMeans = [choiceDiff.preferred.mean choiceDiff.nonPreferred.mean];
    testingSEM = [choiceDiff.preferred.sem choiceDiff.nonPreferred.sem];
    figure
    bar(testingMeans, 'k', 'FaceAlpha', .6, 'EdgeAlpha', .6)
    hold on
    errorbar([1 2], testingMeans, testingSEM, ...
        'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
    clean_DMTS_figs
end

function [meanVal, SEM] = calculate_averages(dataMat)
    meanVal = mean(dataMat, 'all', 'omitnan');
    SEM = std(dataMat, 0, 'all', 'omitnan')./sqrt(sum(~isnan(dataMat), 'all'));
end