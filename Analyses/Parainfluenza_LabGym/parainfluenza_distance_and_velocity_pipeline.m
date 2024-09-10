%% Initialize
[parainfluenzaSeparated, parainfluenzaCombined] = parainfluenza_init;

%% Position by frame
parainfluenzaSeparated.set1.prePosition = ...
    cellfun(@(x) parainfluenza_position(x), ...
    parainfluenzaSeparated.set1.prePath, 'uni', 0);
parainfluenzaSeparated.set1.postPosition = ...
    cellfun(@(x) parainfluenza_position(x), ...
    parainfluenzaSeparated.set1.postPath, 'uni', 0);
parainfluenzaSeparated.set2.prePosition = ...
    cellfun(@(x) parainfluenza_position(x), ...
    parainfluenzaSeparated.set2.prePath, 'uni', 0);
parainfluenzaSeparated.set2.postPosition = ...
    cellfun(@(x) parainfluenza_position(x), ...
    parainfluenzaSeparated.set2.postPath, 'uni', 0);

parainfluenzaCombined.prePosition = ...
    [parainfluenzaSeparated.set1.prePosition; parainfluenzaSeparated.set2.prePosition];
parainfluenzaCombined.postPosition = ...
    [parainfluenzaSeparated.set1.postPosition; parainfluenzaSeparated.set2.postPosition];
%% Periphery by frame
parainfluenzaSeparated.set1.prePeripheral = ...
    cellfun(@(x, y) parainfluenza_periphery(x, y), ...
    parainfluenzaSeparated.set1.prePosition, ...
    parainfluenzaSeparated.set1.prePerim, 'uni', 0);
parainfluenzaSeparated.set1.postPeripheral = ...
    cellfun(@(x, y) parainfluenza_periphery(x, y), ...
    parainfluenzaSeparated.set1.postPosition, ...
    parainfluenzaSeparated.set1.postPerim, 'uni', 0);
parainfluenzaSeparated.set2.prePeripheral = ...
    cellfun(@(x, y) parainfluenza_periphery(x, y), ...
    parainfluenzaSeparated.set2.prePosition, ...
    parainfluenzaSeparated.set2.prePerim, 'uni', 0);
parainfluenzaSeparated.set2.postPeripheral = ...
    cellfun(@(x, y) parainfluenza_periphery(x, y), ...
    parainfluenzaSeparated.set2.postPosition, ...
    parainfluenzaSeparated.set2.postPerim, 'uni', 0);

parainfluenzaCombined.prePeripheral = ...
    [parainfluenzaSeparated.set1.prePeripheral; parainfluenzaSeparated.set2.prePeripheral];
parainfluenzaCombined.postPeripheral = ...
    [parainfluenzaSeparated.set1.postPeripheral; parainfluenzaSeparated.set2.postPeripheral];
%% Velocity by frame
parainfluenzaSeparated.set1.preVelocity = ...
    cellfun(@(x) parainfluenza_velocity(x), ...
    parainfluenzaSeparated.set1.prePath, 'uni', 0);
parainfluenzaSeparated.set1.postVelocity = ...
    cellfun(@(x) parainfluenza_velocity(x), ...
    parainfluenzaSeparated.set1.postPath, 'uni', 0);
parainfluenzaSeparated.set2.preVelocity = ...
    cellfun(@(x) parainfluenza_velocity(x), ...
    parainfluenzaSeparated.set2.prePath, 'uni', 0);
parainfluenzaSeparated.set2.postVelocity = ...
    cellfun(@(x) parainfluenza_velocity(x), ...
    parainfluenzaSeparated.set2.postPath, 'uni', 0);

parainfluenzaCombined.preVelocity = ...
    [parainfluenzaSeparated.set1.preVelocity; parainfluenzaSeparated.set2.preVelocity];
parainfluenzaCombined.postVelocity = ...
    [parainfluenzaSeparated.set1.postVelocity; parainfluenzaSeparated.set2.postVelocity];
%% Behavior by frame

%% Periphery analysis
velocityOuterPreSet1 = cellfun(@(x, y) x(y), ...
    parainfluenzaSeparated.set1.preVelocity, parainfluenzaSeparated.set1.prePeripheral, 'uni', 0);
velocityCenterPreSet1 = cellfun(@(x, y) x(~y), ...
    parainfluenzaSeparated.set1.preVelocity, parainfluenzaSeparated.set1.prePeripheral, 'uni', 0);
velocityOuterPostSet1 = cellfun(@(x, y) x(y), ...
    parainfluenzaSeparated.set1.postVelocity, parainfluenzaSeparated.set1.postPeripheral, 'uni', 0);
velocityCenterPostSet1 = cellfun(@(x, y) x(~y), ...
    parainfluenzaSeparated.set1.postVelocity, parainfluenzaSeparated.set1.postPeripheral, 'uni', 0);

