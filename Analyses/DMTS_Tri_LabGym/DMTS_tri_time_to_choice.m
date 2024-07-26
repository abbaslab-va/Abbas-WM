function [preferredDiff, nonPreferredDiff] = DMTS_tri_time_to_choice(sessionParser)

% sessionBias = calculate_side_bias(sessionParser);
sessionBias = calculate_performance_bias(sessionParser);
delayToChoiceCorrectLeft = sessionParser.distance_between_states('DelayOn', 'ChoiceOn', 'trialType', 'Left', 'outcome', 'Correct');
delayToChoiceIncorrectLeft = sessionParser.distance_between_states('DelayOn', 'Punish', 'trialType', 'Left', 'outcome', 'Incorrect');
delayToChoiceCorrectRight = sessionParser.distance_between_states('DelayOn', 'ChoiceOn', 'trialType', 'Right', 'outcome', 'Correct');
delayToChoiceIncorrectRight = sessionParser.distance_between_states('DelayOn', 'Punish', 'trialType', 'Right', 'outcome', 'Incorrect');

leftDiff = mean([delayToChoiceIncorrectLeft{:}]) - mean([delayToChoiceCorrectLeft{:}]);
rightDiff = mean([delayToChoiceIncorrectRight{:}]) - mean([delayToChoiceCorrectRight{:}]);

if sessionBias < 0
    preferredDiff = leftDiff;
    nonPreferredDiff = rightDiff;
else
    preferredDiff = rightDiff;
    nonPreferredDiff = leftDiff;
end
