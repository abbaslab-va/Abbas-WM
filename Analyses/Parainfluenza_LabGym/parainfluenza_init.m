function [subStruct, subStructCombined] = parainfluenza_init

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
    subStruct.set1.names = get_sub_names(preDir);
    subStruct.set1.prePath = arrayfun(@(x) fullfile(x.folder, x.name), preDir, 'uni', 0);
    subStruct.set1.postPath = arrayfun(@(x) fullfile(x.folder, x.name), postDir, 'uni', 0);
    subStruct.set1.wildType = cellfun(@(x) contains(x, 'WT'), subStruct.set1.names);
    subStruct.set1.infection = [1 1 0 0 1 0 1 0]';
    subStruct.set2.names = get_sub_names(preDirSet2);
    subStruct.set2.prePath = arrayfun(@(x) fullfile(x.folder, x.name), preDirSet2, 'uni', 0);
    postPathSet2Unordered = arrayfun(@(x) fullfile(x.folder, x.name), postDirSet2, 'uni', 0);
    [~, postPathSet2Idx] = sort(cellfun(@(x) find(cellfun(@(y) contains(x, y), subStruct.set2.names)), postPathSet2Unordered), 'ascend');
    subStruct.set2.postPath = postPathSet2Unordered(postPathSet2Idx);
    subStruct.set2.wildType = cellfun(@(x) contains(x, 'WT'), subStruct.set2.names);
    subStruct.set2.infection = [0 0 1 1 0 0 1 1 1 1 0 0 1 1 0 0]';
    subStruct = parainfluenza_get_perimeter(subStruct);
    subStructCombined.names = [subStruct.set1.names; subStruct.set2.names];
    subStructCombined.prePath = [subStruct.set1.prePath; subStruct.set2.prePath];
    subStructCombined.postPath = [subStruct.set1.postPath; subStruct.set2.postPath];
    subStructCombined.wildType = [subStruct.set1.wildType; subStruct.set2.wildType];
    subStructCombined.infection = [subStruct.set1.infection; subStruct.set2.infection];
    subStructCombined.prePerim = [subStruct.set1.prePerim; subStruct.set2.prePerim];
    subStructCombined.postPerim = [subStruct.set1.postPerim; subStruct.set2.postPerim];
end

function subNames = get_sub_names(setDir)
    originalNames = extractfield(setDir, 'name');
    splitNames = cellfun(@(x) split(x, '_'), originalNames, 'uni', 0);
    numSplits = cellfun(@(x) numel(x), splitNames);
    validCells = arrayfun(@(x) 4:x-1, numSplits, 'uni', 0);
    subNames = cellfun(@(x, y) join(x(y), '_'), splitNames, validCells, 'uni', 0);
    subNames = cellfun(@(x) x{1}, subNames, 'uni', 0)';
end