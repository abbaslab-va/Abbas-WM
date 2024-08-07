% DMTS_Tri video analysis pipeline with LabGym

%% INIT
I = INI;
I.read('F:\LabGym\DMTS_Tri\matlab\config.ini')
configs = struct('path', [], 'name', [], 'date', [], 'trialTypes', I.trialTypes, 'outcomes', I.outcomes, 'startState', 'ITI');

videoDir = 'F:\LabGym\DMTS_Tri\VideoAnalyzed';
load("F:\LabGym\DMTS_Tri\matlab\labGymSessions.mat")
load("F:\LabGym\DMTS_Tri\matlab\BehaviorDataModified.mat")
numSessions = numel(labGymSessions.sessions);
subNames = fields(BehaviorData);
numSubs = numel(subNames);
taskName = 'DMTS_Tri_Training2';
correctChoiceLeft = PresetManager('event', 'choicePoke', 'outcome', 'Correct', 'trialType', 'Left', 'edges', [-1 1], 'offset', -1);
correctChoiceRight = PresetManager('event', 'choicePoke', 'outcome', 'Correct', 'trialType', 'Right', 'edges', [-1 1], 'offset', -1);
vidRes = [270 150];
for f = 1:numel(subNames)
    newName = regexprep(subNames{f}, 'NMTP', 'DMTS');
    temp.(newName) = BehaviorData.(subNames{f});
end
BehaviorData = temp;
subNames = fields(BehaviorData);
filteredSubNames = {};

