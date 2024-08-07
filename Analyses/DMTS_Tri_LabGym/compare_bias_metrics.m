function figH = compare_bias_metrics(sideBias, performanceBias)

matSize = size(sideBias);
numElements = matSize(1) * matSize(2);
sideBias = reshape(sideBias, [numElements 1]);
performanceBias = reshape(performanceBias, [numElements 1]);
linMdl = fitlm(sideBias, performanceBias);
figH = figure;
plot(linMdl);
hold on
xlabel("Side visit bias")
ylabel("Directional performance bias")
scatter(sideBias, performanceBias, 20, 'filled', 'k')

clean_DMTS_figs
l = legend({"Remove me", "Fit", "95% Confidence Bounds", "Sessions"}, "Color", 'w', "TextColor", 'k')
