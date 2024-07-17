function biasIdx = DMTS_tri_performance_bias(numTT, numCorrect)

leftTrials = [1 4 5];
rightTrials = [2 3 6];

pctLeft = sum(numCorrect(leftTrials), 'omitnan')/sum(numTT(leftTrials), 'omitnan');
pctRight = sum(numCorrect(rightTrials), 'omitnan')/sum(numTT(rightTrials), 'omitnan');

biasIdx = pctRight - pctLeft;

