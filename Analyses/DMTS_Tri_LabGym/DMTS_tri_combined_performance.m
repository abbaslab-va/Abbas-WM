function DMTS_tri_combined_performance(trainingData, testingData)

% This is formatted to use outputs from DMTS_tri_training_performance and
% DMTS_tri_testing_performance, respectively

testingMeans = mean(testingData.all.sessions);
testingSEM = std(testingData.all.sessions)./sqrt(numel(testingData.all.sessions));
meanData = [trainingData.means.early, trainingData.means.mid, trainingData.means.late, testingMeans];
semData = [trainingData.sem.early, trainingData.sem.mid, trainingData.sem.late, testingSEM];
figure
bar(meanData, 'k', 'FaceAlpha', .6, 'EdgeAlpha', .6)
hold on
errorbar(meanData, semData, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
xticklabels({"Early", "Mid", "Late", "Testing"})
yline(50, 'LineStyle', '--', 'LineWidth', 3, 'color', 'k', 'Alpha', .6)
ylim([30 100])
clean_DMTS_figs