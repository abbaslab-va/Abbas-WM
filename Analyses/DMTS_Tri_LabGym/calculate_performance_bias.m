function biasIdx = calculate_performance_bias(sessionParser)

    leftTrials = sessionParser.config.trialTypes.Left;
    rightTrials = sessionParser.config.trialTypes.Right;
    try
        [numTT, numCorrect] = sessionParser.performance;
        pctLeft = sum(numCorrect(leftTrials), 'omitnan')/sum(numTT(leftTrials), 'omitnan');
        pctRight = sum(numCorrect(rightTrials), 'omitnan')/sum(numTT(rightTrials), 'omitnan');
 
        biasIdx = pctRight - pctLeft;  
    catch
        biasIdx = nan;
        sessionParser.session.Info.SessionDate
        sessionParser.config.name
    end

end