% This is the pipeline for the parainfluenza LabGym project, comparing pre-
% vs post- activity as classified by LabGym.

prePath = 'F:\LabGym\PARAINFLUENZA PROJECT\analyzed_preinfection_2x';
postPath = 'F:\LabGym\PARAINFLUENZA PROJECT\analyzed_postinfection_2x';
prePathSet2 = 'F:\LabGym\PARAINFLUENZA PROJECT\analyzed_preinfection_set2_2x';
postPathSet2 = 'F:\LabGym\PARAINFLUENZA PROJECT\analyzed_postinfection_set2_2x';
preDir = dir(prePath);
preDir = preDir(3:end);
postDir = dir(postPath);
postDir = postDir(3:end);
preDirSet2 = dir(prePathSet2);
preDirSet2 = preDirSet2(3:end);
postDirSet2 = dir(postPathSet2);
postDirSet2 = postDirSet2(3:end);

numSessionsPre = numel(preDir);
numSessionsPost = numel(postDir);
numSessionsPreSet2 = numel(preDirSet2);
numSessionsPostSet2 = numel(postDirSet2);

set1Animals = {'WT_1', 'WT_2', 'WT_3', 'WT_4', ...
    'MUC5B_1', 'MUC5B_2', 'MUC5B_3', 'MUC5B_4'};

set1WT = contains(set1Animals, 'WT');
set1Infection = [1 1 0 0 1 0 1 0];

infectedWTSet1 = set1WT & set1Infection;
mockWTSet1 = set1WT & ~set1Infection;
infectedMutantSet1 = ~set1WT & set1Infection;
mockMutantSet1 = ~set1WT & ~set1Infection;

set2Animals = ...
{'MUC5AC_1', 'MUC5AC_2', 'MUC5AC_3', 'MUC5AC_4' ...
'MUC5B_11', 'MUC5B_12', 'MUC5B_13', 'MUC5B_14' ...
'WT11', 'WT12', 'WT13', 'WT14' ...
'WT15', 'WT16', 'WT17', 'WT18'};

set2WT = contains(set2Animals, 'WT');
set2Infection = [0 0 1 1 0 0 1 1 1 1 0 0 1 1 0 0];

infectedWTSet2 = set2WT & set2Infection;
mockWTSet2 = set2WT & ~set2Infection;
infectedMutantSet2 = ~set2WT & set2Infection;
mockMutantSet2 = ~set2WT & ~set2Infection;

%% Positional map

% Extract positional data from video
preArraySet1 = cell(numSessionsPre, 1);
postArraySet1 = cell(numSessionsPost, 1);
preArraySet2 = cell(numSessionsPreSet2, 1);
postArraySet2 = cell(numSessionsPostSet2, 1);
pathAllPre = preArraySet1;
positionAllPre = preArraySet1;
perimeterAllPreSet1 = preArraySet1;
perimeterAllPreSet2 = preArraySet2;
speedAllPre = preArraySet1;
velocityAllPre = preArraySet1;
pathAllPost = postArraySet1;
positionAllPost = postArraySet1;
perimeterAllPostSet1 = postArraySet1;
perimeterAllPostSet2 = postArraySet2;
speedAllPost = postArraySet1;
velocityAllPost = postArraySet1;
badAreaAllPre = preArraySet1;
badAreaAllPost = postArraySet1;
distPreSet1 = zeros(numSessionsPre, 1);
distPostSet1 = zeros(numSessionsPost, 1);
distPreSet2 = zeros(numSessionsPreSet2, 1);
distPostSet2 = zeros(numSessionsPostSet2, 1);
distPreVelSet1 = zeros(numSessionsPre, 1);
distPostVelSet1 = zeros(numSessionsPost, 1);
distPreVelSet2 = zeros(numSessionsPreSet2, 1);
distPostVelSet2 = zeros(numSessionsPostSet2, 1);

%%
for preSub = 1:numSessionsPre
    sessionName = preDir(preSub).name;
    sessionPath = fullfile(prePath, sessionName);
    vidPath = dir(fullfile(sessionPath, '*.avi'));
    distPreSet1(preSub) = parainfluenza_distance_traveled(vidPath.folder);
    distPreVelSet1(preSub) = parainfluenza_velocity(vidPath.folder);
    % perimeterAllPreSet1{preSub} = get_perimeter(vidPath);
end
%%
for postSub = 1:numSessionsPost
    sessionName = postDir(postSub).name;
    sessionPath = fullfile(postPath, sessionName);
    vidPath = dir(fullfile(sessionPath, '*.avi'));
    distPostSet1(postSub) = parainfluenza_distance_traveled(vidPath.folder);
    distPostVelSet1(postSub) = parainfluenza_velocity(vidPath.folder);
    % perimeterAllPostSet1{postSub} = get_perimeter(vidPath);
