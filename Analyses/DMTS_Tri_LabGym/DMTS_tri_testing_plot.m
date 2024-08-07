function [animalFigH, sessionFigH] = DMTS_tri_testing_plot(alignmentStruct, color)

% alignmentStruct is obtained from the method DMTS_tri_testing_performance
numAlignments = numel(alignmentStruct.alignments);
alignmentField = alignmentStruct.alignments;
if all(cellfun(@(x) ischar(x), alignmentField))
    alignmentString = {'1', '2', '3'};
else
    alignmentString = {'0-3', '3-4', '4-5', '5-6', '6-7'};
end

animalCells = alignmentStruct.animals;
animalFigH = bar_and_scatter(animalCells, 'color', color);
clean_DMTS_figs
xticks(1:numAlignments)
xticklabels(alignmentString)

sessionCells = alignmentStruct.sessions;
sessionFigH = bar_and_scatter(sessionCells, 'color', color);
clean_DMTS_figs
xticks(1:numAlignments)
xticklabels(alignmentString)