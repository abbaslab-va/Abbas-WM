function perfBiasData = DMTS_tri_performance_bias(parserArray)

end

function biasIdx = calculate_performance_bias(sessionParser)

    leftTrials = [1 4 5];
    rightTrials = [2 3 6];
    
    [numTT, numCorrect] = sessionParser.
    pctLeft = sum(numCorrect(leftTrials), 'omitnan')/sum(numTT(leftTrials), 'omitnan');
    pctRight = sum(numCorrect(rightTrials), 'omitnan')/sum(numTT(rightTrials), 'omitnan');
    
    biasIdx = pctRight - pctLeft;

end