end
%%
for preSub = 1:numSessionsPreSet2
    sessionName = preDirSet2(preSub).name;
    idxPreSet2 = find(cellfun(@(x) contains(sessionName, x), set2Animals));
    sessionPath = fullfile(prePathSet2, sessionName);
    vidPath = dir(fullfile(sessionPath, '*.avi'));
    distPreSet2(idxPreSet2) = parainfluenza_distance_traveled(vidPath.folder);
    distPreVelSet2(idxpreSet2) = parainfluenza_velocity(vidPath.folder);
    % perimeterAllPreSet2{preSub} = get_perimeter(vidPath);
end
%%
for postSub = 1:numSessionsPostSet2
    sessionName = postDirSet2(postSub).name;
    idxPostSet2 = find(cellfun(@(x) contains(sessionName, x), set2Animals));
    sessionPath = fullfile(postPathSet2, sessionName);
    vidPath = dir(fullfile(sessionPath, '*.avi'));
    distPostSet2(idxPostSet2) = parainfluenza_distance_traveled(vidPath.folder);
    distPostVelSet2(idxPostSet2) = parainfluenza_velocity(vidPath.folder);
    % perimeterAllPostSet2{postSub} = get_perimeter(vidPath);
end
%%
% cd('F:\LabGym\PARAINFLUENZA PROJECT\matlab')
% save('perimeterAll.mat', 'perimeterAllPreSet1', 'perimeterAllPreSet2',...
%     'perimeterAllPostSet1', 'perimeterAllPostSet2', '-v7.3')

%% Set 1
 

bar_and_error([distPreSet1(infectedWTSet1) distPostSet1(infectedWTSet1) distPreSet1(mockWTSet1) distPostSet1(mockWTSet1)], 2)
bar_and_error([distPreVelSet1(infectedWTSet1) distPostVelSet1(infectedWTSet1) distPreVelSet1(mockWTSet1) distPostVelSet1(mockWTSet1)], 2)
title("Wildtype")
xticks([1, 2])
xticklabels({"Infection", "Mock"})
legend({"Pre-", "Post-"})
clean_DMTS_figs

[~, pIWT1] = ttest(distPreSet2(infectedWTSet1), distPostSet1(infectedWTSet1))
[~, pMWT1] = ttest(distPreSet1(mockWTSet1), distPostSet1(mockWTSet1))
bar_and_error([distPreSet1(infectedMutantSet1) distPostSet1(infectedMutantSet1) distPreSet1(mockMutantSet1) distPostSet1(mockMutantSet1)], 2)
bar_and_error([distPreVelSet1(infectedMutantSet1) distPostVelSet1(infectedMutantSet1) distPreVelSet1(mockMutantSet1) distPostVelSet1(mockMutantSet1)], 2)

title("Mutant")
xticks([1, 2])
xticklabels({"Infection", "Mock"})
legend({"Pre-", "Post-"})
clean_DMTS_figs

[~, pIM1] = ttest(distPreSet1(infectedMutantSet1), distPostSet1(infectedMutantSet1))
[~, pMM1] = ttest(distPreSet1(mockMutantSet1), distPostSet1(mockMutantSet1))
%% Set 2


bar_and_error([distPreSet2(infectedWTSet2) distPostSet2(infectedWTSet2) distPreSet2(mockWTSet2) distPostSet2(mockWTSet2)], 2)
bar_and_error([distPreVelSet2(infectedWTSet2) distPostVelSet2(infectedWTSet2) distPreVelSet2(mockWTSet2) distPostVelSet2(mockWTSet2)], 2)

