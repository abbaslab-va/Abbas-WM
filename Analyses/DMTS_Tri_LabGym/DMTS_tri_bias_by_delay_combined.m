function DMTS_tri_bias_by_delay_combined(trainingData, testingData)
blueShades = brewermap(5, 'PuBu');
yellowShades = brewermap(6, 'YlOrBr');
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
% meanBar(1).FaceColor = blueShades(3, :);
% meanBar(2).FaceColor = blueShades(4, :);
% meanBar(3).FaceColor = blueShades(5, :);
% meanBar(1).EdgeColor = blueShades(3, :);
% meanBar(2).EdgeColor = blueShades(4, :);
% meanBar(3).EdgeColor = blueShades(5, :);

meanBar(1).FaceColor = yellowShades(3, :);
meanBar(2).FaceColor = yellowShades(4, :);
meanBar(3).FaceColor = yellowShades(5, :);
meanBar(1).EdgeColor = yellowShades(3, :);
meanBar(2).EdgeColor = yellowShades(4, :);
meanBar(3).EdgeColor = yellowShades(5, :);
hold on
zeroDelayX = meanBar(1).XEndPoints;
shortDelayX = meanBar(2).XEndPoints;
longDelayX = meanBar(3).XEndPoints;

errorX = [zeroDelayX; shortDelayX; longDelayX]';
errorbar(errorX, meanData, semData, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
xticklabels({"Early", "Mid", "Late", "Testing"})
clean_DMTS_figs
legend({'0-3 sec', '3-5 sec', '5-7 sec'})