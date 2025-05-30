function [biasByEra, biasAligned] = DMTS_tri_training_bias_by_delay(trainingSessions, delayBins)

biasByAnimal = cellfun(@(x) arrayfun(@(y) ...
    side_bias_by_delay(y, delayBins), x, 'uni', 0), trainingSessions, 'uni', 0);
biasByDelay = cell(1, numel(delayBins));
for d = 1:numel(delayBins)
    biasByDelay{d} = cellfun(@(x) cellfun(@(y) y{d}, x), biasByAnimal, 'uni', 0);
end
biasAligned = cellfun(@(x) abs(align_training_data(trainingSessions, x)), biasByDelay, 'uni', 0);

biasByEra = cellfun(@(x) DMTS_tri_results_by_era(x), biasAligned, 'uni', 0);