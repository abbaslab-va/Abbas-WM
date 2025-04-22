function DMTS_tri_bias_by_delay_combined(trainingData, testingData, delayColors)
testingBiasMeans = mean(testingData, 1, 'omitnan');
testingBiasSEM = std(testingData, 0, 1)./sqrt(size(testingData, 1));

meanData = [cellfun(@(x) x.early.mean, trainingData); ...
    cellfun(@(x) x.mid.mean, trainingData); ...
    cellfun(@(x) x.late.mean, trainingData); ...
    testingBiasMeans];

semData = [cellfun(@(x) x.early.sem, trainingData); ...
    cellfun(@(x) x.mid.sem, trainingData); ...
    cellfun(@(x) x.late.sem, trainingData); ...
    testingBiasSEM];

figure
meanBar = bar(meanData);
meanBar(1).FaceColor = delayColors{1};
meanBar(2).FaceColor = delayColors{2};
meanBar(3).FaceColor = delayColors{3};
meanBar(1).EdgeColor = delayColors{1};
meanBar(2).EdgeColor = delayColors{2};
meanBar(3).EdgeColor = delayColors{3};

hold on
zeroDelayX = meanBar(1).XEndPoints;
shortDelayX = meanBar(2).XEndPoints;
longDelayX = meanBar(3).XEndPoints;

errorX = [zeroDelayX; shortDelayX; longDelayX]';
errorbar(errorX, meanData, semData, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
xticklabels({"Early", "Mid", "Late", "Testing"})
clean_DMTS_figs
legend({'0-3 sec', '3-5 sec', '5-7 sec'})