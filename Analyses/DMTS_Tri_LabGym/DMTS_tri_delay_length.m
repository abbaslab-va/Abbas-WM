function [delayTimes, ewByDelay] = DMTS_tri_delay_length(sessionParser, varargin)
% OUTPUT:
%     delayTimes - a 1xT array of delay lengths in seconds, where T is the number of trials in sessionParser
%     ewByDelay - a 1xB array of binned early withdrawal counts or proportions, 
%     where B is the number of bins in the variable binRanges, defined below.
% INPUT:
%     sessionParser - a BpodSession object
% VARIABLE INPUT PAIRS:
%     trialType - a string of trial types defined in the configs

presets = PresetManager(varargin{:});
validCalcType = @(x) strcmp(x, 'raw') || strcmp(x, 'proportion');
defaultBins = {[0 3] [3.1 4] [4.1 5] [5.1 6] [6.1 7]};
p = inputParser;
p.KeepUnmatched = true;
addParameter(p, 'calcType', 'raw', validCalcType)
addParameter(p, 'binRanges', defaultBins, @iscell)
parse(p, varargin{:});
calcType = p.Results.calcType;
binRanges = p.Results.binRanges;
numBins = numel(binRanges);
validTrials = sessionParser.trial_intersection_BpodParser('trialType', presets.trialType);
if ~any(validTrials)
    delayTimes = nan(1, numBins);
    ewByDelay = nan(1, numBins);
    return
end
% Get delay length for each trial
try
    delayTimes = extractfield(sessionParser.session.GUI, 'DelayHoldTime');
catch
    delayReward = sessionParser.state_times('DelayOn', 'trialized', true, 'returnStart', true);
    delayStart = sessionParser.state_times('WaitForDelayPoke', 'trialized', true, 'returnEnd', true);
    delayTimes = cellfun(@(x, y) x{end} - y{end}, delayReward, delayStart);
end
delayTimes = delayTimes(validTrials);
% Count and discretize early withdrawals by delay length
ewTimes = sessionParser.state_times('EarlyWithdrawal', 'trialized', true, 'trialType', presets.trialType);
rangeIdx = (1:numBins) - 1;
delayBins = cellfun(@(x) discretize(delayTimes, x), binRanges, 'uni', 0);
delayBins = cat(1, delayBins{:}) + rangeIdx';
delayBins(isnan(delayBins)) = [];
ewCount = cellfun(@(x) numel(x), ewTimes);
if presets.trialized
    ewByDelay = cellfun(@(x) any(ewCount(delayBins == x)), num2cell(1:numBins));
else
    ewByDelay = cellfun(@(x) sum(ewCount(delayBins == x)), num2cell(1:numBins));
end
if strcmp(calcType, 'proportion')
    numDelay = cellfun(@(x) sum(delayBins == x), num2cell(1:numBins));
    ewByDelay = ewByDelay./numDelay;
end

