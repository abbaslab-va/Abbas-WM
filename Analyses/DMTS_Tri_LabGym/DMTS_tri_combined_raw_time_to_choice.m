function DMTS_tri_combined_raw_time_to_choice(trainingStruct, testingStruct)
% This generates a panel in figure 4, combining the time to choice diff for preferred against non-preferred
% through training with the same metric during testing.

meanData = [trainingStruct.preferredCorrect.early.mean, trainingStruct.preferredCorrect.mid.mean, trainingStruct.preferredCorrect.late.mean, testingStruct.preferredCorrect.mean; ...
    trainingStruct.preferredIncorrect.early.mean, trainingStruct.preferredIncorrect.mid.mean, trainingStruct.preferredIncorrect.late.mean, testingStruct.preferredIncorrect.mean; ...
    trainingStruct.nonPreferredCorrect.early.mean, trainingStruct.nonPreferredCorrect.mid.mean, trainingStruct.nonPreferredCorrect.late.mean, testingStruct.nonPreferredCorrect.mean; ...
    trainingStruct.nonPreferredIncorrect.early.mean, trainingStruct.nonPreferredIncorrect.mid.mean, trainingStruct.nonPreferredIncorrect.late.mean, testingStruct.nonPreferredIncorrect.mean]';
semData = [trainingStruct.preferredCorrect.early.sem, trainingStruct.preferredCorrect.mid.sem, trainingStruct.preferredCorrect.late.sem, testingStruct.preferredCorrect.sem; ...
    trainingStruct.preferredIncorrect.early.sem, trainingStruct.preferredIncorrect.mid.sem, trainingStruct.preferredIncorrect.late.sem, testingStruct.preferredIncorrect.sem; ...
    trainingStruct.nonPreferredCorrect.early.sem, trainingStruct.nonPreferredCorrect.mid.sem, trainingStruct.nonPreferredCorrect.late.sem, testingStruct.nonPreferredCorrect.sem; ...
    trainingStruct.nonPreferredIncorrect.early.sem, trainingStruct.nonPreferredIncorrect.mid.sem, trainingStruct.nonPreferredIncorrect.late.sem, testingStruct.nonPreferredIncorrect.sem]';
figure
meanBar = bar(meanData, 'k', 'FaceAlpha', .6, 'EdgeAlpha', .6);
hold on
preferenceColors = brewermap(8, 'Blues');
preferredColor = preferenceColors(8, :);
nonPreferredColor = preferenceColors(5, :);
meanBar(1).FaceColor = preferredColor;
meanBar(2).FaceColor = preferredColor;
hatchfill2(meanBar(2), 'single', 'HatchAngle', -60, 'hatchcolor', [0 0 0], 'HatchDensity', 80, 'HatchLineWidth', 1)
meanBar(3).FaceColor = nonPreferredColor;
meanBar(4).FaceColor = nonPreferredColor;
hatchfill2(meanBar(4), 'single', 'HatchAngle', -60, 'hatchcolor', [0 0 0], 'HatchDensity', 80, 'HatchLineWidth', 1)
meanBar(1).EdgeColor = preferredColor;
meanBar(2).EdgeColor = preferredColor;
meanBar(3).EdgeColor = nonPreferredColor;
meanBar(4).EdgeColor = nonPreferredColor;
preferredCorrectX = meanBar(1).XEndPoints;
preferredIncorrectX = meanBar(2).XEndPoints;
nonPreferredCorrectX = meanBar(3).XEndPoints;
nonPreferredIncorrectX = meanBar(4).XEndPoints;
errorX = [preferredCorrectX; preferredIncorrectX; nonPreferredCorrectX; nonPreferredIncorrectX]';
errorbar(errorX, meanData, semData, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
% xticklabels({"Early", "Mid", "Late", "Testing"})
xticklabels({})
% yticklabels({})
legend({"Preferred Correct", "Preferred Incorrect", "Remove me", "Non-Preferred Correct", "Non-Preferred Incorrect"}, 'Location', 'southeast')
clean_DMTS_figs

figure
hashBar = bar(10, 'FaceColor', 'w', 'EdgeColor', 'w');
hatchfill2(hashBar, 'single', 'HatchAngle', -60, 'hatchcolor', [0 0 0], 'HatchDensity', 80, 'HatchLineWidth', 1)