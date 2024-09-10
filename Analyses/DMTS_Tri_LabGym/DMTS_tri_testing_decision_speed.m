function choiceDiff = DMTS_tri_testing_decision_speed(managerObj, biasType, delayLen)
    % OUTPUT:
    %     choiceDiff - a structure containing average and sem values for the difference
    %     in latencies between incorrect and correct choice port arrivals, comparing the 
    %     preferred trialtypes against the non-preferred
    % INPUT:
    %     managerObj - an ExpManager object containing BehDat sessions with BpodParser sessions within
    %     biasType - a string indicating if bias should be calculated by performance ('perf') or side preference ('side')

    if ~exist('delayLen', 'var')
        delayLen = [0 7];
    end
    [preferredTimeToChoice, nonPreferredTimeToChoice] = arrayfun(@(x) ...
        DMTS_tri_time_to_choice(x.bpod, biasType, delayLen), managerObj.sessions);
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
    %correctDiff

    [correctTimeToChoice, incorrectTimeToChoice] = arrayfun(@(x) ...
        DMTS_tri_time_to_choice_correct_diff(x.bpod, biasType, delayLen), managerObj.sessions);
    [choiceDiff.correct.mean, choiceDiff.correct.sem] = calculate_averages(correctTimeToChoice);
    [choiceDiff.incorrect.mean, choiceDiff.incorrect.sem] = calculate_averages(incorrectTimeToChoice);
    testingMeans = [choiceDiff.correct.mean choiceDiff.incorrect.mean];
    testingSEM = [choiceDiff.correct.sem choiceDiff.incorrect.sem];
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