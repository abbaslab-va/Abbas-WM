function dateIdx = align_training_data(parserArray, data)

% Returns a DxS session index matrix, where D is the total number of days
% that have data, and S is the number of subjects. Takes a parserArray from
% DMTS_tri_pipeline_init

trainingDates = cellfun(@(x) arrayfun(@(y) datetime(y.session.Info.SessionDate), x, 'uni', 0), parserArray, 'uni', 0);
allDates = [];
for i = 1:numel(trainingDates)
    allDates = [allDates, [trainingDates{i}{:}]];
end
uniqueDates = unique(allDates);
numDates = numel(uniqueDates);
numAnimals = numel(parserArray);
if all(cellfun(@(x) isstruct(x), data))
    dateIdx = cell(numDates, numAnimals);
    for i = 1:numAnimals
        [~, loc] = ismember([trainingDates{i}{:}], uniqueDates);
        dateIdx(loc, i) = arrayfun(@(x) x, data{i}, 'uni', 0);
    end
else
    dateIdx = nan(numDates, numAnimals);
    for i = 1:numAnimals
        [~, loc] = ismember([trainingDates{i}{:}], uniqueDates);
        dateIdx(loc, i) = data{i};
    end
end