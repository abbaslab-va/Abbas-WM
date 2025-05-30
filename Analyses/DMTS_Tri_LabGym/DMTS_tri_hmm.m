function hmmStruct = DMTS_tri_hmm(parserObj)
    templateObservations = zeros(1, parserObj.session.nTrials);
    hmmStruct.trialOutcomes = parserObj.session.SessionPerformance;
    hmmStruct.trialDirection = double(parserObj.trial_intersection_BpodParser('trialType', 'Right'));
    hmmStruct.numEW = cellfun(@(x) numel(x), ...
        parserObj.state_times('EarlyWithdrawal', 'trialized', true));
    hmmStruct.numScan = cellfun(@(x) numel(x), ...
        parserObj.state_times('ScanPunish', 'trialized', true));
    hmmStruct.numSampleMiss = cellfun(@(x) numel(x), ...
        parserObj.state_times('SamplePunishEW', 'trialized', true)) ...
        + cellfun(@(x) numel(x), ...
        parserObj.state_times('SamplePunish', 'trialized', true));
    hmmStruct.numDelayMiss = cellfun(@(x) numel(x), ...
        parserObj.state_times('BadDelayPoke', 'trialized', true));
    hmmStruct.numRepeats = templateObservations;
    repeatTrials = parserObj.trial_intersection_BpodParser('outcome', 'Repeat');
    hmmStruct.numRepeats(repeatTrials) = cellfun(@(x) numel(x), ...
        parserObj.state_times('Punish', 'outcome', 'Repeat', 'trialized', true));
    hmmStruct.timeToSample = time_spent_in_state(parserObj, 'WaitForSamplePoke');
    hmmStruct.timeToDelay = time_spent_in_state(parserObj, 'WaitForDelayPoke');
    hmmStruct.timeToChoice = time_spent_in_state(parserObj, 'WaitForChoicePoke');
    hmmStruct.delayLength = DMTS_tri_delay_length(parserObj);
end

function meanTimePerState = time_spent_in_state(parserObj, stateName)
    timePerState = cellfun(@(x) cellfun(@(y) diff(y), x), ...
            parserObj.state_times(stateName, 'trialized', true), 'uni', 0);
    meanTimePerState = cellfun(@(x) mean(x), timePerState);
end