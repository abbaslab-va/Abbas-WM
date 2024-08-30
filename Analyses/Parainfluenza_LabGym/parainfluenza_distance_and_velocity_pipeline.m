%% Initialize
parainfluenzaCombined = parainfluenza_init;

%% Position by frame
parainfluenzaCombined.set1.prePosition = ...
    cellfun(@(x) parainfluenza_position(x), ...
    parainfluenzaCombined.set1.prePath, 'uni', 0);
parainfluenzaCombined.set1.postPosition = ...
    cellfun(@(x) parainfluenza_position(x), ...
    parainfluenzaCombined.set1.postPath, 'uni', 0);
parainfluenzaCombined.set2.prePosition = ...
    cellfun(@(x) parainfluenza_position(x), ...
    parainfluenzaCombined.set2.prePath, 'uni', 0);
parainfluenzaCombined.set2.postPosition = ...
    cellfun(@(x) parainfluenza_position(x), ...
    parainfluenzaCombined.set2.postPath, 'uni', 0);

%% Periphery by frame
parainfluenzaCombined.set1.prePeripheral = ...
    cellfun(@(x, y) parainfluenza_periphery(x, y), ...
    parainfluenzaCombined.set1.prePosition, ...
    parainfluenzaCombined.set1.prePerim, 'uni', 0);
parainfluenzaCombined.set1.postPeripheral = ...
    cellfun(@(x, y) parainfluenza_periphery(x, y), ...
    parainfluenzaCombined.set1.postPosition, ...
    parainfluenzaCombined.set1.postPerim, 'uni', 0);
parainfluenzaCombined.set2.prePeripheral = ...
    cellfun(@(x, y) parainfluenza_periphery(x, y), ...
    parainfluenzaCombined.set2.prePosition, ...
    parainfluenzaCombined.set2.prePerim, 'uni', 0);
parainfluenzaCombined.set2.postPeripheral = ...
    cellfun(@(x, y) parainfluenza_periphery(x, y), ...
    parainfluenzaCombined.set2.postPosition, ...
    parainfluenzaCombined.set2.postPerim, 'uni', 0);

%% Velocity by frame
parainfluenzaCombined.set1.preVelocity = ...
    cellfun(@(x) parainfluenza_velocity(x), ...
    parainfluenzaCombined.set1.prePath, 'uni', 0);
parainfluenzaCombined.set1.postVelocity = ...
    cellfun(@(x) parainfluenza_velocity(x), ...
    parainfluenzaCombined.set1.postPath, 'uni', 0);
parainfluenzaCombined.set2.preVelocity = ...
    cellfun(@(x) parainfluenza_velocity(x), ...
    parainfluenzaCombined.set2.prePath, 'uni', 0);
parainfluenzaCombined.set2.postVelocity = ...
    cellfun(@(x) parainfluenza_velocity(x), ...
    parainfluenzaCombined.set2.postPath, 'uni', 0);

%% Behavior by frame

%% Periphery analysis
velocityOuterPreSet1 = cellfun(@(x, y) x(y), ...
    parainfluenzaCombined.set1.preVelocity, parainfluenzaCombined.set1.prePeripheral, 'uni', 0);
velocityCenterPreSet1 = cellfun(@(x, y) x(~y), ...
    parainfluenzaCombined.set1.preVelocity, parainfluenzaCombined.set1.prePeripheral, 'uni', 0);
velocityOuterPostSet1 = cellfun(@(x, y) x(y), ...
    parainfluenzaCombined.set1.postVelocity, parainfluenzaCombined.set1.postPeripheral, 'uni', 0);
velocityCenterPostSet1 = cellfun(@(x, y) x(~y), ...
    parainfluenzaCombined.set1.postVelocity, parainfluenzaCombined.set1.postPeripheral, 'uni', 0);

velocityOuterPreSet2 = cellfun(@(x, y) x(y), ...
    parainfluenzaCombined.set2.preVelocity, parainfluenzaCombined.set2.prePeripheral, 'uni', 0);
velocityCenterPreSet2 = cellfun(@(x, y) x(~y), ...
    parainfluenzaCombined.set2.preVelocity, parainfluenzaCombined.set2.prePeripheral, 'uni', 0);
velocityOuterPostSet2 = cellfun(@(x, y) x(y), ...
    parainfluenzaCombined.set2.postVelocity, parainfluenzaCombined.set2.postPeripheral, 'uni', 0);
velocityCenterPostSet2 = cellfun(@(x, y) x(~y), ...
    parainfluenzaCombined.set2.postVelocity, parainfluenzaCombined.set2.postPeripheral, 'uni', 0);

framesOuterPreSet1 = cellfun(@(x) sum(x), ...
    parainfluenzaCombined.set1.prePeripheral, 'uni', 0);
framesCenterPreSet1 = cellfun(@(x) sum(~x), ...
    parainfluenzaCombined.set1.prePeripheral, 'uni', 0);
framesOuterPostSet1 = cellfun(@(x) sum(x), ...
    parainfluenzaCombined.set1.postPeripheral, 'uni', 0);
framesCenterPostSet1 = cellfun(@(x) sum(~x), ...
    parainfluenzaCombined.set1.postPeripheral, 'uni', 0);

framesOuterPreSet2 = cellfun(@(x) sum(x), ...
    parainfluenzaCombined.set2.prePeripheral, 'uni', 0);
