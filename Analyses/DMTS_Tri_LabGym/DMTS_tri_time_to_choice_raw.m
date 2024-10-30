function [preferredCorrect, preferredIncorrect, nonPreferredCorrect, nonPreferredIncorrect] = DMTS_tri_time_to_choice_raw(sessionParser, biasType, delayLen)

% Outputs the difference in time to choice arrival from delay reward for the session's preferred and non-preferred trial type.

if strcmp(biasType, 'perf')
    sessionBias = calculate_performance_bias(sessionParser);
elseif strcmp(biasType, 'side')
    sessionBias = calculate_side_bias(sessionParser);
else
    throw(MException("DMTS:BadInput", "ERROR: please input either perf or side to select bias type"))
end


delayToChoiceCorrectLeft = mean(sessionParser.distance_between_states('DelayOn', 'ChoiceOn', 'trialType', 'Left', 'outcome', 'Correct', 'delayLength', delayLen));
delayToChoiceIncorrectLeft = mean(sessionParser.distance_between_states('DelayOn', 'Punish', 'trialType', 'Left', 'outcome', 'Incorrect', 'delayLength', delayLen));
delayToChoiceCorrectRight = mean(sessionParser.distance_between_states('DelayOn', 'ChoiceOn', 'trialType', 'Right', 'outcome', 'Correct', 'delayLength', delayLen));
delayToChoiceIncorrectRight = mean(sessionParser.distance_between_states('DelayOn', 'Punish', 'trialType', 'Right', 'outcome', 'Incorrect', 'delayLength', delayLen));


if sessionBias < 0
    preferredCorrect = delayToChoiceCorrectLeft;
    preferredIncorrect = delayToChoiceIncorrectLeft;
    nonPreferredCorrect = delayToChoiceCorrectRight;
    nonPreferredIncorrect = delayToChoiceIncorrectRight;
else    
    preferredCorrect = delayToChoiceCorrectRight;
    preferredIncorrect = delayToChoiceIncorrectRight;
    nonPreferredCorrect = delayToChoiceCorrectLeft;
    nonPreferredIncorrect = delayToChoiceIncorrectLeft;
end
