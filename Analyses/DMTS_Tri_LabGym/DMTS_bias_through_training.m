function biasRelationship = DMTS_bias_through_trianing(trainingSessions)

    biasByAnimal = cellfun(@(x) arrayfun(@(y) calculate_side_bias(y), x), trainingSessions, 'uni', 0);
    biasByAnimalAligned = align_training_data(trainingSessions, biasByAnimal);
    numSessions = cellfun(@(x) true(size(x)), biasByAnimal, 'uni', 0);
    sessionIdx = align_training_data(trainingSessions, numSessions);
    sessionIdx(isnan(sessionIdx)) = false;
    delayToChoiceCorrectLeft = cellfun(@(x) ...
        arrayfun(@(y) mean(y.distance_between_states('DelayOn', 'ChoiceOn', 'trialType', 'Left', 'outcome', 'Correct')), x, 'uni', 0), ...
        trainingSessions, 'uni', 0);
    delayToChoiceIncorrectLeft = cellfun(@(x) ...
        arrayfun(@(y) mean(y.distance_between_states('DelayOn', 'Punish', 'trialType', 'Left', 'outcome', 'Incorrect')), x, 'uni', 0), ...
        trainingSessions, 'uni', 0);
    delayToChoiceCorrectRight = cellfun(@(x) ...
        arrayfun(@(y) mean(y.distance_between_states('DelayOn', 'ChoiceOn', 'trialType', 'Right', 'outcome', 'Correct')), x, 'uni', 0), ...
        trainingSessions, 'uni', 0);
    delayToChoiceIncorrectRight = cellfun(@(x) ...
        arrayfun(@(y) mean(y.distance_between_states('DelayOn', 'Punish', 'trialType', 'Right', 'outcome', 'Incorrect')), x, 'uni', 0), ...
        trainingSessions, 'uni', 0);
    correctLeftAligned = nan(size(sessionIdx));
    incorrectLeftAligned = nan(size(sessionIdx));
    correctRightAligned = nan(size(sessionIdx));
    incorrectRightAligned = nan(size(sessionIdx));
    for animal = 1:numel(trainingSessions)
        dayIdx = find(sessionIdx(:, animal));
        correctLeftAligned(dayIdx, animal) = cell2mat(delayToChoiceCorrectLeft{animal});
        incorrectLeftAligned(dayIdx, animal) = cell2mat(delayToChoiceIncorrectLeft{animal});
        correctRightAligned(dayIdx, animal) = cell2mat(delayToChoiceCorrectRight{animal});
        incorrectRightAligned(dayIdx, animal) = cell2mat(delayToChoiceIncorrectRight{animal});
    end
    
    eraFraction = 1/3;
    numTrainingSessionsAll = size(sessionIdx, 1);
    sessionsPerEra = floor(numTrainingSessionsAll*eraFraction);
    eraIdx = cell(1, 3);
    eraIdx{1} = 1:sessionsPerEra;
    eraIdx{2} = sessionsPerEra + 1:sessionsPerEra * 2;
    eraIdx{3} = 2 * sessionsPerEra + 1:numTrainingSessionsAll;
    for era = 1:3
        currentIdx = eraIdx{era};
        eraBias = biasByAnimalAligned(currentIdx, :);
        leftCorrect = correctLeftAligned(currentIdx, :);
        leftIncorrect = incorrectLeftAligned(currentIdx, :);
        rightCorrect = correctRightAligned(currentIdx, :);
        rightIncorrect = incorrectRightAligned(currentIdx, :);
        hasLeft = ~isnan(leftCorrect) & ~isnan(leftIncorrect);
        biasLeft = eraBias(hasLeft);
        leftDiff = leftIncorrect(hasLeft) - leftCorrect(hasLeft);
        hasRight = ~isnan(rightCorrect) & ~isnan(rightIncorrect);
        biasRight = eraBias(hasRight);
        rightDiff = rightIncorrect(hasRight) - rightCorrect(hasRight);
        leftMdl = fitlm(biasLeft, leftDiff);
        rightMdl = fitlm(biasRight, rightDiff);
        leftIntercept(era) = leftMdl.Coefficients.Estimate(2);
        rightIntercept(era) = rightMdl.Coefficients.Estimate(2);   
        figure
        plot(leftMdl)
        figure
        plot(rightMdl)
    end
    
    for sess = 1:numTrainingSessionsAll
        sessionBias = biasByAnimalAligned(sess, :);
        leftCorrect = correctLeftAligned(sess, :);
        leftIncorrect = incorrectLeftAligned(sess, :);
        rightCorrect = correctRightAligned(sess, :);
        rightIncorrect = incorrectRightAligned(sess, :);
        hasLeft = ~isnan(leftCorrect) & ~isnan(leftIncorrect);
        biasLeft = sessionBias(hasLeft);
        leftDiff = leftIncorrect(hasLeft) - leftCorrect(hasLeft);
        hasRight = ~isnan(rightCorrect) & ~isnan(rightIncorrect);
        biasRight = sessionBias(hasRight);
        rightDiff = rightIncorrect(hasRight) - rightCorrect(hasRight);
        leftMdl = fitlm(biasLeft, leftDiff);
        rightMdl = fitlm(biasRight, rightDiff);
        leftIntercept(sess) = leftMdl.Coefficients.Estimate(2);
        rightIntercept(sess) = rightMdl.Coefficients.Estimate(2);   
    end
end

function diffStruct = bias_against_timing(sessionParser)
    diffStruct.bias = calculate_side_bias(sessionParser);
    delayToChoiceCorrectLeft = mean(sessionParser.distance_between_states ...
        ('DelayOn', 'ChoiceOn', 'trialType', 'Left', 'outcome', 'Correct'));
    delayToChoiceIncorrectLeft = mean(sessionParser.distance_between_states ...
        ('DelayOn', 'Punish', 'trialType', 'Left', 'outcome', 'Incorrect'));
    delayToChoiceCorrectRight = mean(sessionParser.distance_between_states ...
        ('DelayOn', 'ChoiceOn', 'trialType', 'Right', 'outcome', 'Correct'));
    delayToChoiceIncorrectRight = mean(sessionParser.distance_between_states ...
        ('DelayOn', 'Punish', 'trialType', 'Right', 'outcome', 'Incorrect'));
    diffStruct.left = delayToChoiceIncorrectLeft - delayToChoiceCorrectLeft;
    diffStruct.right = delayToChoiceIncorrectRight - delayToChoiceCorrectRight;
end