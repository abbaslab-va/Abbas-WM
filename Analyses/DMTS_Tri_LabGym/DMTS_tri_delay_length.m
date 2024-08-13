function [delayTimes, ewByDelay] = DMTS_tri_delay_length(sessionParser)

% Get delay length for each trial
try
    delayTimes = extractfield(sessionParser.session.GUI, 'DelayHoldTime');
catch
    delayReward = sessionParser.state_times('DelayOn', 'trialized', true, 'returnStart', true);
    delayStart = sessionParser.state_times('WaitForDelayPoke', 'trialized', true, 'returnEnd', true);
    delayTimes = cellfun(@(x, y) x{1} - y{end}, delayReward, delayStart);
end
% Count and discretize early withdrawals by delay length
ewTimes = sessionParser.state_times('EarlyWithdrawal', 'trialized', true);
binRanges = {[0 3] [3.1 4] [4.1 5] [5.1 6] [6.1 7]};
rangeIdx = 0:4;
delayBins = cellfun(@(x) discretize(delayTimes, x), binRanges, 'uni', 0);
delayBins = cat(1, delayBins{:}) + rangeIdx';
delayBins(isnan(delayBins)) = [];
ewCount = cellfun(@(x) numel(x), ewTimes);
ewByDelay = cellfun(@(x) sum(ewCount(delayBins == x)), num2cell(1:5));

