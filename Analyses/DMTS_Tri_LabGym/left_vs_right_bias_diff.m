function left_vs_right_bias_diff(testingSessions, biasType, leftColor, rightColor)

frameRate = 30;
if strcmp(biasType, 'perf')
    sessionBias = arrayfun(@(x) calculate_performance_bias(x.bpod), testingSessions.sessions);
elseif strcmp(biasType, 'side')
    sessionBias = arrayfun(@(x) calculate_side_bias(x.bpod), testingSessions.sessions);
else
    throw(MException("DMTS:BadInput", "ERROR: please input either perf or side to select bias type"))
end


delayToChoiceCorrectLeft = arrayfun(@(x) x.distance_between_events('delayReward', 'choicePoke', ...
    'outcome', 'Correct', 'trialType', 'Left', 'trialized', false), testingSessions.sessions, 'uni', 0);
delayToChoiceIncorrectLeft = arrayfun(@(x) x.distance_between_events('delayReward', 'choicePoke', ...
    'outcome', 'Incorrect', 'trialType', 'Left', 'trialized', false), testingSessions.sessions, 'uni', 0);
delayToChoiceCorrectRight = arrayfun(@(x) x.distance_between_events('delayReward', 'choicePoke', ...
    'outcome', 'Correct', 'trialType', 'Right', 'trialized', false), testingSessions.sessions, 'uni', 0);
delayToChoiceIncorrectRight = arrayfun(@(x) x.distance_between_events('delayReward', 'choicePoke', ...
    'outcome', 'Incorrect', 'trialType', 'Right', 'trialized', false), testingSessions.sessions, 'uni', 0);


delayToChoiceCorrectMeansLeft = cellfun(@(x) mean(x)/frameRate, delayToChoiceCorrectLeft);
delayToChoiceIncorrectMeansLeft = cellfun(@(x) mean(x)/frameRate, delayToChoiceIncorrectLeft);
delayToChoiceCorrectMeansRight = cellfun(@(x) mean(x)/frameRate, delayToChoiceCorrectRight);
delayToChoiceIncorrectMeansRight = cellfun(@(x) mean(x)/frameRate, delayToChoiceIncorrectRight);

leftDiffMean = delayToChoiceIncorrectMeansLeft - delayToChoiceCorrectMeansLeft;
rightDiffMean = delayToChoiceIncorrectMeansRight - delayToChoiceCorrectMeansRight;

figure
lftMdl = fitlm(sessionBias, leftDiffMean);
plot(lftMdl)
hold on
scatter(sessionBias, leftDiffMean, 20, leftColor, 'filled')
clean_DMTS_figs
xlim([-.6 .6])
xlabel("Bias weight", "FontSize", 24)
yticks(-6:2:20)
ylabel("Choice Delta (seconds)", "FontSize", 14)
legend({"Remove me", "Fit", "95% Confidence Bounds", "Left Trials Averaged"}, "Color", 'w', "TextColor", 'k');

figure
rightMdl = fitlm(sessionBias, rightDiffMean);
plot(rightMdl)
hold on
scatter(sessionBias, rightDiffMean, 20, rightColor, 'filled')
clean_DMTS_figs
xlabel("Bias weight", "FontSize", 24)
xlim([-.6 .6])
yticks(-6:2:10)
ylabel("Choice Delta (seconds)", "FontSize", 14)
legend({"Remove me", "Fit", "95% Confidence Bounds", "Right Trials Averaged"}, "Color", 'w', "TextColor", 'k');