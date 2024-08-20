function numScanPunish = DMTS_tri_scan_punish(sessionParser)
% Counts the number of entries into ports during the ITI.

scanPunishStates = sessionParser.state_times('ScanPunish', 'trialized', true);
numScanPunish = cellfun(@(x) numel(x), scanPunishStates);
[delayTimes, numEW] = DMTS_tri_delay_length(sessionParser);