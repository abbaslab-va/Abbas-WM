function [correctDiff, incorrectDiff] = DMTS_tri_time_to_choice_correct_diff(sessionParser, biasType)

% Outputs the difference in time to choice arrival from delay reward for the session's preferred and non-preferred trial type.

if strcmp(biasType, 'perf')
    sessionBias = calculate_performance_bias(sessionParser);
elseif strcmp(biasType, 'side')
    sessionBias = calculate_side_bias(sessionParser);
else
    throw(MException("DMTS:BadInput", "ERROR: please input either perf or side to select bias type"))
end
delayToChoiceCorrectLeft = sessionParser.distance_between_states('DelayOn', 'ChoiceOn', 'trialType', 'Left', 'outcome', 'Correct');
delayToChoiceIncorrectLeft = sessionParser.distance_between_states('DelayOn', 'Punish', 'trialType', 'Left', 'outcome', 'Incorrect');
delayToChoiceCorrectRight = sessionParser.distance_between_states('DelayOn', 'ChoiceOn', 'trialType', 'Right', 'outcome', 'Correct');
delayToChoiceIncorrectRight = sessionParser.distance_between_states('DelayOn', 'Punish', 'trialType', 'Right', 'outcome', 'Incorrect');

if sessionBias < 0
    correctDiff = mean(delayToChoiceCorrectLeft) - mean(delayToChoiceCorrectRight);
    incorrectDiff = mean(delayToChoiceIncorrectLeft) - mean(delayToChoiceIncorrectRight);
else
    correctDiff = mean(delayToChoiceCorrectRight) - mean(delayToChoiceCorrectLeft);
    incorrectDiff = mean(delayToChoiceIncorrectRight) - mean(delayToChoiceIncorrectLeft);
end
