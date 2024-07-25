function sideBiasData = DMTS_tri_training_side_bias(parserArray)
    biasByAnimal = cellfun(@(x) arrayfun(@(y) calculate_side_bias(y), x), parserArray, 'uni', 0);
    sideBiasData = align_training_data(parserArray, biasByAnimal);
end
