function [preferredDiff, nonPreferredDiff] = DMTS_tri_time_to_choice(sessionParser, biasType, delayLen)

% Outputs the difference in time to choice arrival from delay reward for the session's preferred and non-preferred trial type.

if strcmp(biasType, 'perf')
    sessionBias = calculate_performance_bias(sessionParser);
elseif strcmp(biasType, 'side')
    sessionBias = calculate_side_bias(sessionParser);
else
    throw(MException("DMTS:BadInput", "ERROR: please input either perf or side to select bias type"))
end


delayToChoiceCorrectLeft = sessionParser.distance_between_states('DelayOn', 'ChoiceOn', 'trialType', 'Left', 'outcome', 'Correct', 'delayLength', delayLen);
delayToChoiceIncorrectLeft = sessionParser.distance_between_states('DelayOn', 'Punish', 'trialType', 'Left', 'outcome', 'Incorrect', 'delayLength', delayLen);
delayToChoiceCorrectRight = sessionParser.distance_between_states('DelayOn', 'ChoiceOn', 'trialType', 'Right', 'outcome', 'Correct', 'delayLength', delayLen);
delayToChoiceIncorrectRight = sessionParser.distance_between_states('DelayOn', 'Punish', 'trialType', 'Right', 'outcome', 'Incorrect', 'delayLength', delayLen);

leftDiff = mean(delayToChoiceIncorrectLeft) - mean(delayToChoiceCorrectLeft);
rightDiff = mean(delayToChoiceIncorrectRight) - mean(delayToChoiceCorrectRight);

if sessionBias < 0
    preferredDiff = leftDiff;
    nonPreferredDiff = rightDiff;
else
    preferredDiff = rightDiff;
    nonPreferredDiff = leftDiff;
end