[~, pIWT2] = ttest(distPreSet2(infectedWTSet2), distPostSet2(infectedWTSet2))
[~, pMWT2] = ttest(distPreSet2(mockWTSet2), distPostSet2(mockWTSet2))
% set1Bar = bar([1 2], [mean(distPreSet2(infectedWTSet2)) mean(distPostSet2(infectedWTSet2)); mean(distPreSet2(mockWTSet2)) mean(distPostSet2(mockWTSet2))]);
% hold on
% infectedSet1X = set1Bar(1).XEndPoints;
% mockSet1X = set1Bar(2).XEndPoints;
% plot([distPreSet2(infectedWTSet2) distPostSet2(infectedWTSet2)]', 'k', 'LineWidth', 3)
% plot([distPreSet2(mockWTSet2) distPostSet2(mockWTSet2)]', 'Color', [.5 .5 .5], 'LineWidth', 3)

title("Wildtype Set 2")
xticks([1, 2])
xticklabels({"Infection", "Mock"})
legend({"Pre-", "Post-"})
clean_DMTS_figs
bar_and_error([distPreSet2(infectedMutantSet2) distPostSet2(infectedMutantSet2) distPreSet2(mockMutantSet2) distPostSet2(mockMutantSet2)], 2)
bar_and_error([distPreVelSet2(infectedMutantSet2) distPostVelSet2(infectedMutantSet2) distPreVelSet2(mockMutantSet2) distPostVelSet2(mockMutantSet2)], 2)
% bar([1 2], [mean(distPreSet2(infectedMutantSet2)) mean(distPostSet2(infectedMutantSet2)); mean(distPreSet2(mockMutantSet2)) mean(distPostSet2(mockMutantSet2))])
[~, pIM2] = ttest(distPreSet2(infectedMutantSet2), distPostSet2(infectedMutantSet2))
[~, pMM2] = ttest(distPreSet2(mockMutantSet2), distPostSet2(mockMutantSet2))
% hold on
% plot([distPreSet2(infectedMutantSet2) distPostSet2(infectedMutantSet2)]', 'r', 'LineWidth', 3)
% plot([distPreSet2(mockMutantSet2) distPostSet2(mockMutantSet2)]', 'Color', [.5 0 0], 'LineWidth', 3)
title("Mutant Set 2")
xticks([1, 2])
xticklabels({"Infection", "Mock"})
legend({"Pre-", "Post-"})
clean_DMTS_figs

%% Combined
% Try absolute delta for combined dataset instead of pre vs post

% WT
wtCombinedInfectedPre = [distPreSet1(infectedWTSet1); distPreSet2(infectedWTSet2)];
wtCombinedInfectedPost = [distPostSet1(infectedWTSet1); distPostSet2(infectedWTSet2)];
wtCombinedMockPre = [distPreSet1(mockWTSet1); distPreSet2(mockWTSet2)];
wtCombinedMockPost = [distPostSet1(mockWTSet1); distPostSet2(mockWTSet2)];
mutantCombinedInfectedPre = [distPreSet1(infectedMutantSet1); distPreSet2(infectedMutantSet2)];
mutantCombinedInfectedPost = [distPostSet1(infectedMutantSet1); distPostSet2(infectedMutantSet2)];
mutantCombinedMockPre = [distPreSet1(mockMutantSet1); distPreSet2(mockMutantSet2)];
mutantCombinedMockPost = [distPostSet1(mockMutantSet1); distPostSet2(mockMutantSet2)];



bar_and_error([wtCombinedInfectedPre, wtCombinedInfectedPost, wtCombinedMockPre, wtCombinedMockPost], 2)
title("Combined wildtype")

xticks([1, 2])
xticklabels({"Infection", "Mock"})
legend({"Pre-", "Post-"})
clean_DMTS_figs
[~, pIWTCombined] = ttest(wtCombinedInfectedPre, wtCombinedInfectedPost)
[~, pMWTCombined] = ttest(wtCombinedMockPre, wtCombinedMockPost)
% Mutant
bar_and_error([mutantCombinedInfectedPre, mutantCombinedInfectedPost, mutantCombinedMockPre, mutantCombinedMockPost], 2)
title("Combined mutant")

xticks([1, 2])
xticklabels({"Infection", "Mock"})
legend({"Pre-", "Post-"})
clean_DMTS_figs
[~, pIMCombined] = ttest(mutantCombinedInfectedPre, mutantCombinedInfectedPost)
[~, pMMCombined] = ttest(mutantCombinedMockPre, mutantCombinedMockPost)

% Absolute

absInfectedWT = abs(wtCombinedInfectedPost - wtCombinedInfectedPre);
absMockWT = abs(wtCombinedMockPost - wtCombinedMockPre);
absInfectedMutant = abs(mutantCombinedInfectedPost - mutantCombinedInfectedPre);
absMockMutant = abs(mutantCombinedMockPost - mutantCombinedMockPre);

bar_and_error([absInfectedWT, absMockWT, absInfectedMutant, absMockMutant], 2)
xticks([1, 2])
xticklabels({"WT", "Mutant"})
legend({"Infection", "Mock"})
title("Combined absolute change")
clean_DMTS_figs

[~, pAbsWT] = ttest(absInfectedWT, absMockWT)
[~, pAbsMutant] = ttest(absInfectedMutant, absMockMutant)

function distanceTraveled = parainfluenza_distance_traveled(filePath)
    % myPosition = get_LabGym_centroid(fullfile(filePath, 'Annotated video.avi'));
    vid = VideoReader(fullfile(filePath, 'Annotated video.avi'));
    vidRes = [vid.Width vid.Height];
    positionCSV = readtable(fullfile(filePath, 'mouse_centers.xlsx'));
    positionString = positionCSV.Var2(2:end);
    positionString = cellfun(@(x) regexprep(x, '[()]', ''), positionString, 'uni', 0);
    positionCell = cellfun(@(x) str2num(x), positionString, 'uni', 0);
    positionByFrame = cat(1, positionCell{:});
    missingVals = cellfun(@(x) isempty(x), positionCell);
    numFrames = numel(positionCell);
    positionX = zeros(numFrames, 1);
    positionY = zeros(numFrames, 1);
    positionX(~missingVals) = positionByFrame(:, 1);
    positionX(missingVals) = NaN;
    positionY(~missingVals) = positionByFrame(:, 2);
    positionY(missingVals) = NaN;
    [xF, xT] = fillmissing(positionX, 'linear', 'SamplePoints', 1:numFrames);
    [yF, yT] = fillmissing(positionY, 'linear', 'SamplePoints', 1:numFrames);
    combinedPosition = [xF, yF];
    % tsData = sub2ind(fliplr(vidRes), ceil(yF), ceil(xF));
    % figure
    % plot(tsData)
    % diffX = diff(xF);
    % diffY = diff(yF);

    % velocityByDistance = [NaN; (diffX.^2 + diffX.^2).^0.5];
    
    velocityCSV = readtable(fullfile(filePath, 'mouse_velocity.xlsx'));
    velocityByFrame = velocityCSV.Var2(2:end);
    % figure
    % hold on
    % plot(velocityByDistance)
    % plot(velocityByFrame)
    distanceTraveled = sum(velocityByFrame, 'omitnan');
end

function distTraveled = parainfluenza_velocity(filePath)
    % vid = VideoReader(fullfile(filePath, 'Annotated video.avi'));
    velocityCSV = readtable(fullfile(filePath, 'mouse_velocity.xlsx'));
    velocityByFrame = velocityCSV.Var2(2:end);
    distTraveled = sum(velocityByFrame, 'omitnan');
    % figure(1)
    % plot(velocityByFrame)
    % lineX = xline(0);
    % hold on
    % noiseThresh = thselect(velocityByFrame, 'sqtwolog');
    % aboveThresh = velocityByFrame > noiseThresh;
    % f = find(aboveThresh);
    % for g = f'
    % 
    %     frame = read(vid, g);
    %     figure(2)
    %     imshow(frame)
    %     figure(1)
    %     delete(lineX)
    %     lineX = xline(g);
    %     pause
    % end
    % 
    % pause
end

function innerPerim = get_perimeter(filePath)
% inner perimeter
    f = figure;
    hold on
    vid = VideoReader(fullfile(filePath.folder, filePath.name));
    frame = read(vid, 100);
    perimAccepted = false;
    while ~perimAccepted
        clf(f)
        imshow(frame, 'Border', 'tight')
        ax = gca;
        disableDefaultInteractivity(ax)
        [outerPerim, innerPerim] = parainfluenza_perimeters(f);
        hold on
        rectangle('Position', outerPerim, 'EdgeColor', 'k')
        rectangle('Position', innerPerim, 'EdgeColor', 'r')
        qFig = uifigure;
        qAns = uiconfirm(qFig, "Accept perimeters?", "Bounding Boxes");
        perimAccepted = strcmp(qAns, "OK");
        close(qFig)
    end    
    close(f)
end
% 

%% Center vs Periphery

% % Compare positional data to reference pixels for inner vs outer region
% 
% 
% innerXPre = cellfun(@(x) [x(1); x(1); x(1) + x(3); x(1) + x(3)], perimeterAllPre, 'uni', 0);
% innerYPre = cellfun(@(x) [x(2); x(2) + x(4); x(2) + x(4); x(2)], perimeterAllPre, 'uni', 0);
% innerXPost = cellfun(@(x) [x(1); x(1); x(1) + x(3); x(1) + x(3)], perimeterAllPost, 'uni', 0);
% innerYPost = cellfun(@(x) [x(2); x(2) + x(4); x(2) + x(4); x(2)], perimeterAllPost, 'uni', 0);
% [inPre, onPre] = cellfun(@(x, y, z) inpolygon(x(:, 1), x(:, 2), y, z), positionAllPre, innerXPre, innerYPre, 'uni', 0);
% [inPost, onPost] = cellfun(@(x, y, z) inpolygon(x(:, 1), x(:, 2), y, z), positionAllPost, innerXPost, innerYPost, 'uni', 0);