behaviorColormap = brewermap(9, 'Set1');
behaviorColormap = ...
    [0 0 0;                  %     [NA - black
    behaviorColormap(2, :);  %     drink - blue
    behaviorColormap(6, :);  %     groom - black
    behaviorColormap(1, :);  %     left - red
    behaviorColormap(8, :);  %     poke - pink
    behaviorColormap(5, :);  %     rear - yellow
    behaviorColormap(9, :);  %     rest - grey
    behaviorColormap(3, :);  %     right - green
    behaviorColormap(7, :);  %     walk - brown
    ];
leftColor = behaviorColormap(4, :);
rightColor = behaviorColormap(8, :);
%%
performanceAnimals = zeros(1, numSubs);
performanceSessions = zeros(1, numSessions);
startIdx = 0;
goodSessionsAll = false(1, numSessions);
sessionIdx = 1;
for sub = 1:numSubs
    subName = subNames{sub};
    subStruct = BehaviorData.(subName).(taskName);
    numTrainingSessions = numel(subStruct);


    for sess = 1:numTrainingSessions
        bpodSession = subStruct(sess).Results;
        subConfigs = configs;
        subConfigs.name = subName;
        subConfigs.date = bpodSession.Info.SessionDate;
        trainingParser{sub, sess} = BpodParser('session', bpodSession, 'config', subConfigs);
        [numTT, numCorrect] = bpod_performance(bpodSession, 1);
        [~, numRepeats] = bpod_performance(bpodSession, 2);
        ttIncluded = size(numTT, 2);
        if ttIncluded ~= 6
            missingTT = ttIncluded + 1:6;
            numTT(missingTT) = 0;
            numCorrect(missingTT) = 0;
            numRepeats(missingTT) = 0;
            % performanceAllTraining{sub, sess} = nan(3, 6);
        end
        performanceAllTraining{sub, sess} = [numTT; numCorrect; numRepeats];
    end


    % Decoded video sessions

    minThresh = 65;
    subIdxLogical = labGymSessions.subset('animal', subName);
    subIdx = find(subIdxLogical);
    subSessions = labGymSessions.sessions(subIdxLogical);
    numSubSessions = numel(subSessions);
    behaviorByFrame = arrayfun(@(x) x.LabGym, subSessions, 'uni', 0);
    [numTT, numCorrect] = arrayfun(@(x) bpod_performance(x.bpod.session), subSessions, 'uni', 0);
    % Or alternatively
    [numTT, numCorrect] = labGymSessions.calculate_performance('animal', subName);
    subAverage = cellfun(@(x, y) sum(x)/sum(y)*100, numCorrect, numTT);
    goodSessions = subAverage >= minThresh;
    goodSessionsIdx = find(goodSessions);
    numGoodSessions = numel(goodSessionsIdx);
    if numGoodSessions >= 3
        goodSessionsAll(subIdxLogical) = goodSessions;
        filteredSubNames{end+1} = subName;
        for s = 1:numGoodSessions
            newSess = BehDat();
            whichSession = subIdx(goodSessionsIdx(s));
            newSess.copy(labGymSessions.sessions(whichSession));
            filteredSessions(sessionIdx) = newSess;
            sessionIdx = sessionIdx + 1;
        end
        coords.(subName).Choice.Correct.Left = arrayfun(@(x) x.plot_centroid('preset', correctChoiceLeft, 'plot', false), subSessions(goodSessions), 'uni', 0);
        coords.(subName).Choice.Correct.Right = arrayfun(@(x) x.plot_centroid('preset', correctChoiceRight, 'plot', false), subSessions(goodSessions), 'uni', 0);
    else
        performanceAnimals(sub) = nan;
    end


    allTT = cat(1, numTT{:});
    allCorrect = cat(1, numCorrect{:});
    behSubset = mean(allCorrect./allTT, 2) *100;

    goodSessions = behSubset >= minThresh;
    animalAverage = behSubset(goodSessions);
    animalSessions{sub} = animalAverage;
    performanceSessions(startIdx+1:startIdx+numSubSessions) = behSubset;
    performanceAnimals(sub) = mean(animalAverage);
    startIdx = startIdx + numSubSessions;
    % figure
    % hold on
    % cellfun(@(x) cellfun(@(y) scatter(y(:, 1), y(:, 2)), x), coords.(subName).Choice.Correct.Left)
    % figure
    % hold on
    % cellfun(@(x) cellfun(@(y) scatter(y(:, 1), y(:, 2)), x), coords.(subName).Choice.Correct.Right)


end

% manually remove 2 unaligned sessions
filteredSessions([17, 29]) = [];
filteredMetadata = labGymSessions.metadata;
filteredMetadata.subjects = filteredSubNames;
filteredSessions = ExpManager(filteredSessions, filteredMetadata);
filteredIdx = ismember(subNames, filteredSubNames);
% Plots

% % for session = 1:numSessions
% for session = 1:5
% for sub = 1:numSubs
%     currentSession = labGymSessions.sessions(session);
%     SessionData = currentSession.bpod;
%     subname = currentSession.info.name;
%     behaviorByFrame = currentSession.LabGym;
%     pathStruct = currentSession.info.path;
%     [~, dirName] = fileparts(pathStruct);
%     videoLoc = fullfile(pathStruct, [dirName, '.avi']);
%     plot_DMTS_rotation(choicePoke, behaviorByFrame, [-60 60])
%     currentSession.plot_centroid('preset', correctChoiceLeft)
%     currentSession.plot_centroid('preset', correctChoiceRight)
% end
%% Training
performanceTrainingFiltered = performanceAllTraining(filteredIdx, :);
trainingParserFiltered = trainingParser(filteredIdx, :);
emptyIdx = cellfun(@(x) isempty(x), performanceTrainingFiltered);
[performanceTrainingFiltered{emptyIdx}] = deal(nan(3, 6));
pctAverageTT = cellfun(@(x) sum(x(2, :))/sum(x(1, :)), performanceTrainingFiltered)*100;
figure
% hold on
% plot(pctAverageTT', 'Color', 'r', 'LineStyle', '--', 'LineWidth', .5)
trainingMeans = mean(pctAverageTT, 1, 'omitnan');
trainingSEM = std(pctAverageTT, 1, 'omitnan')./sqrt(size(pctAverageTT, 1));
shaded_error_plot(11:size(pctAverageTT, 2), trainingMeans(11:end), trainingSEM(11:end), 'k', 'k', .3)
% plot(mean(pctAverageTT, 1, 'omitnan'), 'LineWidth', 3, 'color', 'k');
clean_DMTS_figs
ylim([35 100])
yline(50, 'LineStyle', '--', 'LineWidth', 3, 'Color', 'k')

%% Training bias
maxSessions = size(trainingParserFiltered, 2);
% timeToChoiceLeftCorrect = cell(size(trainingParserFiltered));
% timeToChoiceLeftIncorrect = cell(size(trainingParserFiltered));
leftChoiceDiff = nan(size(trainingParserFiltered));
% timeToChoiceRightCorrect = cell(size(trainingParserFiltered));
% timeToChoiceRightIncorrect = cell(size(trainingParserFiltered));
rightChoiceDiff = nan(size(trainingParserFiltered));
trainingBiasIdx = cellfun(@(x) DMTS_Tri_rotational_bias(x(1, :), x(2, :)), performanceTrainingFiltered);
trainingSideVisitBias = nan(size(trainingBiasIdx));
leftIntercept = zeros(1, maxSessions);
rightIntercept = zeros(1, maxSessions);

leftInterceptSideBias = zeros(1, maxSessions);
rightInterceptSideBias = zeros(1, maxSessions);


goodDays = true(1, maxSessions);
for sess = 1:maxSessions
    dailySessions = trainingParserFiltered(:, sess);
    hasParser = cellfun(@(x) ~isempty(x), dailySessions);
    if numel(find(hasParser)) ~= 8
        goodDays(sess) = false;
        continue
    end
    trainingSideVisitBias(:, sess) = cellfun(@(x) DMTS_Tri_side_bias(x), dailySessions(hasParser));
    leftDelayCorrect = cellfun(@(x) x.state_times('DelayOn', 'trialType', 'Left', 'outcome', 'Correct', 'trialized', false, 'returnStart', true), dailySessions(hasParser), 'uni', 0);
    leftDelayIncorrect = cellfun(@(x) x.state_times('DelayOn', 'trialType', 'Left', 'outcome', 'Incorrect', 'trialized', false, 'returnStart', true), dailySessions(hasParser), 'uni', 0);
    rightDelayCorrect = cellfun(@(x) x.state_times('DelayOn', 'trialType', 'Right', 'outcome', 'Correct', 'trialized', false, 'returnStart', true), dailySessions(hasParser), 'uni', 0);
    rightDelayIncorrect = cellfun(@(x) x.state_times('DelayOn', 'trialType', 'Right', 'outcome', 'Incorrect', 'trialized', false, 'returnStart', true), dailySessions(hasParser), 'uni', 0);
    
    leftChoiceCorrect = cellfun(@(x) x.state_times('ChoiceOn', 'trialType', 'Left', 'outcome', 'Correct', 'trialized', false, 'returnStart', true), dailySessions(hasParser), 'uni', 0);
    leftChoiceIncorrect = cellfun(@(x) x.state_times('Punish', 'trialType', 'Left', 'outcome', 'Incorrect', 'trialized', false, 'returnStart', true), dailySessions(hasParser), 'uni', 0);
    rightChoiceCorrect = cellfun(@(x) x.state_times('ChoiceOn', 'trialType', 'Right', 'outcome', 'Correct', 'trialized', false, 'returnStart', true), dailySessions(hasParser), 'uni', 0);
    rightChoiceIncorrect = cellfun(@(x) x.state_times('Punish', 'trialType', 'Right', 'outcome', 'Incorrect', 'trialized', false, 'returnStart', true), dailySessions(hasParser), 'uni', 0);
    
    hasLeftDelay = cellfun(@(x, y) ~isempty(x) && ~isempty(y), leftDelayCorrect, leftDelayIncorrect);
    hasRightDelay = cellfun(@(x, y) ~isempty(x) && ~isempty(y), rightDelayCorrect, rightDelayIncorrect);
    
    timeToChoiceLeftCorrectSess = cellfun(@(w, x) cellfun(@(y, z) y - z, w, x, 'uni', 0), leftChoiceCorrect(hasLeftDelay), leftDelayCorrect(hasLeftDelay), 'uni', 0);
    timeToChoiceLeftIncorrectSess = cellfun(@(w, x) cellfun(@(y, z) y - z, w, x, 'uni', 0), leftChoiceIncorrect(hasLeftDelay), leftDelayIncorrect(hasLeftDelay), 'uni', 0);
    timeToChoiceRightCorrectSess = cellfun(@(w, x) cellfun(@(y, z) y - z, w, x, 'uni', 0), rightChoiceCorrect(hasRightDelay), rightDelayCorrect(hasRightDelay), 'uni', 0);
    timeToChoiceRightIncorrectSess = cellfun(@(w, x) cellfun(@(y, z) y - z, w, x, 'uni', 0), rightChoiceIncorrect(hasRightDelay), rightDelayIncorrect(hasRightDelay), 'uni', 0);
    timeToChoiceLeftCorrectSessMeans = cellfun(@(x) mean(cat(1, x{:})), timeToChoiceLeftCorrectSess);
    timeToChoiceLeftIncorrectSessMeans = cellfun(@(x) mean(cat(1, x{:})), timeToChoiceLeftIncorrectSess);
    timeToChoiceRightCorrectSessMeans = cellfun(@(x) mean(cat(1, x{:})), timeToChoiceRightCorrectSess);
    timeToChoiceRightIncorrectSessMeans = cellfun(@(x) mean(cat(1, x{:})), timeToChoiceRightIncorrectSess);
    leftChoiceDiff(hasLeftDelay, sess) = timeToChoiceLeftIncorrectSessMeans - timeToChoiceLeftCorrectSessMeans;
    rightChoiceDiff(hasRightDelay, sess) = timeToChoiceRightIncorrectSessMeans - timeToChoiceRightCorrectSessMeans;
    leftMdlSessSideBias = fitlm(trainingSideVisitBias(hasLeftDelay, sess), leftChoiceDiff(hasLeftDelay, sess));
    rightMdlSessSideBias = fitlm(trainingSideVisitBias(hasRightDelay, sess), rightChoiceDiff(hasRightDelay, sess));
    leftInterceptSideBias(sess) = leftMdlSessSideBias.Coefficients.Estimate(2);
    rightInterceptSideBias(sess) = rightMdlSessSideBias.Coefficients.Estimate(2);
    % figure(1)
    % plot(leftMdlSessSideBias)
    % figure(2)
    % plot(rightMdlSessSideBias)
    % pause

    leftMdlSess = fitlm(trainingBiasIdx(hasLeftDelay, sess), leftChoiceDiff(hasLeftDelay, sess));
    rightMdlSess = fitlm(trainingBiasIdx(hasRightDelay, sess), rightChoiceDiff(hasRightDelay, sess));
    leftIntercept(sess) = leftMdlSess.Coefficients.Estimate(2);
    rightIntercept(sess) = rightMdlSess.Coefficients.Estimate(2);
    % figure(1)
    % plot(leftMdlSess)
    % figure(2)
    % plot(rightMdlSess)
    % pause
    % leftChoiceDiff(hasLeftDelay, sess)
    % rightChoiceDiff(has)
    % timeToChoiceLeftCorrect(hasLeftDelay, sess) = timeToChoiceLeftCorrectSess;
    % timeToChoiceLeftIncorrect(hasLeftDelay, sess) = timeToChoiceLeftIncorrectSess;
    % timeToChoiceRightCorrect(hasRightDelay, sess) = timeToChoiceRightCorrectSess;
    % timeToChoiceRightIncorrect(hasRightDelay, sess) = timeToChoiceRightIncorrectSess;
    
end
% hasParser = cellfun(@(x) ~isempty(x), trainingParserFiltered);
% 
% 
% leftDelayCorrect = cellfun(@(x) x.state_times('DelayOn', 'trialType', 'Left', 'outcome', 'Correct', 'trialized', false, 'returnStart', true), trainingParserFiltered(hasParser), 'uni', 0);
% leftDelayIncorrect = cellfun(@(x) x.state_times('DelayOn', 'trialType', 'Left', 'outcome', 'Incorrect', 'trialized', false, 'returnStart', true), trainingParserFiltered(hasParser), 'uni', 0);
% rightDelayCorrect = cellfun(@(x) x.state_times('DelayOn', 'trialType', 'Right', 'outcome', 'Correct', 'trialized', false, 'returnStart', true), trainingParserFiltered(hasParser), 'uni', 0);
% rightDelayIncorrect = cellfun(@(x) x.state_times('DelayOn', 'trialType', 'Right', 'outcome', 'Incorrect', 'trialized', false, 'returnStart', true), trainingParserFiltered(hasParser), 'uni', 0);
% 
% leftChoiceCorrect = cellfun(@(x) x.state_times('ChoiceOn', 'trialType', 'Left', 'outcome', 'Correct', 'trialized', false, 'returnStart', true), trainingParserFiltered(hasParser), 'uni', 0);
% leftChoiceIncorrect = cellfun(@(x) x.state_times('Punish', 'trialType', 'Left', 'outcome', 'Incorrect', 'trialized', false, 'returnStart', true), trainingParserFiltered(hasParser), 'uni', 0);
% rightChoiceCorrect = cellfun(@(x) x.state_times('ChoiceOn', 'trialType', 'Right', 'outcome', 'Correct', 'trialized', false, 'returnStart', true), trainingParserFiltered(hasParser), 'uni', 0);
% rightChoiceIncorrect = cellfun(@(x) x.state_times('Punish', 'trialType', 'Right', 'outcome', 'Incorrect', 'trialized', false, 'returnStart', true), trainingParserFiltered(hasParser), 'uni', 0);
% 
% hasLeftDelayCorrect = cellfun(@(x) ~isempty(x), leftDelayCorrect);
% hasLeftDelayIncorrect = cellfun(@(x) ~isempty(x), leftDelayIncorrect);
% hasRightDelayCorrect = cellfun(@(x) ~isempty(x), rightDelayCorrect);
% 
% timeToChoiceLeftCorrect = cellfun(@(w, x) cellfun(@(y, z) z - y, w, x, 'uni', 0), leftChoiceCorrect(hasLeftDelayCorrect), leftDelayCorrect(hasLeftDelayCorrect), 'uni', 0);
% timeToChoiceLeftIncorrect
% timeToChoiceRightCorrect
% timeToChoiceRightIncorrect

preferLeftTraining = trainingSideVisitBias < 0;
preferRightTraining = trainingSideVisitBias > 0;
preferredDiff = nan(size(preferLeftTraining));
nonPreferredDiff = nan(size(preferLeftTraining));
preferredDiff(preferLeftTraining) = leftChoiceDiff(preferLeftTraining);
preferredDiff(preferRightTraining) = rightChoiceDiff(preferRightTraining);
nonPreferredDiff(preferLeftTraining) = rightChoiceDiff(preferLeftTraining);
nonPreferredDiff(preferRightTraining) = leftChoiceDiff(preferRightTraining);

absoluteBias = abs(trainingBiasIdx);
reds = linspace(0, 1, 128);
blues = linspace(1, 0, 128);
cMap = zeros(256, 3);
cMap(129:end, 1) = reds;
cMap(1:128, 3) = blues;
topColor = [.7 0 0];
bottomColor = [0 0 .7];
figure
absBiasMean = smooth(mean(absoluteBias, 1, 'omitnan'), 5);
absBiasSEM = smooth(std(absoluteBias, 1, 'omitnan')./sqrt(size(absoluteBias, 1)), 5);
shaded_error_plot(1:numel(absBiasMean), absBiasMean, absBiasSEM, 'k', 'k', .3)
clean_DMTS_figs
ylim([0 .5])
copygraphics(gcf, 'ContentType', 'vector')


%% Filter
figure

plot(smooth(mean(preferredDiff, 1, 'omitnan').*30, 5), 'k', 'LineWidth', 3)
hold on
plot(smooth(mean(nonPreferredDiff, 1, 'omitnan').*30, 5), 'Color', [.4 .4 .4], 'LineWidth', 3)
clean_DMTS_figs
ylim([-90 300])
yticks([-90:30:300])
yticklabels(cellfun(@(x) num2str(x), num2cell(-3:10), 'uni', 0))
smoothingVal = 3;
leftIntercept = leftIntercept(goodDays);
rightIntercept = rightIntercept(goodDays);
numMdlSessions = numel(leftIntercept);
numDivisions = 3;
fractionOfTraining = numMdlSessions/numDivisions;


binnedPerformanceMean = nan(1, 3);
binnedPerformanceSEM = nan(1, 3);
binnedLeftIntercept = nan(1, 3);
binnedRightIntercept = nan(1, 3);
binnedLeftInterceptSEM = nan(1, 3);
binnedRightInterceptSEM = nan(1, 3);
binnedLeftBiasMean = nan(1, 3);
binnedLeftBiasSEM = nan(1, 3);
binnedRightBiasMean = nan(1, 3);
binnedRightBiasSEM = nan(1, 3);
binnedRepeatMean = nan(1, 3);
binnedRepeatSEM = nan(1, 3);
binnedPreferredDiffMean = nan(1, 3);
binnedNonPreferredDiffMean = nan(1, 3);
binnedPreferredDiffSEM = nan(1, 3);
binnedNonPreferredDiffSEM = nan(1, 3);
eraEdges = [0 0];
binnedAbsBiasMean = nan(1, 3);
binnedAbsBiasSEM = nan(1, 3);

for era = 1:numDivisions
    eraEdges(1) = eraEdges(2) + 1;
    eraEdges(2) = eraEdges(2) + fractionOfTraining;
    roundedEdges = round(eraEdges(1)):round(eraEdges(2));
    binnedPerformanceMean(era) = mean(trainingMeans(roundedEdges));
    binnedPerformanceSEM(era) = std(trainingMeans(roundedEdges))/sqrt(numel(trainingMeans(roundedEdges)));
    binnedLeftIntercept(era) = mean(leftIntercept(roundedEdges));
    binnedLeftInterceptSEM(era) = std(leftIntercept(roundedEdges))/sqrt(numel(leftIntercept(roundedEdges)));
    binnedRightIntercept(era) = mean(rightIntercept(roundedEdges));
    binnedRightInterceptSEM(era) = std(rightIntercept(roundedEdges))/sqrt(numel(rightIntercept(roundedEdges)));
    binnedLeftBiasMean(era) = mean(trainingSideVisitBias(:, roundedEdges), 'all', 'omitnan');
    binnedLeftBiasSEM(era) = std(trainingSideVisitBias(:, roundedEdges), 0, 'all', 'omitnan')/sqrt(numel(trainingSideVisitBias(:, roundedEdges)));
    binnedRepeatMean(era) = mean(meanRepeatPunish(roundedEdges));
    binnedRepeatSEM(era) = std(meanRepeatPunish(roundedEdges))/sqrt(numel(meanRepeatPunish(roundedEdges)));
    binnedPreferredDiffMean(era) = mean(preferredDiff(:, roundedEdges), 'all', 'omitnan');
    binnedNonPreferredDiffMean(era) = mean(nonPreferredDiff(:, roundedEdges), 'all', 'omitnan');
    binnedPreferredDiffSEM(era) = std(preferredDiff(:, roundedEdges), 0, 'all', 'omitnan')/sqrt(numel(preferredDiff(:, roundedEdges)));
    binnedNonPreferredDiffSEM(era) = std(nonPreferredDiff(:, roundedEdges), 0, 'all', 'omitnan')/sqrt(numel(nonPreferredDiff(:, roundedEdges)));
    binnedAbsBiasMean(era) = mean(absoluteBias(:, roundedEdges), 'all', 'omitnan');
    binnedAbsBiasSEM(era) = std(absoluteBias(:, roundedEdges), 0, 'all', 'omitnan')/sqrt(numel(absoluteBias(:, roundedEdges)));
end
% figure
% prefBar = bar([binnedPreferredDiffMean', binnedNonPreferredDiffMean']);
% xLocsPref = prefBar(1).XEndPoints;
% xLocsNonPref = prefBar(2).XEndPoints;
% hold on
% errorbar([xLocsPref', xLocsNonPref'], [binnedPreferredDiffMean', binnedNonPreferredDiffMean'], [binnedPreferredDiffSEM', binnedNonPreferredDiffSEM'], 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
% clean_DMTS_figs
figure
bar(binnedAbsBiasMean);
hold on
errorbar(binnedAbsBiasMean, binnedAbsBiasSEM, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)

figure
bar(1:3, binnedRepeatMean)
hold on
errorbar(1:3, binnedRepeatMean, binnedRepeatSEM, 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
clean_DMTS_figs

testingSEM = std(testingPerformance)/sqrt(numel(testingPerformance));
figure
bar(1:4, [binnedPerformanceMean mean(testingPerformance)])
hold on
errorbar(1:4, [binnedPerformanceMean mean(testingPerformance)], [binnedPerformanceSEM testingSEM], 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
clean_DMTS_figs

figure
plot(1:numel(leftIntercept), smooth(leftIntercept, smoothingVal), 'Color', leftColor, 'LineWidth', 3)
hold on
plot(1:numel(rightIntercept), smooth(rightIntercept, smoothingVal), 'Color', rightColor, 'LineWidth', 3)
clean_DMTS_figs
ylim([-30 30])

leftInterceptSideBias = leftInterceptSideBias(goodDays);
rightInterceptSideBias = rightInterceptSideBias(goodDays);
figure
plot(1:numel(leftInterceptSideBias), smooth(leftInterceptSideBias, smoothingVal), 'Color', leftColor, 'LineWidth', 3)
hold on
plot(1:numel(rightInterceptSideBias), smooth(rightInterceptSideBias, smoothingVal), 'Color', rightColor, 'LineWidth', 3)
clean_DMTS_figs
ylim([-30 30])


% goodSessionsAll = performanceSessions >= minThresh & ~isnan(performanceSessions);
performanceSessionsFiltered = performanceSessions(goodSessionsAll);
goodAnimalsAll = ~isnan(performanceAnimals);
performanceAnimalsFiltered = performanceAnimals(goodAnimalsAll);
%% Animals
figure
hold on
bar(mean(performanceAnimalsFiltered), 'FaceColor', 'k', 'FaceAlpha', .5, 'EdgeColor', 'k', 'EdgeAlpha', 1)
animalSEM = std(performanceAnimalsFiltered)/sqrt(numel(performanceAnimalsFiltered));
jitterVec = (zeros(1, numel(performanceAnimalsFiltered)) + rand(1, numel(performanceAnimalsFiltered)) - .5).*.5;
scatter(ones(1, numel(performanceAnimalsFiltered)) + jitterVec, performanceAnimalsFiltered, 20, 'filled', 'r')
errorbar(mean(performanceAnimalsFiltered), animalSEM, 'vertical', 'Color','k', 'LineWidth', 1.5);
clean_DMTS_figs
set(gca, 'XTick', 1, 'XTickLabel', [])
%% Sessions
figure
hold on
bar(mean(performanceSessionsFiltered), 'FaceColor', 'k', 'FaceAlpha', .3, 'EdgeColor', 'k', 'EdgeAlpha', 1)
sessionSEM = std(performanceSessionsFiltered)/sqrt(numel(performanceSessionsFiltered));
jitterVec = (zeros(1, numel(performanceSessionsFiltered)) + rand(1, numel(performanceSessionsFiltered)) - .5).*.5;
scatter(ones(1, numel(performanceSessionsFiltered)) + jitterVec, performanceSessionsFiltered, 20, 'filled', 'r')
errorbar(mean(performanceSessionsFiltered), sessionSEM, 'vertical', 'Color','k', 'LineWidth', 1.5)
clean_DMTS_figs
set(gca, 'XTick', 1, 'XTickLabel', [])
clear jitterVec
%% Test bar all animals
figure
hold on
goodAnimals = cellfun(@(x, y) ~isempty(x) && numel(x) > 2, animalSessions);
animalSessions = animalSessions(goodAnimals);
% colorPalette = brewermap(numel(animalSessions), 'Set2');
% dotColor = num2cell(colorPalette, 2)';
meanAll = cellfun(@(x) mean(x), animalSessions);
semAll = cellfun(@(x) std(x)/sqrt(numel(x)), animalSessions);
xOffset = num2cell(1:numel(animalSessions));
jitterVecAll = cellfun(@(x) (zeros(1, numel(x)) + rand(1, numel(x)) - .5).*.5, animalSessions, 'uni', 0);
scatterX = cellfun(@(x, y, z) zeros(1, numel(x)) + y + z, animalSessions, xOffset, jitterVecAll, 'uni', 0);
scatterY = cellfun(@(x, y) x + y, animalSessions, jitterVecAll, 'uni', 0);

averageBar = bar(meanAll, 'facecolor', 'flat', 'FaceColor', 'k', 'FaceAlpha', .4, 'EdgeColor', 'none');
% averageBar.CData = colorPalette;
cellfun(@(x, y) scatter(x, y, 20, 'k', 'filled'), scatterX, animalSessions)
errorbar(meanAll, semAll, 'vertical', 'Color','k', 'LineWidth', 3, 'LineStyle', 'none')
xlim([.5, numel(animalSessions) + .5])
ylim([35 100])
clean_DMTS_figs
yline(50, 'LineStyle', '--', 'LineWidth', 3, 'Color', 'k')
% cellfun(@(x) scatter())

%% Sample Port
sampleNames = {'Sample1', 'Sample2', 'Sample3'};
for sample = 1:numel(sampleNames)
    sampleName = sampleNames{sample};
    ttPerf.(sampleName).animals = [];
    for sub = find(goodAnimals)
        subName = subNames{sub};
        subSessions = labGymSessions.subset('animal', subName);
        validSessions = subSessions & goodSessionsAll;
        [numTT, numCorrect] = arrayfun(@(x) x.outcomes('trialType', sampleName), labGymSessions.sessions(validSessions), 'uni', 0);
        % [numTT, numCorrect] = labGymSessions.performance('trialType', sampleName);
        numTT = cat(2, numTT{:});
        numCorrect = cat(2, numCorrect{:});
        ttPerf.(sampleName).animals(end+1) = sum(numCorrect)/sum(numTT);
        ttPerf.(sampleName).animals(isnan(ttPerf.(sampleName).animals)) = [];
    end
    [numTT, numCorrect] = arrayfun(@(x) x.outcomes('trialType', sampleName), labGymSessions.sessions(goodSessionsAll), 'uni', 0);
    ttPerf.(sampleName).sessions = cellfun(@(x, y) sum(x)/sum(y), numCorrect, numTT);

    animalMeansSample(sample) = mean(ttPerf.(sampleName).animals);
    animalSEMSample(sample) = std(ttPerf.(sampleName).animals)/sqrt(numel(ttPerf.(sampleName).animals));
    jitterVec{sample} = (zeros(1, numel(ttPerf.(sampleName).animals)) + rand(1, numel(ttPerf.(sampleName).animals)) - .5).*.5;
    scatterPts{sample} = ttPerf.(sampleName).animals;

    sessionMeansSample(sample) = mean(ttPerf.(sampleName).sessions);
    sessionSEMSample(sample) = std(ttPerf.(sampleName).sessions)/sqrt(numel(ttPerf.(sampleName).sessions));
    jitterVecSession{sample} = (zeros(1, numel(ttPerf.(sampleName).sessions)) + rand(1, numel(ttPerf.(sampleName).sessions)) - .5).*.5;
    scatterPtsSession{sample} = ttPerf.(sampleName).sessions;
end

figure
hold on
bar(animalMeansSample, 'FaceColor', '#33DBFF', 'FaceAlpha', .4)
for sample = 1:3
    scatter(zeros(1, numel(scatterPts{sample})) + sample + jitterVec{sample}, scatterPts{sample}, 20, 'k', 'filled')
    errorbar(sample, animalMeansSample(sample), animalSEMSample(sample), 'vertical', 'Color','k', 'LineWidth', 3);
end
clean_DMTS_figs
figure
hold on
bar(sessionMeansSample, 'FaceColor', '#33DBFF', 'FaceAlpha', .4)
for sample = 1:3
    scatter(zeros(1, numel(scatterPtsSession{sample})) + sample + jitterVecSession{sample}, scatterPtsSession{sample}, 20, 'k', 'filled')
    errorbar(sample, sessionMeansSample(sample), sessionSEMSample(sample), 'vertical', 'Color','k', 'LineWidth', 3);
end
clean_DMTS_figs
%% Delay Port
delayNames = {'Delay1', 'Delay2', 'Delay3'};
for delay = 1:numel(delayNames)
    delayName = delayNames{delay};
    ttPerf.(delayName).animals = [];
    for sub = find(goodAnimals)
        subName = subNames{sub};
        subSessions = labGymSessions.subset('animal', subName);
        validSessions = subSessions & goodSessionsAll;
        [numTT, numCorrect] = arrayfun(@(x) x.outcomes('trialType', delayName), labGymSessions.sessions(validSessions), 'uni', 0);
        numTT = cat(2, numTT{:});
        numCorrect = cat(2, numCorrect{:});
        ttPerf.(delayName).animals(end+1) = sum(numCorrect)/sum(numTT);
        ttPerf.(delayName).animals(isnan(ttPerf.(delayName).animals)) = [];

    end
    [numTT, numCorrect] = arrayfun(@(x) x.outcomes('trialType', delayName), labGymSessions.sessions(goodSessionsAll), 'uni', 0);
    ttPerf.(delayName).sessions = cellfun(@(x, y) sum(x)/sum(y), numCorrect, numTT);
    
    animalMeansDelayPort(delay) = mean(ttPerf.(delayName).animals);
    animalSEMDelayPort(delay) = std(ttPerf.(delayName).animals)/sqrt(numel(ttPerf.(delayName).animals));
    jitterVec{delay} = (zeros(1, numel(ttPerf.(delayName).animals)) + rand(1, numel(ttPerf.(delayName).animals)) - .5).*.5;
    scatterPts{delay} = ttPerf.(delayName).animals;

    sessionMeansDelayPort(delay) = mean(ttPerf.(delayName).sessions);
    sessionSEMDelayPort(delay) = std(ttPerf.(delayName).sessions)/sqrt(numel(ttPerf.(delayName).sessions));
    jitterVecSession{delay} = (zeros(1, numel(ttPerf.(delayName).sessions)) + rand(1, numel(ttPerf.(delayName).sessions)) - .5).*.5;
    scatterPtsSession{delay} = ttPerf.(delayName).sessions;
end

figure
hold on
bar(animalMeansDelayPort, 'FaceColor', '#BD33FF', 'FaceAlpha', .4)
for delay = 1:3
    scatter(zeros(1, numel(scatterPts{delay})) + delay + jitterVec{delay}, scatterPts{delay}, 20, 'k', 'filled')
    errorbar(delay, animalMeansDelayPort(delay), animalSEMDelayPort(delay), 'vertical', 'Color','k', 'LineWidth', 3);
end
clean_DMTS_figs

figure
hold on
bar(sessionMeansDelayPort, 'FaceColor', '#BD33FF', 'FaceAlpha', .4)
for delay = 1:3
    scatter(zeros(1, numel(scatterPtsSession{delay})) + delay + jitterVecSession{delay}, scatterPtsSession{delay}, 20, 'k', 'filled')
    errorbar(delay, sessionMeansDelayPort(delay), sessionSEMDelayPort(delay), 'vertical', 'Color', 'k', 'LineWidth', 3);
end
clean_DMTS_figs

%% Rotation

rotNames = {'Left', 'Right'};
for rot = 1:numel(rotNames)
    rotName = rotNames{rot};
    ttPerf.(rotName).animals = [];
    for sub = find(goodAnimals)
        subName = subNames{sub};
        subSessions = labGymSessions.subset('animal', subName);
        validSessions = subSessions & goodSessionsAll;
        [numTT, numCorrect] = arrayfun(@(x) x.outcomes('trialType', rotName), labGymSessions.sessions(validSessions), 'uni', 0);
        numTT = cat(2, numTT{:});
        numCorrect = cat(2, numCorrect{:});
        ttPerf.(rotName).animals(end+1) = sum(numCorrect)/sum(numTT);
        ttPerf.(rotName).animals(isnan(ttPerf.(rotName).animals)) = [];

    end
    [numTT, numCorrect] = arrayfun(@(x) x.outcomes('trialType', rotName), labGymSessions.sessions(goodSessionsAll), 'uni', 0);
    ttPerf.(rotName).sessions = cellfun(@(x, y) sum(x)/sum(y), numCorrect, numTT);
    
    animalMeansRot(rot) = mean(ttPerf.(rotName).animals);
    animalSEMRot(rot) = std(ttPerf.(rotName).animals)/sqrt(numel(ttPerf.(rotName).animals));
    jitterVec{rot} = (zeros(1, numel(ttPerf.(rotName).animals)) + rand(1, numel(ttPerf.(rotName).animals)) - .5).*.5;
    scatterPts{rot} = ttPerf.(rotName).animals;

    sessionMeansRot(rot) = mean(ttPerf.(rotName).sessions);
    sessionSEMRot(rot) = std(ttPerf.(rotName).sessions)/sqrt(numel(ttPerf.(rotName).sessions));
    jitterVecSession{rot} = (zeros(1, numel(ttPerf.(rotName).sessions)) + rand(1, numel(ttPerf.(rotName).sessions)) - .5).*.5;
    scatterPtsSession{rot} = ttPerf.(rotName).sessions;
end

figure
hold on
bar(1, animalMeansRot(1), 'FaceColor', leftColor, 'FaceAlpha', .6)
bar(2, animalMeansRot(2), 'FaceColor', rightColor, 'FaceAlpha', .6)
for rot = 1:2
    scatter(zeros(1, numel(scatterPts{rot})) + rot + jitterVec{rot}, scatterPts{rot}, 20, 'k', 'filled')
    errorbar(rot, animalMeansRot(rot), animalSEMRot(rot), 'vertical', 'Color','k', 'LineWidth', 3);
end
clean_DMTS_figs

figure
hold on
bar(1, sessionMeansRot(1), 'FaceColor', leftColor, 'FaceAlpha', .6)
bar(2, sessionMeansRot(2), 'FaceColor', rightColor, 'FaceAlpha', .6)
for rot = 1:2
    scatter(zeros(1, numel(scatterPtsSession{rot})) + rot + jitterVecSession{rot}, scatterPtsSession{rot}, 20, 'k', 'filled')
    errorbar(rot, sessionMeansRot(rot), sessionSEMRot(rot), 'vertical', 'Color', 'k', 'LineWidth', 3);
end
clean_DMTS_figs

%% Delay Length

delayBins = {[0 3], [3.1 4], [4.1 5], [5.1 6], [6.1 7]};
for len = 1:numel(delayBins)
    delayLen = delayBins{len};
    delayName = ['range_' regexprep(num2str(delayLen), '\s+', '_')];
    delayName = regexprep(delayName, '.1', '');
    ttPerf.(delayName).animals = [];
    [numTT, numCorrect] = labGymSessions.calculate_performance('delayLength', delayLen);
    for sub = 1:numel(subNames)
        subName = subNames{sub};
        subSessions = labGymSessions.subset('animal', subName);
        validSessions = subSessions & goodSessionsAll;
        numTTAnimal = numTT(validSessions);
        numCorrectAnimal = numCorrect(validSessions);
        numTTAnimal = cat(2, numTTAnimal{:});
        numCorrectAnimal = cat(2, numCorrectAnimal{:});
        ttPerf.(delayName).animals(end+1) = sum(numCorrectAnimal)/sum(numTTAnimal);
        ttPerf.(delayName).animals(isnan(ttPerf.(delayName).animals)) = [];
    end

    ttPerf.(delayName).sessions = cellfun(@(x, y) sum(x)/sum(y), numCorrect(goodSessionsAll), numTT(goodSessionsAll));

    animalMeansDelayLength(len) = mean(ttPerf.(delayName).animals);
    animalSEMDelayLength(len) = std(ttPerf.(delayName).animals)/sqrt(numel(ttPerf.(delayName).animals));
    jitterVec{len} = (zeros(1, numel(ttPerf.(delayName).animals)) + rand(1, numel(ttPerf.(delayName).animals)) - .5).*.5;
    scatterPts{len} = ttPerf.(delayName).animals;

    sessionMeansDelayLength(len) = mean(ttPerf.(delayName).sessions);
    sessionSEMDelayLength(len) = std(ttPerf.(delayName).sessions)/sqrt(numel(ttPerf.(delayName).sessions));
    jitterVecSession{len} = (zeros(1, numel(ttPerf.(delayName).sessions)) + rand(1, numel(ttPerf.(delayName).sessions)) - .5).*.5;
    scatterPtsSession{len} = ttPerf.(delayName).sessions;
end

figure
hold on
bar(animalMeansDelayLength, 'k', 'FaceAlpha', .6)
for len = 1:numel(animalMeansDelayLength)
    scatter(zeros(1, numel(scatterPts{len})) + len + jitterVec{len}, scatterPts{len}, 20, 'k', 'filled')
    errorbar(len, animalMeansDelayLength(len), animalSEMDelayLength(len), 'vertical', 'Color','k', 'LineWidth', 3);
end
clean_DMTS_figs

figure
hold on
bar(sessionMeansDelayLength, 'k', 'FaceAlpha', .6)
for len = 1:numel(sessionMeansDelayLength)
    scatter(zeros(1, numel(scatterPtsSession{len})) + len + jitterVecSession{len}, scatterPtsSession{len}, 20, 'k', 'filled')
    errorbar(len, sessionMeansDelayLength(len), sessionSEMDelayLength(len), 'vertical', 'Color', 'k', 'LineWidth', 3);
end
clean_DMTS_figs

%% Delay figure for grant

loBin = 2;
hiBin = 5;
goodBins = [loBin hiBin];
lowVsHiDelayMean = sessionMeansDelayLength(goodBins);
lowVsHiDelayScatter = [scatterPtsSession{loBin} scatterPtsSession{hiBin}];
figure
hold on
bar(sessionMeansDelayLength(goodBins), 'k', 'FaceAlpha', .6)
xVal = 1;
for len = goodBins
    scatter(zeros(1, numel(scatterPtsSession{len})) + xVal + jitterVecSession{len}, scatterPtsSession{len}, 20, 'k', 'filled')
    errorbar(xVal, sessionMeansDelayLength(len), sessionSEMDelayLength(len), 'vertical', 'Color', 'k', 'LineWidth', 3);
    xVal = xVal + 1;
end
clean_DMTS_figs
xticks([1 2])
xticklabels({'Low', 'High'});
xlabel('Delay Length')
yticks([.2 .4 .6 .8 1])
yticklabels({'20', '40', '60', '80', '100'});
ylabel('Percent Correct')
title('Performance by Delay Length')
%%% Strategy

%% Left vs Right rotation against performance

%% Port arrival and departure

%% HCTSA
% subjectCell = filteredSessions.metadata.subjects;
% % subjectCell = {'DMTS_5_2'};
% 
% samplePoke = PresetManager('event', 'samplePoke', 'edges', [0 3]);
% delayApproach = PresetManager('event', 'delayPoke', 'edges', [-1 0]);
% delayStart = PresetManager('event', 'delayPoke', 'edges', [0 3]);
% delayEnd = PresetManager('event', 'delayReward', 'edges', [-2 0]);
% choiceApproach = PresetManager('event', 'choicePoke', 'edges', [-1 0]);
% %% position HCTSA
% for s = 1:numel(subjectCell)
% % for s = 1
%     subName = subjectCell{s};
%     filteredSessions.hctsa_position('preset', choiceApproach, 'trialType', {'Left', 'Right'}, 'animals', subName);
%     figure
%     tiledlayout(3, 4);
%     sgtitle(subName)
%     nexttile
%     filteredSessions.hctsa_position('preset', samplePoke, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Left', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Left Sample Poke: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_position('preset', samplePoke, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Right', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Right Sample Poke: ' gca().Title.String])
%     % nexttile
%     % filteredSessions.hctsa_position('preset', delayApproach, 'trialType', {'Sample1', 'Sample2', 'Sample3'}, 'animals', subName, 'panel', gca);
%     % nexttile
%     % filteredSessions.hctsa_position('preset', delayApproach, 'trialType', {'Left', 'Right'}, 'animals', subName, 'panel', gca);
%     nexttile
%     filteredSessions.hctsa_position('preset', delayApproach, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Left', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Left Delay Approach: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_position('preset', delayApproach, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Right', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Right Delay Approach: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_position('preset', delayStart, 'trialType', {'Sample1', 'Sample2', 'Sample3'}, 'animals', subName, 'panel', gca);
%     title(['Sample Port Delay Start: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_position('preset', delayStart, 'trialType', {'Left', 'Right'}, 'animals', subName, 'panel', gca);
%     title(['Left/Right Delay Start: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_position('preset', delayStart, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Left', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Left Delay Start: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_position('preset', delayStart, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Right', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Right Delay Start: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_position('preset', delayEnd, 'trialType', {'Sample1', 'Sample2', 'Sample3'}, 'animals', subName, 'panel', gca);
%     title(['Sample port Delay End: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_position('preset', delayEnd, 'trialType', {'Left', 'Right'}, 'animals', subName, 'panel', gca);
%     title(['Left/Right Delay End: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_position('preset', delayEnd, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Left', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Left Delay End: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_position('preset', delayEnd, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Right', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Right Delay End: ' gca().Title.String])
%     % pause
% end
% 
% %% behavior HCTSA
% for s = 1:numel(subjectCell)
% % for s = 8
%     subName = subjectCell{s};
%     filteredSessions.hctsa_behavior('preset', choiceApproach, 'trialType', {'Left', 'Right'}, 'animals', subName);
%     figure
%     tiledlayout(3, 4);
%     sgtitle(subName)
%     nexttile
%     filteredSessions.hctsa_behavior('preset', samplePoke, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Left', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Left Sample Poke: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_behavior('preset', samplePoke, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Right', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Right Sample Poke: ' gca().Title.String])
%     % nexttile
%     % filteredSessions.hctsa_behavior('preset', delayApproach, 'trialType', {'Sample1', 'Sample2', 'Sample3'}, 'animals', subName, 'panel', gca);
%     % nexttile
%     % filteredSessions.hctsa_behavior('preset', delayApproach, 'trialType', {'Left', 'Right'}, 'animals', subName, 'panel', gca);
%     nexttile
%     filteredSessions.hctsa_behavior('preset', delayApproach, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Left', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Left Delay Approach: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_behavior('preset', delayApproach, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Right', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Right Delay Approach: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_behavior('preset', delayStart, 'trialType', {'Sample1', 'Sample2', 'Sample3'}, 'animals', subName, 'panel', gca);
%     title(['Sample port Delay Start: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_behavior('preset', delayStart, 'trialType', {'Left', 'Right'}, 'animals', subName, 'panel', gca);
%     title(['Left/Right Delay Start: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_behavior('preset', delayStart, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Left', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Left Delay Start: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_behavior('preset', delayStart, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Right', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Right Delay Start: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_behavior('preset', delayEnd, 'trialType', {'Sample1', 'Sample2', 'Sample3'}, 'animals', subName, 'panel', gca);
%     title(['Sample port Delay End: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_behavior('preset', delayEnd, 'trialType', {'Left', 'Right'}, 'animals', subName, 'panel', gca);
%     title(['Left/Right Delay End: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_behavior('preset', delayEnd, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Left', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Left Delay End: ' gca().Title.String])
%     nexttile
%     filteredSessions.hctsa_behavior('preset', delayEnd, 'outcome', {'Correct', 'Incorrect'}, 'trialType', 'Right', 'animals', subName, 'panel', gca);
%     title(['Correct/Incorrect Right Delay End: ' gca().Title.String])
% end

%% Trial motivation?
subIdxAll = cellfun(@(x) filteredSessions.subset('animal', x), filteredSubNames, 'uni', 0);
sampleToDelayCorrect = arrayfun(@(x) x.distance_between_events('samplePoke', 'delayPoke', ...
    'outcome', 'Correct', 'trialized', false), filteredSessions.sessions, 'uni', 0);
sampleToDelayIncorrect = arrayfun(@(x) x.distance_between_events('samplePoke', 'delayPoke', ...
    'outcome', 'Incorrect', 'trialized', false), filteredSessions.sessions, 'uni', 0);

sampleToDelayCorrectMeans = cellfun(@(x) mean(x), sampleToDelayCorrect);
sampleToDelayCorrectStd = cellfun(@(x) std(x), sampleToDelayCorrect);
sampleToDelayIncorrectMeans = cellfun(@(x) mean(x), sampleToDelayIncorrect);
sampleToDelayIncorrectStd = cellfun(@(x) std(x), sampleToDelayIncorrect);


sampleToDelayCorrectLeft = arrayfun(@(x) x.distance_between_events('samplePoke', 'delayPoke', ...
    'outcome', 'Correct', 'trialType', 'Left', 'trialized', false), filteredSessions.sessions, 'uni', 0);
sampleToDelayIncorrectLeft = arrayfun(@(x) x.distance_between_events('samplePoke', 'delayPoke', ...
    'outcome', 'Incorrect', 'trialType', 'Left', 'trialized', false), filteredSessions.sessions, 'uni', 0);
sampleToDelayCorrectRight = arrayfun(@(x) x.distance_between_events('samplePoke', 'delayPoke', ...
    'outcome', 'Correct', 'trialType', 'Right', 'trialized', false), filteredSessions.sessions, 'uni', 0);
sampleToDelayIncorrectRight = arrayfun(@(x) x.distance_between_events('samplePoke', 'delayPoke', ...
    'outcome', 'Incorrect', 'trialType', 'Right', 'trialized', false), filteredSessions.sessions, 'uni', 0);

sampleToDelayCorrectMeansLeft = cellfun(@(x) mean(x), sampleToDelayCorrectLeft);
sampleToDelayCorrectStdLeft = cellfun(@(x) std(x), sampleToDelayCorrectLeft);
sampleToDelayIncorrectMeansLeft = cellfun(@(x) mean(x), sampleToDelayIncorrectLeft);
sampleToDelayIncorrectStdLeft = cellfun(@(x) std(x), sampleToDelayIncorrectLeft);
sampleToDelayCorrectMeansRight = cellfun(@(x) mean(x), sampleToDelayCorrectRight);
sampleToDelayCorrectStdRight = cellfun(@(x) std(x), sampleToDelayCorrectRight);
sampleToDelayIncorrectMeansRight = cellfun(@(x) mean(x), sampleToDelayIncorrectRight);
sampleToDelayIncorrectStdRight = cellfun(@(x) std(x), sampleToDelayIncorrectRight);

bar_and_scatter({sampleToDelayCorrectMeansLeft, sampleToDelayIncorrectMeansLeft, ...
    sampleToDelayCorrectMeansRight, sampleToDelayIncorrectMeansRight})
for sub = 1:numel(filteredSubNames)
    currentSubIdx = subIdxAll{sub};
    bar_and_scatter({sampleToDelayCorrectMeansLeft(currentSubIdx), sampleToDelayIncorrectMeansLeft(currentSubIdx), ...
        sampleToDelayCorrectMeansRight(currentSubIdx), sampleToDelayIncorrectMeansRight(currentSubIdx)})
    xticks(1:4)
    xticklabels({'Correct Left', 'Incorrect Left', 'Correct Right', 'Incorrect Right'})
    xtickangle(45)
    xlabel('Trial Type + Outcome')
    ylabel('Frames elapsed')
    title(['Sample to Delay time for ' filteredSubNames{sub}])
    % if meanBiasAll(sub) > 0
    %     set(gca, 'Color', [0 0 meanBiasAll(sub)])
    % else
    %     set(gca, 'Color', [abs(meanBiasAll(sub)) 0 0])
    % end

end

delayToChoiceCorrect = arrayfun(@(x) x.distance_between_events('delayReward', 'choicePoke', ...
    'outcome', 'Correct', 'trialized', false), filteredSessions.sessions, 'uni', 0);
delayToChoiceIncorrect = arrayfun(@(x) x.distance_between_events('delayReward', 'choicePoke', ...
    'outcome', 'Incorrect', 'trialized', false), filteredSessions.sessions, 'uni', 0);

delayToChoiceCorrectMeans = cellfun(@(x) mean(x), delayToChoiceCorrect);
delayToChoiceCorrectStd = cellfun(@(x) std(x), delayToChoiceCorrect);
delayToChoiceIncorrectMeans = cellfun(@(x) mean(x), delayToChoiceIncorrect);
delayToChoiceIncorrectStd = cellfun(@(x) std(x), delayToChoiceIncorrect);

bar_and_scatter({sampleToDelayCorrectMeans, sampleToDelayIncorrectMeans})
bar_and_scatter({delayToChoiceCorrectMeans, delayToChoiceIncorrectMeans})

delayToChoiceCorrectLeft = arrayfun(@(x) x.distance_between_events('delayReward', 'choicePoke', ...
    'outcome', 'Correct', 'trialType', 'Left', 'trialized', false), filteredSessions.sessions, 'uni', 0);
delayToChoiceIncorrectLeft = arrayfun(@(x) x.distance_between_events('delayReward', 'choicePoke', ...
    'outcome', 'Incorrect', 'trialType', 'Left', 'trialized', false), filteredSessions.sessions, 'uni', 0);
delayToChoiceCorrectRight = arrayfun(@(x) x.distance_between_events('delayReward', 'choicePoke', ...
    'outcome', 'Correct', 'trialType', 'Right', 'trialized', false), filteredSessions.sessions, 'uni', 0);
delayToChoiceIncorrectRight = arrayfun(@(x) x.distance_between_events('delayReward', 'choicePoke', ...
    'outcome', 'Incorrect', 'trialType', 'Right', 'trialized', false), filteredSessions.sessions, 'uni', 0);

delayToChoiceCorrectMeansLeft = cellfun(@(x) mean(x), delayToChoiceCorrectLeft);
delayToChoiceCorrectStdLeft = cellfun(@(x) std(x), delayToChoiceCorrectLeft);
delayToChoiceIncorrectMeansLeft = cellfun(@(x) mean(x), delayToChoiceIncorrectLeft);
delayToChoiceIncorrectStdLeft = cellfun(@(x) std(x), delayToChoiceIncorrectLeft);
delayToChoiceCorrectMeansRight = cellfun(@(x) mean(x), delayToChoiceCorrectRight);
delayToChoiceCorrectStdRight = cellfun(@(x) std(x), delayToChoiceCorrectRight);
delayToChoiceIncorrectMeansRight = cellfun(@(x) mean(x), delayToChoiceIncorrectRight);
delayToChoiceIncorrectStdRight = cellfun(@(x) std(x), delayToChoiceIncorrectRight);

for sub = 1:numel(filteredSubNames)
    currentSubIdx = subIdxAll{sub};
    bar_and_scatter({delayToChoiceCorrectMeansLeft(currentSubIdx), delayToChoiceIncorrectMeansLeft(currentSubIdx), ...
        delayToChoiceCorrectMeansRight(currentSubIdx), delayToChoiceIncorrectMeansRight(currentSubIdx)})
    % if meanBiasAll(sub) > 0
    %     set(gca, 'Color', [0 0 meanBiasAll(sub)])
    % else
    %     set(gca, 'Color', [abs(meanBiasAll(sub)) 0 0])
    % end
    xticks(1:4)
    xticklabels({'Correct Left', 'Incorrect Left', 'Correct Right', 'Incorrect Right'})
    xtickangle(45)
    xlabel('Trial Type + Outcome')
    ylabel('Frames elapsed')
    title(['Delay to Choice time for ' filteredSubNames{sub}])
end
% 
% 
bar_and_scatter({delayToChoiceCorrectMeansLeft, delayToChoiceIncorrectMeansLeft, ...
    delayToChoiceCorrectMeansRight, delayToChoiceIncorrectMeansRight})
xticks(1:4)
xticklabels({'Correct Left', 'Incorrect Left', 'Correct Right', 'Incorrect Right'})
xtickangle(45)
xlabel('Trial Type + Outcome')
ylabel('Frames elapsed')
title(['Delay to Choice time for ' filteredSubNames{sub}])

%% Side visit bias
% leftVisits = arrayfun(@(x) x.bpod.state_times(''), filteredSessions.sessions, 'uni', 0);
% rightVisits = arrayfun(@(x) x.bpod.state_times(), filteredSessions.sessions);

%% TrialType Bias

[numTT, numCorrect] = filteredSessions.calculate_performance;
sessionBias = cellfun(@(x, y) DMTS_Tri_rotational_bias(x, y), numTT, numCorrect);
sideVisitBias = arrayfun(@(x) DMTS_Tri_side_bias(x.bpod), filteredSessions.sessions);

biasRelationship = fitlm(sessionBias, sideVisitBias);
plot(biasRelationship)
hold on
subColors = brewermap(8, 'Accent');
for sub = 1:numel(subIdxAll)
    subSessions = subIdxAll{sub};
    subColor = subColors(sub, :);
    scatter(sessionBias(subSessions), sideVisitBias(subSessions), ...
        20, 'filled', 'k')
    % scatter(sessionBias(subSessions), sideVisitBias(subSessions), ...
    %     20, 'MarkerFaceColor', subColor, 'MarkerEdgeColor', subColor)
end
clean_DMTS_figs
xlabel("Directional performance bias")
ylabel("Side visit bias")
l = legend({"Remove me", "Fit", "95% Confidence Bounds", "Sessions"}, "Color", 'w', "TextColor", 'k')

testingPerformance = cellfun(@(x, y) mean((x./y)*100), numCorrect, numTT);
% sideBiasPerformance = fitlm(sideVisitBias, testingPerformance);
% figure
% % plot(sideBiasPerformance)
% p = polyfit(sideVisitBias, testingPerformance, 2);
% x1 = linspace(-1, 1);
% y1 = polyval(p, x1);
% plot(x1, y1)
% hold on
% scatter(sideVisitBias, testingPerformance, 10, 'r', 'filled')
% xlabel("Side visit bias")
% ylabel("Session Performance")

leftDiffMean = delayToChoiceIncorrectMeansLeft - delayToChoiceCorrectMeansLeft;
rightDiffMean = delayToChoiceIncorrectMeansRight - delayToChoiceCorrectMeansRight;
preferLeft = sideVisitBias < 0;
preferRight = sideVisitBias > 0;
preferLeftDiff = leftDiffMean(preferLeft);
preferRightDiff = rightDiffMean(preferRight);
leftBins = discretize(sessionBias(preferLeft), -1:.1:0);
rightBins = discretize(sessionBias(preferRight), 0:.1:1);
histAll = zeros(1, 20);
for lb = 1:10
    histAll(lb) = mean(preferLeftDiff(leftBins == lb));
end
for rb = 1:10
    histAll(rb+10) = mean(preferRightDiff(rightBins ==  rb));
end
preferLeftDiffLeftMean = mean(leftDiffMean(preferLeft), 'omitnan')./30;
preferLeftDiffRightMean = mean(rightDiffMean(preferLeft), 'omitnan')./30;
preferRightDiffRightMean = mean(rightDiffMean(preferRight), 'omitnan')./30;
preferRightDiffLeftMean = mean(leftDiffMean(preferRight), 'omitnan')./30;
preferredDiffTestingMean = mean([preferLeftDiffLeftMean, preferRightDiffRightMean]);
nonPreferredDiffTestingMean = mean([preferLeftDiffRightMean, preferRightDiffLeftMean]);
preferredDiffTestingSEM = std([preferLeftDiffLeftMean, preferRightDiffRightMean])/sqrt(numel([preferLeftDiffLeftMean, preferRightDiffRightMean]));
nonPreferredDiffTestingSEM = std([preferLeftDiffRightMean, preferRightDiffLeftMean])/sqrt(numel([preferLeftDiffRightMean, preferRightDiffLeftMean]));

figure
prefY = [binnedPreferredDiffMean, preferredDiffTestingMean]';
nonPrefY = [binnedNonPreferredDiffMean, nonPreferredDiffTestingMean]';
prefSEM = [binnedPreferredDiffSEM, preferredDiffTestingSEM]';
nonPrefSEM = [binnedNonPreferredDiffSEM, nonPreferredDiffTestingSEM]';

prefBar = bar([prefY, nonPrefY]);
xLocsPref = prefBar(1).XEndPoints;
xLocsNonPref = prefBar(2).XEndPoints;
hold on
errorbar([xLocsPref', xLocsNonPref'], [prefY, nonPrefY], [prefSEM, nonPrefSEM], 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1.5)
clean_DMTS_figs

figure
preferenceFig = bar([mean([preferLeftDiffLeftMean, preferRightDiffRightMean]), mean([preferLeftDiffRightMean, preferRightDiffLeftMean])], ...
    'FaceColor', 'k');
clean_DMTS_figs
xticklabels({'Preferred', 'Non-Preferred'});
xtickangle(0)
xlabel("Direction Bias", "FontSize", 24)
xlim([.5 2.5])
yticks([-10, 0:50:150])
ylim([-10 150])
yticks(-30:30:150)
yticklabels(cellfun(@(x) num2str(x), num2cell(-1:5), 'uni', 0))
ylabel("Choice Delta (seconds)", "FontSize", 18)
gca.XAxis.FontSize = 96;

meanBiasAll = cellfun(@(x) mean(sessionBias(x)), subIdxAll);
figure
lftMdl = fitlm(sessionBias, leftDiffMean);
plot(lftMdl)
hold on
scatter(sessionBias, leftDiffMean, 20, 'MarkerFaceColor', leftColor, 'MarkerEdgeColor', leftColor)

clean_DMTS_figs
xlim([-.6 .6])
xlabel("Bias weight", "FontSize", 24)
yticks(-180:60:600)
yticklabels(cellfun(@(x) num2str(x), num2cell(-6:2:20), 'uni', 0))
ylabel("Choice Delta (seconds)", "FontSize", 14)
l = legend({"Remove me", "Fit", "95% Confidence Bounds", "Left Trials Averaged"}, "Color", 'w', "TextColor", 'k')

figure
rightMdl = fitlm(sessionBias, rightDiffMean);
plot(rightMdl)
hold on
scatter(sessionBias, rightDiffMean, 20, 'MarkerFaceColor', rightColor, 'MarkerEdgeColor', rightColor)
clean_DMTS_figs
xlabel("Bias weight", "FontSize", 24)
xlim([-.6 .6])
yticks(-180:60:300)
yticklabels(cellfun(@(x) num2str(x), num2cell(-6:2:10), 'uni', 0))
ylabel("Choice Delta (seconds)", "FontSize", 14)
ylabel("Incorrect - correct time to choice (frames)", "FontSize", 14)
l = legend({"Remove me", "Fit", "95% Confidence Bounds", "Right Trials Averaged"}, "Color", 'w', "TextColor", 'k')
%% Trial repeats
numFilteredSubs = numel(filteredSubNames);
repeatedPunishAll = cell(numFilteredSubs, numSessions);
repeatedCorrectAll = cell(numFilteredSubs, numSessions);
repeatedPunishLeft = cell(numFilteredSubs, numSessions);
repeatedPunishRight = cell(numFilteredSubs, numSessions);

for s = 1:numSessions
    dailySessions = trainingParserFiltered(:, s);
    hasParser = cellfun(@(x) ~isempty(x), dailySessions);
    repeatedPunishAll(hasParser, s) = cellfun(@(x) x.state_times('Punish', 'outcome', 'Repeat'), dailySessions(hasParser), 'uni', 0);
    repeatedCorrectAll(hasParser, s) = cellfun(@(x) x.state_times('ChoiceOn', 'outcome', 'Repeat'), dailySessions(hasParser), 'uni', 0);
    repeatedPunishLeft(hasParser, s) = cellfun(@(x) x.state_times('Punish', 'outcome', 'Repeat', 'trialType', 'Left'), dailySessions(hasParser), 'uni', 0);
    repeatedPunishRight(hasParser, s) = cellfun(@(x) x.state_times('Punish', 'outcome', 'Repeat', 'trialType', 'Right'), dailySessions(hasParser), 'uni', 0);
end
repeatPunishByTrial = cellfun(@(x) numel(x), repeatedPunishAll);
repeatCorrectByTrial = cellfun(@(x) numel(x), repeatedCorrectAll);
repeatPunishByTrialLeft = cellfun(@(x) numel(x), repeatedPunishLeft);
repeatPunishByTrialRight = cellfun(@(x) numel(x), repeatedPunishRight);
trainingBiasIdx(isnan(trainingBiasIdx)) = 0;
for sub = 1:numFilteredSubs
    % figure
    % plot(repeatPunishByTrial(sub, :))
    % yyaxis right
    % plot(absoluteBias(sub, :))
    figure
    plot(repeatPunishByTrialLeft(sub, :))
    yyaxis right
    plot(trainingBiasIdx(sub, :))
    figure
    plot(repeatPunishByTrialRight(sub, :))
    yyaxis right
    plot(trainingBiasIdx(sub, :))
end
meanRepeatPunish = mean(repeatPunishByTrial, 1);        
semRepeatPunish = std(meanRepeatPunish, 0, 1)/sqrt(size(meanRepeatPunish, 1));
figure
shaded_error_plot(1:numel(meanRepeatPunish), meanRepeatPunish, semRepeatPunish, [0 0 0], [.2 .2 .2], .3);
clean_DMTS_figs

%% Testing bias

for sub = 1:numFilteredSubs
    subIdx = subIdxAll{sub};
    subTestingBias = sessionBias(subIdx);
    figure
    h = plot(subTestingBias, 'LineWidth', 3, 'Color', 'k');
    ylim([-1 1])
    yline(0, '--', 'LineWidth', 1.5, 'Color', 'k')
    % p = addgradient(gca, topColor, bottomColor);
    % set(p, 'FaceAlpha', .3)
end

%% Video analysis
leftCorrect = PresetManager('event', 'choicePoke', 'outcome', 'Correct', 'trialType', 'Left', 'edges', [-1 0]);
rightCorrect = PresetManager('event', 'choicePoke', 'outcome', 'Correct', 'trialType', 'Right', 'edges', [-1 0]);

% fig3Subs = [1 7];
fig3Subs = 1:8;
for sub = fig3Subs
    subName = filteredSubNames{sub};
    subIdx = subIdxAll{sub};
    sessIdx = find(subIdx);
    leftPosition = figure;
    hold on
    rightPosition = figure;
    hold on
    for sess = sessIdx
        [~, leftSess] = filteredSessions.sessions(sess).plot_centroid('preset', leftCorrect);
        xlim([60 220])
        ylim([0 140])
        set(leftSess, 'Color', 'none')
        [~, rightSess] = filteredSessions.sessions(sess).plot_centroid('preset', rightCorrect);
        xlim([60 220])
        ylim([0 140])
        set(rightSess, 'Color', 'none')
        copyobj(leftSess.Children, leftPosition)
        close(leftSess)
        copyobj(rightSess.Children, rightPosition)
        close(rightSess)
    end
    [~, ~, leftBehavior] = filteredSessions.plot_combined_behaviors('preset', leftCorrect, 'animal', subName);
    [~, ~, rightBehavior] = filteredSessions.plot_combined_behaviors('preset', rightCorrect, 'animal', subName);
    % copygraphics(leftPosition, 'ContentType', 'vector')
    % pause
    % copygraphics(rightPosition, 'ContentType', 'vector')
    % pause
    % copygraphics(leftBehavior, 'ContentType', 'vector')
    % pause
    % copygraphics(rightBehavior, 'ContentType', 'vector')
    % pause
end
