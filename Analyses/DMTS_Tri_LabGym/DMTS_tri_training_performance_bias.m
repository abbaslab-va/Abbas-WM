function perfBiasData = DMTS_tri_training_performance_bias(parserArray)
    biasByAnimal = cellfun(@(x) arrayfun(@(y) calculate_performance_bias(y), x), parserArray, 'uni', 0);
    perfBiasData = align_training_data(parserArray, biasByAnimal);
end

