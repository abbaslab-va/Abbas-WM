function figH = DMTS_tri_testing_plot_individual(sessionPerformance)

meanAll = sessionPerformance.all.animals;
subIdx = sessionPerformance.all.subIdx;
animalPerf = cellfun(@(x) sessionPerformance.all.sessions(x), subIdx, 'uni', 0);
semAll = cellfun(@(x) std(x)/sqrt(numel(x)), animalPerf);
xOffset = num2cell(1:numel(animalPerf));
jitterVecAll = cellfun(@(x) (zeros(1, numel(x)) + rand(1, numel(x)) - .5).*.5, animalPerf, 'uni', 0);
scatterX = cellfun(@(x, y, z) zeros(1, numel(x)) + y + z, animalPerf, xOffset, jitterVecAll, 'uni', 0);
scatterY = cellfun(@(x, y) x + y, animalPerf, jitterVecAll, 'uni', 0);
figH = figure;
hold on
bar(meanAll, 'facecolor', 'flat', 'FaceColor', 'k', 'FaceAlpha', .6, 'EdgeColor', 'none');
cellfun(@(x, y) scatter(x, y, 20, 'k', 'filled'), scatterX, animalPerf)
errorbar(meanAll, semAll, 'vertical', 'Color','k', 'LineWidth', 3, 'LineStyle', 'none')
xlim([.5, numel(animalPerf) + .5])
ylim([30 100])
clean_DMTS_figs
yline(50, 'LineStyle', '--', 'LineWidth', 3, 'Color', 'k', 'Alpha', .6)