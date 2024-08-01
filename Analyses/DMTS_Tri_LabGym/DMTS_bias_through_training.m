function biasRelationship = DMTS_bias_through_trianing(trainingSessions)

    structByAnimal = cellfun(@(x) arrayfun(@(y) bias_against_timing(y), x), trainingSessions, 'uni', 0);
    structByAnimalAligned = align_training_data(trainingSessions, structByAnimal);
    hasSession = cellfun(@(x) ~isempty(x), structByAnimalAligned);
    dataStruct = nan(size(structByAnimalAligned));
    biasByAnimalAligned = dataStruct;
    leftByAnimalAligned = dataStruct;
    rightByAnimalAligned = dataStruct;
    biasByAnimalAligned(hasSession) = cellfun(@(x) x.bias, structByAnimalAligned(hasSession));
    leftByAnimalAligned(hasSession) = cellfun(@(x) x.left, structByAnimalAligned(hasSession));
    rightByAnimalAligned(hasSession) = cellfun(@(x) x.right, structByAnimalAligned(hasSession));

    eraFraction = 1/3;
    numTrainingSessionsAll = size(structByAnimalAligned, 1);
    sessionsPerEra = floor(numTrainingSessionsAll*eraFraction);
    eraIdx = cell(1, 3);
    eraIdx{1} = 1:sessionsPerEra;
    eraIdx{2} = sessionsPerEra + 1:sessionsPerEra * 2;
    eraIdx{3} = 2 * sessionsPerEra + 1:numTrainingSessionsAll;
    for era = 1:3
        currentIdx = eraIdx{era};
        eraBias = biasByAnimalAligned(currentIdx, :);
        leftDiff = leftByAnimalAligned(currentIdx, :);
        rightDiff = rightByAnimalAligned(currentIdx, :);
        hasLeft = ~isnan(leftDiff);
        biasLeft = eraBias(hasLeft);
        leftDiff = leftDiff(hasLeft);
        hasRight = ~isnan(rightDiff);
        biasRight = eraBias(hasRight);
        rightDiff = rightDiff(hasRight);
        leftMdl = fitlm(biasLeft, leftDiff);
        rightMdl = fitlm(biasRight, rightDiff);
        leftSE(era) = leftMdl.Coefficients.SE(2);
        rightSE(era) = rightMdl.Coefficients.SE(2);
        leftIntercept(era) = leftMdl.Coefficients.Estimate(2);
        rightIntercept(era) = rightMdl.Coefficients.Estimate(2);   
        figure
        plot(leftMdl)
        figure
        plot(rightMdl)
    end
    figure
    interceptData = [leftIntercept' rightIntercept'];
    interceptBar = bar(interceptData, 'k', 'FaceAlpha', .6, 'EdgeAlpha', .6);
    hold on
    seData = [leftSE' rightSE'];
    leftX = interceptBar(1).XEndPoints;
    rightX = interceptBar(2).XEndPoints;
    errorX = [leftX; rightX]';
    errorbar(errorX, interceptData, seData, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
    clean_DMTS_figs

    for sess = 1:numTrainingSessionsAll
        sessionBias = biasByAnimalAligned(sess, :);
        leftDiff = leftByAnimalAligned(sess, :);
        rightDiff = rightByAnimalAligned(sess, :);
        hasLeft = ~isnan(leftDiff);
        biasLeft = sessionBias(hasLeft);
        leftDiff = leftDiff(hasLeft);
        hasRight = ~isnan(rightDiff);
        biasRight = sessionBias(hasRight);
        rightDiff = rightDiff(hasRight);
        leftMdl = fitlm(biasLeft, leftDiff);
        rightMdl = fitlm(biasRight, rightDiff);
        leftIntercept(sess) = leftMdl.Coefficients.Estimate(2);
        rightIntercept(sess) = rightMdl.Coefficients.Estimate(2);   
    end
    figure
    plot(smooth(leftIntercept, 5), 'r', 'LineWidth', 3);
    hold on
    plot(smooth(rightIntercept, 5), 'g', 'LineWidth', 3);
    biasRelationship = 0;

end

function diffStruct = bias_against_timing(sessionParser)
    % diffStruct.bias = calculate_side_bias(sessionParser);
    diffStruct.bias = calculate_performance_bias(sessionParser);
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