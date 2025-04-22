function trialProportion = DMTS_tri_trial_proportion_by_delay(sessionParser, delayBins)

numTrials = sessionParser.session.nTrials;
trialsByDelay = cellfun(@(x) sum(sessionParser.trial_intersection_BpodParser('delayLength', x)), delayBins);
trialProportion = trialsByDelay/numTrials;