velocityOuterPreSet2 = cellfun(@(x, y) x(y), ...
    parainfluenzaSeparated.set2.preVelocity, parainfluenzaSeparated.set2.prePeripheral, 'uni', 0);
velocityCenterPreSet2 = cellfun(@(x, y) x(~y), ...
    parainfluenzaSeparated.set2.preVelocity, parainfluenzaSeparated.set2.prePeripheral, 'uni', 0);
velocityOuterPostSet2 = cellfun(@(x, y) x(y), ...
    parainfluenzaSeparated.set2.postVelocity, parainfluenzaSeparated.set2.postPeripheral, 'uni', 0);
velocityCenterPostSet2 = cellfun(@(x, y) x(~y), ...
    parainfluenzaSeparated.set2.postVelocity, parainfluenzaSeparated.set2.postPeripheral, 'uni', 0);

framesOuterPreSet1 = cellfun(@(x) sum(x)/numel(x), ...
    parainfluenzaSeparated.set1.prePeripheral, 'uni', 0);
framesCenterPreSet1 = cellfun(@(x) sum(~x)/numel(x), ...
    parainfluenzaSeparated.set1.prePeripheral, 'uni', 0);
framesOuterPostSet1 = cellfun(@(x) sum(x)/numel(x), ...
    parainfluenzaSeparated.set1.postPeripheral, 'uni', 0);
framesCenterPostSet1 = cellfun(@(x) sum(~x)/numel(x), ...
    parainfluenzaSeparated.set1.postPeripheral, 'uni', 0);

framesOuterPreSet2 = cellfun(@(x) sum(x)/numel(x), ...
    parainfluenzaSeparated.set2.prePeripheral, 'uni', 0);
framesCenterPreSet2 = cellfun(@(x) sum(~x)/numel(x), ...
    parainfluenzaSeparated.set2.prePeripheral, 'uni', 0);
framesOuterPostSet2 = cellfun(@(x) sum(x)/numel(x), ...
    parainfluenzaSeparated.set2.postPeripheral, 'uni', 0);
framesCenterPostSet2 = cellfun(@(x) sum(~x)/numel(x), ...
    parainfluenzaSeparated.set2.postPeripheral, 'uni', 0);

velocityOuterPre = cellfun(@(x, y) x(y), ...
    parainfluenzaCombined.preVelocity, parainfluenzaCombined.prePeripheral, 'uni', 0);
velocityCenterPre = cellfun(@(x, y) x(~y), ...
    parainfluenzaCombined.preVelocity, parainfluenzaCombined.prePeripheral, 'uni', 0);
velocityOuterPost = cellfun(@(x, y) x(y), ...
    parainfluenzaCombined.postVelocity, parainfluenzaCombined.postPeripheral, 'uni', 0);
velocityCenterPost = cellfun(@(x, y) x(~y), ...
    parainfluenzaCombined.postVelocity, parainfluenzaCombined.postPeripheral, 'uni', 0);

framesOuterPre = cellfun(@(x) sum(x)/numel(x), ...
    parainfluenzaCombined.prePeripheral, 'uni', 0);
framesCenterPre = cellfun(@(x) sum(~x)/numel(x), ...
    parainfluenzaCombined.prePeripheral, 'uni', 0);
framesOuterPost = cellfun(@(x) sum(x)/numel(x), ...
    parainfluenzaCombined.postPeripheral, 'uni', 0);
framesCenterPost = cellfun(@(x) sum(~x)/numel(x), ...
    parainfluenzaCombined.postPeripheral, 'uni', 0);

%% Velocity distributions

velocity_histogram(parainfluenzaCombined, 0, 'Combined');
% velocity_histogram(parainfluenzaSeparated, 1, 'Set 1');
% velocity_histogram(parainfluenzaSeparated, 2, 'Set 2');

%% Periphery comparison


make_grouped_bar_chart([velocityOuterPreSet1, velocityCenterPreSet1, velocityOuterPostSet1, velocityCenterPostSet1], ...
    parainfluenzaSeparated, [1 1 2 2], 'periphery', 'mean', 1);
sgtitle('Velocity Mean Set 1')
make_grouped_bar_chart([velocityOuterPreSet2, velocityCenterPreSet2, velocityOuterPostSet2, velocityCenterPostSet2], ...
    parainfluenzaSeparated, [1 1 2 2], 'periphery', 'mean', 2);
sgtitle('Velocity Mean Set 2')
make_grouped_bar_chart([velocityOuterPreSet1, velocityCenterPreSet1, velocityOuterPostSet1, velocityCenterPostSet1], ...
    parainfluenzaSeparated, [1 1 2 2], 'periphery', 'sum', 1);
