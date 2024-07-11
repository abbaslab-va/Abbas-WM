function [performanceAnimals, performanceSessions] = DMTS_tri_testing_performance(managerObj, varargin)

% Accepts an ExpManager object to calculate performance
subNames = managerObj.metadata.subjects;
subIdxAll = cellfun(@(x) managerObj.subset('animal', x), subNames, 'uni', 0);
[numTT, numCorrect] = arrayfun(@(x) x.outcomes(varargin{:}), managerObj.sessions, 'uni', 0);
performanceSessions = cellfun(@(x, y) sum(x)/sum(y), numCorrect, numTT);
performanceAnimals = cellfun(@(x) mean(performanceSessions(x)), subIdxAll);

