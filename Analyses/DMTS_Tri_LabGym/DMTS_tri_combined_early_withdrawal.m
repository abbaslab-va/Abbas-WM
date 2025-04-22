function DMTS_tri_combined_early_withdrawal(trainingData, testingData, delayColors)

testingMeans = mean(testingData, 1);
testingSEM = std(testingData, 1)./sqrt(size(testingData, 1));

ewMeans = ...
    [cellfun(@(x) x.early.mean, trainingData); ...
    cellfun(@(x) x.mid.mean, trainingData); ...
    cellfun(@(x) x.late.mean, trainingData); ...
    testingMeans];
ewError = ...
    [cellfun(@(x) x.early.sem, trainingData); ...
    cellfun(@(x) x.mid.sem, trainingData); ...
    cellfun(@(x) x.late.sem, trainingData); ...
    testingSEM];
figure
figH = bar(ewMeans);
figH(1).FaceColor = delayColors{1};
figH(2).FaceColor = delayColors{2};
figH(3).FaceColor = delayColors{3};
figH(1).EdgeColor = delayColors{1};
figH(2).EdgeColor = delayColors{2};
figH(3).EdgeColor = delayColors{3};
hold on
barX = arrayfun(@(x) x.XEndPoints', figH, 'uni', 0);
barX = cat(2, barX{:});
errorbar(barX', ewMeans', ewError','vertical', 'Color', 'k', 'LineStyle', 'none')
xticklabels({"Early", "Mid", "Late", "Testing"})
clean_DMTS_figs
legend({'0-3 sec', '3-5 sec', '5-7 sec'})