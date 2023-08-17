function ewData = adaptive_early_withdrawal(session)

% This function will analyze the early withdrawal data from the
% DMTS_Tri_Training2 task and output a structure that reveals the relationship 
% between delay time and number of early withdrawals, so that the protocol
% can automatically tailor the delay increment to the animal.
rawEvents = session.RawEvents.Trial;
numEW = zeros(1, session.nTrials);
delayLen = numEW;

if ~isfield(session, 'GUI')
    rawData = session.RawData;
    for trial = 1:session.nTrials
        stateNames = rawData.OriginalStateNamesByNumber{trial};
        trialEvents = rawData.OriginalStateData{trial};
        orderedStateNames = stateNames(trialEvents);
        delayStart = cellfun(@(x) strcmp(x, 'DelayTimer'), orderedStateNames);
        delayEnd = cellfun(@(x) strcmp(x, 'DelayOn'), orderedStateNames);
        lastDelayStart = find(delayStart, 1, 'last');
        lastDelayOn = find(delayEnd, 1, 'last');
        delayLen(trial) = rawData.OriginalStateTimestamps{trial}(lastDelayOn) - rawData.OriginalStateTimestamps{trial}(lastDelayStart);
    end
else
    delayLen = extractfield(session.GUI, 'DelayHoldTime');
end

for trial = 1:session.nTrials
    ewStates = rawEvents{trial}.States.EarlyWithdrawal;
    if ~isnan(ewStates)
        numEW(trial) = size(ewStates, 1);
    else
        numEW(trial)  = 0;
    end
end

ewData = [];