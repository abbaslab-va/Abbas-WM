function figH = compare_bias_metrics(sideBias, performanceBias)

matSize = size(sideBias);
numElements = matSize(1) * matSize(2);
sideBias = reshape(sideBias, [numElements 1]);
performanceBias = reshape(performanceBias, [numElements 1]);
linMdl = fitlm(sideBias, performanceBias);
figH = figure;
plot(linMdl);