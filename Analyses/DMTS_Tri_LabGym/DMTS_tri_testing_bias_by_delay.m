function biasByDelay = DMTS_tri_testing_bias_by_delay(testingSessions, delayBins)

biasByAnimal = arrayfun(@(x) side_bias_by_delay(x.bpod, delayBins), testingSessions.sessions, 'uni', 0);
biasByDelay = cell(1, numel(delayBins));
for d = 1:numel(delayBins)
    biasByDelay{d} = cellfun(@(x) abs(x{d}), biasByAnimal);
end
biasByDelay = cat(1, biasByDelay{:})';
% bar_and_error(biasByDelay, 3)
% clean_DMTS_figs
% xticklabels({'0-3', '3-5', '5-7'})
% xlabel('Delay Bins')
% ylabel('Absolute bias')
