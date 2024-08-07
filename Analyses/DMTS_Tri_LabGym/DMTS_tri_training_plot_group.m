function figH = DMTS_tri_training_plot_group(performanceStruct)

% performanceStruct is obtained from the method DMTS_tri_training_performance

trainingMeans = smooth(mean(performanceStruct.all, 2, 'omitnan'), 3);
trainingSEM = smooth(std(performanceStruct.all, 0, 2, 'omitnan')./sqrt(size(performanceStruct.all, 2)), 3);
figH = shaded_error_plot(1:size(performanceStruct.all, 1), trainingMeans, trainingSEM, 'k', 'k', .3);
yline(50, 'LineStyle', '--', 'LineWidth', 3, 'color', 'k', 'Alpha', .6)
ylim([30 100])
clean_DMTS_figs
