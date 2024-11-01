function DMTS_tri_combined_diff(trainingStruct, testingStruct)
% This generates a panel in figure 4, combining the time to choice diff for preferred against non-preferred
% through training with the same metric during testing.

meanData = [trainingStruct.preferred.early.mean, trainingStruct.preferred.mid.mean, trainingStruct.preferred.late.mean, testingStruct.preferred.mean; ...
    trainingStruct.nonPreferred.early.mean, trainingStruct.nonPreferred.mid.mean, trainingStruct.nonPreferred.late.mean, testingStruct.nonPreferred.mean]';
semData = [trainingStruct.preferred.early.sem, trainingStruct.preferred.mid.sem, trainingStruct.preferred.late.sem, testingStruct.preferred.sem; ...
    trainingStruct.nonPreferred.early.sem, trainingStruct.nonPreferred.mid.sem, trainingStruct.nonPreferred.late.sem, testingStruct.nonPreferred.sem]';
figure
meanBar = bar(meanData, 'k', 'FaceAlpha', .6, 'EdgeAlpha', .6);
hold on
preferenceColors = brewermap(8, 'Blues');
preferredColor = preferenceColors(8, :);
nonPreferredColor = preferenceColors(5, :);
meanBar(1).FaceColor = preferredColor;
meanBar(2).FaceColor = nonPreferredColor;
meanBar(1).EdgeColor = preferredColor;
meanBar(2).EdgeColor = nonPreferredColor;

preferredX = meanBar(1).XEndPoints;
nonPreferredX = meanBar(2).XEndPoints;
errorX = [preferredX; nonPreferredX]';
errorbar(errorX, meanData, semData, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
% xticklabels({"Early", "Mid", "Late", "Testing"})
xticklabels({})
yticklabels({})
legend({"Preferred", "Non-Preferred"}, 'Location', 'southeast')
clean_DMTS_figs