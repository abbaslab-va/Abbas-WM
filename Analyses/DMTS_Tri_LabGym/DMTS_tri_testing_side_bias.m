function sideBiasData = DMTS_tri_testing_side_bias(managerObj)

sideBiasData = arrayfun(@(x) calculate_side_bias(x.bpod), managerObj.sessions);
