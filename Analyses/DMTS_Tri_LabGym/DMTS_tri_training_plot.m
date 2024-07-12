function figH = DMTS_tri_training_plot(performanceStruct)

% performanceStruct is obtained from the method DMTS_tri_training_performance

trainingMeans = mean(performanceStruct.all, 2, 'omitnan');
trainingSEM = std(performanceStruct.all, 0, 2, 'omitnan')./sqrt(size(performanceStruct.all, 2));
figH = shaded_error_plot(1:size(performanceStruct.all, 1), trainingMeans, trainingSEM, 'k', 'k', .3);
clean_DMTS_figs
