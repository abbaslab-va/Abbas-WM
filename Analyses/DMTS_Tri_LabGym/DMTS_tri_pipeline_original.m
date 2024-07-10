function DMTS_tri_testing_performance(managerObj, varargin)

% Accepts an ExpManager object to calculate performance
numSubs = numel(managerObj.metadata.subjects);
numSessions = numel(managerObj.sessions);
performanceAnimals = zeros(1, numSubs);
performanceSessions = zeros(1, numSessions);
startIdx = 0;
goodSessionsAll = false(1, numSessions);
sessionIdx = 1;
[numTT, numCorrect] = arrayfun(@(x) x.outcomes(varargin{:}), managerObj.sessions, 'uni', 0);
