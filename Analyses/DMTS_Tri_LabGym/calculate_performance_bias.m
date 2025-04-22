function biasIdx = calculate_performance_bias(sessionParser)
    % Returns a value from -1:1, indicating the bias towards correctly completing
    % left trials (-1 = 100% correct left, 0% correct right) or right trials
    % (1 = 0% correct left, 100% correct right)
    
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