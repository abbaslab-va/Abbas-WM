function timeByPreference = DMTS_tri_testing_time_to_choice(managerObj, doPlot, biasType, delayLen)
    % OUTPUT:
    %     choiceDiff - a structure containing average and sem values for the difference
    %     in latencies between incorrect and correct choice port arrivals, comparing the 
    %     preferred trialtypes against the non-preferred
    % INPUT:
    %     managerObj - an ExpManager object containing BehDat sessions with BpodParser sessions within
    %     biasType - a string indicating if bias should be calculated by performance ('perf') or side preference ('side')

    if ~exist('delayLen', 'var')
        delayLen = [0 7.5];
    end
    [preferredCorrect, preferredIncorrect, nonPreferredCorrect, nonPreferredIncorrect] = arrayfun(@(x) ...
        DMTS_tri_time_to_choice_raw(x.bpod, biasType, delayLen), managerObj.sessions);
    [timeByPreference.preferredCorrect.mean, timeByPreference.preferredCorrect.sem] = calculate_averages(preferredCorrect);
    [timeByPreference.preferredIncorrect.mean, timeByPreference.preferredIncorrect.sem] = calculate_averages(preferredIncorrect);
    [timeByPreference.nonPreferredCorrect.mean, timeByPreference.nonPreferredCorrect.sem] = calculate_averages(nonPreferredCorrect);
    [timeByPreference.nonPreferredIncorrect.mean, timeByPreference.nonPreferredIncorrect.sem] = calculate_averages(nonPreferredIncorrect);
    if ~doPlot
        return
    end
    testingMeans = [timeByPreference.preferredCorrect.mean timeByPreference.preferredIncorrect.mean ...
        timeByPreference.nonPreferredCorrect.mean timeByPreference.nonPreferredIncorrect.mean];
    testingSEM = [timeByPreference.preferredCorrect.sem timeByPreference.preferredIncorrect.sem ...
        timeByPreference.nonPreferredCorrect.sem timeByPreference.nonPreferredIncorrect.sem];
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