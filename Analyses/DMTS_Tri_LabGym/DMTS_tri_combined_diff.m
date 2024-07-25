function DMTS_tri_combined_diff(trainingStruct, testingStruct)

meanData = [trainingStruct.preferred.early.mean, trainingStruct.preferred.mid.mean, trainingStruct.preferred.late.mean, testingStruct.preferred.mean; ...
    trainingStruct.nonPreferred.early.mean, trainingStruct.nonPreferred.mid.mean, trainingStruct.nonPreferred.late.mean, testingStruct.nonPreferred.mean]';
semData = [trainingStruct.preferred.early.sem, trainingStruct.preferred.mid.sem, trainingStruct.preferred.late.sem, testingStruct.preferred.sem; ...
    trainingStruct.nonPreferred.early.sem, trainingStruct.nonPreferred.mid.sem, trainingStruct.nonPreferred.late.sem, testingStruct.nonPreferred.sem]';
figure
meanBar = bar(meanData, 'k', 'FaceAlpha', .6, 'EdgeAlpha', .6);
hold on
preferredX = meanBar(1).XEndPoints;
nonPreferredX = meanBar(2).XEndPoints;
errorX = [preferredX; nonPreferredX]';
errorbar(errorX, meanData, semData, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
clean_DMTS_figs