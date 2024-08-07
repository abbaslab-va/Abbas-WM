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
    copyobj(leftSess.Children, leftPosition)
    close(leftSess)
    copyobj(rightSess.Children, rightPosition)
    close(rightSess)
end
[~, ~, leftBehavior] = testingSessions.plot_combined_behaviors('preset', leftCorrect, 'animal', subName);
[~, ~, rightBehavior] = testingSessions.plot_combined_behaviors('preset', rightCorrect, 'animal', subName);
% copygraphics(leftPosition, 'ContentType', 'vector')
% pause
% copygraphics(rightPosition, 'ContentType', 'vector')
% pause
% copygraphics(leftBehavior, 'ContentType', 'vector')
% pause
% copygraphics(rightBehavior, 'ContentType', 'vector')
% pause