sgtitle('Velocity Sum Set 1')
make_grouped_bar_chart([velocityOuterPreSet2, velocityCenterPreSet2, velocityOuterPostSet2, velocityCenterPostSet2], ...
    parainfluenzaSeparated, [1 1 2 2], 'periphery', 'sum', 2);
sgtitle('Velocity Sum Set 2')

make_grouped_bar_chart([framesOuterPreSet1, framesCenterPreSet1, framesOuterPostSet1, framesCenterPostSet1], ...
    parainfluenzaSeparated, [1 1 2 2], 'periphery', 'mean', 1);
sgtitle('Frames Set 1')
make_grouped_bar_chart([framesOuterPreSet2, framesCenterPreSet2, framesOuterPostSet2, framesCenterPostSet2], ...
    parainfluenzaSeparated, [1 1 2 2], 'periphery', 'mean', 2);
sgtitle('Frames Set 2')

%% Injection comparison
make_grouped_bar_chart([velocityOuterPreSet1, velocityCenterPreSet1, velocityOuterPostSet1, velocityCenterPostSet1], ...
    parainfluenzaSeparated, [1 2 1 2], 'epoch', 'mean', 1);
sgtitle('Velocity Mean Set 1')
make_grouped_bar_chart([velocityOuterPreSet2, velocityCenterPreSet2, velocityOuterPostSet2, velocityCenterPostSet2], ...
    parainfluenzaSeparated, [1 2 1 2], 'epoch', 'mean', 2);
sgtitle('Velocity Mean Set 2')
make_grouped_bar_chart([velocityOuterPreSet1, velocityCenterPreSet1, velocityOuterPostSet1, velocityCenterPostSet1], ...
    parainfluenzaSeparated, [1 2 1 2], 'epoch', 'sum', 1);
sgtitle('Velocity Sum Set 1')
make_grouped_bar_chart([velocityOuterPreSet2, velocityCenterPreSet2, velocityOuterPostSet2, velocityCenterPostSet2], ...
    parainfluenzaSeparated, [1 2 1 2], 'epoch', 'sum', 2);
sgtitle('Velocity Sum Set 2')

make_grouped_bar_chart([framesOuterPreSet1, framesCenterPreSet1, framesOuterPostSet1, framesCenterPostSet1], ...
    parainfluenzaSeparated, [1 2 1 2], 'epoch', 'mean', 1);
sgtitle('Frames Set 1')
make_grouped_bar_chart([framesOuterPreSet2, framesCenterPreSet2, framesOuterPostSet2, framesCenterPostSet2], ...
    parainfluenzaSeparated, [1 2 1 2], 'epoch', 'mean', 2);
sgtitle('Frames Set 2')

%% Combined Injection
make_grouped_bar_chart([velocityOuterPre, velocityCenterPre, velocityOuterPost, velocityCenterPost], ...
    parainfluenzaCombined, [1 2 1 2], 'epoch', 'mean', 0);
sgtitle('Velocity Mean Combined')
make_grouped_bar_chart([velocityOuterPre, velocityCenterPre, velocityOuterPost, velocityCenterPost], ...
    parainfluenzaCombined, [1 2 1 2], 'epoch', 'sum', 0);
sgtitle('Velocity Sum Combined')
make_grouped_bar_chart([framesOuterPre, framesCenterPre, framesOuterPost, framesCenterPost], ...
    parainfluenzaCombined, [1 2 1 2], 'epoch', 'mean', 0);

%% TO DO

% Find significance in velocity distribution differences (ks test)
% Look at thresholded velocity to do a ttest on non-movement activity
% Decode behavior through LabGym (tabled)

%% Functions 

function coordsByFrame = parainfluenza_position(filePath)
    positionCSV = readtable(fullfile(filePath, 'mouse_centers.xlsx'));
    positionString = positionCSV.Var2(2:end);
    positionString = cellfun(@(x) regexprep(x, '[()]', ''), positionString, 'uni', 0);
    positionCell = cellfun(@(x) str2double(x), positionString, 'uni', 0);
    positionByFrame = cat(1, positionCell{:});
    missingVals = cellfun(@(x) isempty(x), positionCell);
    numFrames = numel(positionCell);
    positionX = zeros(numFrames, 1);
    positionY = zeros(numFrames, 1);
    positionX(~missingVals) = positionByFrame(:, 1);
    positionX(missingVals) = NaN;
    positionY(~missingVals) = positionByFrame(:, 2);
    positionY(missingVals) = NaN;
    xF = fillmissing(positionX, 'linear', 'SamplePoints', 1:numFrames);
    yF = fillmissing(positionY, 'linear', 'SamplePoints', 1:numFrames);
    coordsByFrame = [xF, yF];
end

function velocityByFrame = parainfluenza_velocity(filePath)
    velocityCSV = readtable(fullfile(filePath, 'mouse_speed.xlsx'));
    velocityByFrame = velocityCSV.Var2(2:end);