framesCenterPreSet2 = cellfun(@(x) sum(~x), ...
    parainfluenzaCombined.set2.prePeripheral, 'uni', 0);
framesOuterPostSet2 = cellfun(@(x) sum(x), ...
    parainfluenzaCombined.set2.postPeripheral, 'uni', 0);
framesCenterPostSet2 = cellfun(@(x) sum(~x), ...
    parainfluenzaCombined.set2.postPeripheral, 'uni', 0);

%% Plots
peripheryComparisonLabel = {'Outer', 'Center'};
injectionComparisonLabel = {'Pre', 'Post'};
make_grouped_bar_chart([velocityOuterPreSet1, velocityCenterPreSet1, velocityOuterPostSet1, velocityCenterPostSet1], ...
    parainfluenzaCombined, [1 1 2 2], peripheryComparisonLabel, 'mean');
sgtitle('Velocity Mean Set 1')
make_grouped_bar_chart([velocityOuterPreSet2, velocityCenterPreSet2, velocityOuterPostSet2, velocityCenterPostSet2], ...
    parainfluenzaCombined, [1 1 2 2], peripheryComparisonLabel, 'mean');
sgtitle('Velocity Mean Set 2')
make_grouped_bar_chart([velocityOuterPreSet1, velocityCenterPreSet1, velocityOuterPostSet1, velocityCenterPostSet1], ...
    parainfluenzaCombined, [1 1 2 2], peripheryComparisonLabel, 'sum');
sgtitle('Velocity Sum Set 1')
make_grouped_bar_chart([velocityOuterPreSet2, velocityCenterPreSet2, velocityOuterPostSet2, velocityCenterPostSet2], ...
    parainfluenzaCombined, [1 1 2 2], peripheryComparisonLabel, 'sum');
sgtitle('Velocity Sum Set 2')

make_grouped_bar_chart([framesOuterPreSet1, framesCenterPreSet1, framesOuterPostSet1, framesCenterPostSet1], ...
    parainfluenzaCombined, [1 1 2 2], peripheryComparisonLabel, 'mean');
sgtitle('Frames Set 1')
make_grouped_bar_chart([framesOuterPreSet2, framesCenterPreSet2, framesOuterPostSet2, framesCenterPostSet2], ...
    parainfluenzaCombined, [1 1 2 2], peripheryComparisonLabel, 'mean');
sgtitle('Frames Set 2')
%% Functions 

function coordsByFrame = parainfluenza_position(filePath)
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
    xF = fillmissing(positionX, 'linear', 'SamplePoints', 1:numFrames);
    yF = fillmissing(positionY, 'linear', 'SamplePoints', 1:numFrames);
    coordsByFrame = [xF, yF];
end

function velocityByFrame = parainfluenza_velocity(filePath)
    velocityCSV = readtable(fullfile(filePath, 'mouse_velocity.xlsx'));
    velocityByFrame = velocityCSV.Var2(2:end);
end

function peripheryByFrame = parainfluenza_periphery(coords, perim)
    innerX = [perim(1); perim(1); perim(1) + perim(3); perim(1) + perim(3)];
    innerY = [perim(2); perim(2) + perim(4); perim(2) + perim(4); perim(2)];
    peripheryByFrame = ~inpolygon(coords(:, 1), coords(:, 2), innerX, innerY);
end

function make_grouped_bar_chart(data, subStruct, groupID, labels, output)
    
    set1InfectedWT = subStruct.set1.infection & subStruct.set1.wildType;
    set1MockWT = ~subStruct.set1.infection & subStruct.set1.wildType;
    set1InfectedMutant = subStruct.set1.infection & ~subStruct.set1.wildType;
    set1MockMutant = ~subStruct.set1.infection & ~subStruct.set1.wildType;
    
    set2InfectedWT = subStruct.set2.infection & subStruct.set2.wildType;
    set2MockWT = ~subStruct.set2.infection & subStruct.set2.wildType;
    set2InfectedMutant = subStruct.set2.infection & ~subStruct.set2.wildType;
    set2MockMutant = ~subStruct.set2.infection & ~subStruct.set2.wildType;

    groupLabels = unique(groupID);
    numInputs = numel(groupID);
    numGroups = numel(groupLabels);
    reshapeVec = [numInputs/numGroups, numGroups];

    dataMeans = cellfun(@(x) mean(x, 'omitnan'), data);
    dataSum = cellfun(@(x) sum(x, 'omitnan'), data);
    if strcmp(output, 'mean')
        toPlot = dataMeans;
    else
        toPlot = dataSum;
    end
    dataSEM = cellfun(@(x) std(x, 0, 'omitnan')/sqrt(sum(~isnan(x))), data);
    meanInfectedWT = reshape(mean(toPlot(set1InfectedWT, :), 1), reshapeVec)';
    meanMockWT = reshape(mean(toPlot(set1MockWT, :), 1), reshapeVec)';
    meanInfectedMutant = reshape(mean(toPlot(set1InfectedMutant, :), 1), reshapeVec)';
    meanMockMutant = reshape(mean(toPlot(set1MockMutant, :), 1), reshapeVec)';

    figure
    tiledlayout(2, 2)
    nexttile
    bar(meanInfectedWT)
    title('Infected WT')
    legend(labels)
    nexttile
    bar(meanMockWT)
    title('Mock WT')
    nexttile
    bar(meanInfectedMutant)
    title('Infected Mutant')
    nexttile
    bar(meanMockMutant)
    title('Mock Mutant')
end