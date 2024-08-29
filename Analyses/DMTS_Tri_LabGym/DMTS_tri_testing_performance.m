function testingPerf = DMTS_tri_testing_performance(managerObj)

% Accepts an ExpManager object to calculate performance in testing. 
% Returns a structure with the given alignment, with means by animal and session.

alignments = struct();
testingPerf = struct();
alignments(1).directional = {'Left', 'Right'};
alignments(1).samplePort = {'Sample1', 'Sample2', 'Sample3'};
alignments(1).delayPort = {'Delay1', 'Delay2', 'Delay3'};
% alignments(1).delayLength = {[0 3], [3.1 4], [4.1 5], [5.1 6], [6.1 7]};
alignments(1).delayLength = {[3.1 5], [5.1 7]};
subNames = managerObj.metadata.subjects;
subIdxAll = cellfun(@(x) managerObj.subset('animal', x), subNames, 'uni', 0);
groupings = fields(alignments);
numTrials = arrayfun(@(x) x.bpod.session.nTrials, managerObj.sessions);
% sort through alignments using PresetManager calls
for al = 1:numel(groupings)
    currentGrouping = groupings{al};
    numGroupings = numel(alignments.(currentGrouping));
    performanceSessions = cell(numGroupings, 1);
    performanceAnimals = cell(numGroupings, 1);
    for tt = 1:numGroupings
        if strcmp(currentGrouping, 'delayLength')
            currentAlignment = {'delayLength', alignments.(currentGrouping){tt}};
        else
            currentAlignment = {'trialType', alignments.(currentGrouping){tt}};
        end
        [numTT, numCorrect] = managerObj.calculate_performance(currentAlignment{:});
        performanceSessions{tt} = cellfun(@(x, y) 100*sum(x)/sum(y), numCorrect, numTT);
        performanceAnimals{tt} = cellfun(@(x) mean(performanceSessions{tt}(x)), subIdxAll);
    end
    testingPerf.(currentGrouping).animals = performanceAnimals;
    testingPerf.(currentGrouping).sessions = performanceSessions;
    testingPerf.(currentGrouping).alignments = alignments.(currentGrouping);
end
[numTT, numCorrect] = managerObj.calculate_performance();
testingPerf.all.sessions = cellfun(@(x, y) 100*sum(x)/sum(y), numCorrect, numTT);
testingPerf.all.animals = cellfun(@(x) mean(testingPerf.all.sessions(x)), subIdxAll);
testingPerf.all(1).subIdx = subIdxAll;