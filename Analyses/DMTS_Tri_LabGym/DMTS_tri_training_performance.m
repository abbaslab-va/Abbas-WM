function DMTS_tri_training_performance(parserArray)

% 
numSubs = numel(parserArray);
numSessions = sum(cellfun(@(x) numel(x), parserArray));
performanceAnimals = zeros(1, numSubs);
performanceSessions = zeros(1, numSessions);
startIdx = 0;
goodSessionsAll = false(1, numSessions);
sessionIdx = 1;
for sub = 1:numSubs