function combined_behavior_and_position(testingSessions, subNo)

leftCorrect = PresetManager('event', 'choicePoke', 'outcome', 'Correct', 'trialType', 'Left', 'edges', [-1 0]);
rightCorrect = PresetManager('event', 'choicePoke', 'outcome', 'Correct', 'trialType', 'Right', 'edges', [-1 0]);

subName = testingSessions.metadata.subjects{subNo};
subIdx = testingSessions.subset('animal', subName);
sessIdx = find(subIdx);
leftPosition = figure;
hold on
rightPosition = figure;
hold on
for sess = sessIdx
    [~, leftSess] = testingSessions.sessions(sess).plot_centroid('preset', leftCorrect);
    xlim([60 220])
    ylim([0 140])
    set(leftSess, 'Color', 'none')
    [~, rightSess] = testingSessions.sessions(sess).plot_centroid('preset', rightCorrect);
    xlim([60 220])
    ylim([0 140])
    set(rightSess, 'Color', 'none')
    arrayfun(@(x) copyobj(x, leftPosition.Children), leftSess.Children.Children)
    close(leftSess)
    arrayfun(@(x) copyobj(x, rightPosition.Children), rightSess.Children.Children)
    close(rightSess)
end
set(leftPosition.Children, 'xlim', [60 220], 'ylim', [0 140])
set(rightPosition.Children, 'xlim', [60 220], 'ylim', [0 140])
[~, ~, leftBehavior] = testingSessions.plot_combined_behaviors('preset', leftCorrect, 'animal', subName);
[~, ~, rightBehavior] = testingSessions.plot_combined_behaviors('preset', rightCorrect, 'animal', subName);
copygraphics(leftPosition, 'ContentType', 'vector')
disp("Left position copied to clipboard")
pause
copygraphics(rightPosition, 'ContentType', 'vector')
disp("Right position copied to clipboard")
pause
subNo = num2str(find(strcmp(subName, testingSessions.metadata.subjects)));
exportgraphics(leftBehavior.Children, fullfile('E:\Papers\DMTS_Tri\Figures\figure4', strcat(subName, '_Left_', subNo, '.png')));
exportgraphics(rightBehavior.Children, fullfile('E:\Papers\DMTS_Tri\Figures\figure4', strcat(subName, '_Right_', subNo, '.png')));