end

function peripheryByFrame = parainfluenza_periphery(coords, perim)
    innerX = [perim(1); perim(1); perim(1) + perim(3); perim(1) + perim(3)];
    innerY = [perim(2); perim(2) + perim(4); perim(2) + perim(4); perim(2)];
    peripheryByFrame = ~inpolygon(coords(:, 1), coords(:, 2), innerX, innerY);
end

function make_grouped_bar_chart(data, subStruct, groupID, label, output, setNo)
    if setNo
        setStr = ['set' num2str(setNo)];
        dataStruct = subStruct.(setStr);
    else
        dataStruct = subStruct;
    end

    if strcmp(label, 'periphery')
        legendString = {'Outer', 'Center'};
        xLabelString = {'Pre', 'Post'};
    else
        legendString = {'Pre', 'Post'};
        xLabelString = {'Outer', 'Center'};
    end
    infectedWT = dataStruct.infection & dataStruct.wildType;
    mockWT = ~dataStruct.infection & dataStruct.wildType;
    infectedMutant = dataStruct.infection & ~dataStruct.wildType;
    mockMutant = ~dataStruct.infection & ~dataStruct.wildType;

    groupLabels = unique(groupID);
    groupIdx = arrayfun(@(x) groupID == x, groupLabels, 'uni', 0)';

    dataMeans = cellfun(@(x) mean(x, 'omitnan'), data);
    dataSum = cellfun(@(x) sum(x, 'omitnan'), data);
    if strcmp(output, 'mean')
        toPlot = dataMeans;
    else
        toPlot = dataSum;
    end
    % dataSEM = cellfun(@(x) std(x, 0, 'omitnan')/sqrt(sum(~isnan(x))), data);
    meanInfectedWT = mean_and_reshape(toPlot, infectedWT, groupIdx);
    meanMockWT = mean_and_reshape(toPlot, mockWT, groupIdx);
    meanInfectedMutant = mean_and_reshape(toPlot, infectedMutant, groupIdx);
    meanMockMutant = mean_and_reshape(toPlot, mockMutant, groupIdx);

    figure
    tiledlayout(2, 2)
    nexttile
    bar(meanInfectedWT)
    title('Infected WT')
    xticklabels(xLabelString)
    legend(legendString)
    nexttile
    bar(meanMockWT)
    title('Mock WT')
    xticklabels(xLabelString)
    nexttile
    bar(meanInfectedMutant)
    title('Infected Mutant')
    xticklabels(xLabelString)
    nexttile
    bar(meanMockMutant)
    title('Mock Mutant')
    xticklabels(xLabelString)
end

function dataOut = mean_and_reshape(dataIn, subIdx, groupIdx)
    dataAveraged = mean(dataIn(subIdx, :), 1);
    dataCells = cellfun(@(x) dataAveraged(x), groupIdx, 'uni', 0);
    dataOut = cat(1, dataCells{:});
end

function velocity_histogram(subStruct, setNo, mainTitle)

    if setNo
        setStr = ['set' num2str(setNo)];
        dataStruct = subStruct.(setStr);
    else
        dataStruct = subStruct;
    end

    infectedWT = dataStruct.infection & dataStruct.wildType;
    mockWT = ~dataStruct.infection & dataStruct.wildType;
    infectedMutant = dataStruct.infection & ~dataStruct.wildType;
    mockMutant = ~dataStruct.infection & ~dataStruct.wildType;

    velocityPre = dataStruct.preVelocity;
    velocityPost = dataStruct.postVelocity;
    figure
    tiledlayout(2, 2)
    nexttile
    plot_hist_subset(velocityPre, velocityPost, infectedWT);
    title('Infected WT')
    legend({'Pre', 'Post'})
    nexttile
    plot_hist_subset(velocityPre, velocityPost, mockWT);
    title('Mock WT')
    nexttile
    plot_hist_subset(velocityPre, velocityPost, infectedMutant);
    title('Infected Mutant')
    nexttile
    plot_hist_subset(velocityPre, velocityPost, mockMutant);
    title('Mock Mutant')
    sgtitle(mainTitle)
    figure
    plot_hist_subset(velocityPre(dataStruct.wildType), velocityPre(~dataStruct.wildType), true(numel(find(dataStruct.wildType)), 1))
    legend({'Wild Type', 'Mutant'})
    title(mainTitle)
end

function plot_hist_subset(dataPre, dataPost, subset)
    binEdges = 0:.1:5;
    preVel = dataPre(subset);
    preVel = cat(1, preVel{:});
    postVel = dataPost(subset);
    postVel = cat(1, postVel{:});
    histogram(preVel, 'BinEdges', binEdges, 'Normalization','probability')
    hold on
    histogram(postVel, 'BinEdges', binEdges, 'Normalization','probability')
end

