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
p = inputParser;
p.KeepUnmatched = true;
addParameter(p, 'calcType', 'raw', validCalcType)
parse(p, varargin{:});
calcType = p.Results.calcType;


validTrials = sessionParser.trial_intersection_BpodParser('trialType', presets.trialType);
if ~any(validTrials)
    delayTimes = nan(1, 5);
    ewByDelay = nan(1, 5);
    return
end
% Get delay length for each trial
try
    delayTimes = extractfield(sessionParser.session.GUI, 'DelayHoldTime');
catch
    delayReward = sessionParser.state_times('DelayOn', 'trialized', true, 'returnStart', true);
    delayStart = sessionParser.state_times('WaitForDelayPoke', 'trialized', true, 'returnEnd', true);
    delayTimes = cellfun(@(x, y) x{1} - y{end}, delayReward, delayStart);
end
delayTimes = delayTimes(validTrials);
% Count and discretize early withdrawals by delay length
ewTimes = sessionParser.state_times('EarlyWithdrawal', 'trialized', true, 'trialType', presets.trialType);
binRanges = {[0 3] [3.1 4] [4.1 5] [5.1 6] [6.1 7]};
rangeIdx = 0:4;
delayBins = cellfun(@(x) discretize(delayTimes, x), binRanges, 'uni', 0);
delayBins = cat(1, delayBins{:}) + rangeIdx';
delayBins(isnan(delayBins)) = [];
ewCount = cellfun(@(x) numel(x), ewTimes);
ewByDelay = cellfun(@(x) sum(ewCount(delayBins == x)), num2cell(1:5));
if ~strcmp(calcType, 'raw')
    numDelay = cellfun(@(x) sum(delayBins == x), num2cell(1:5));
    ewByDelay = ewByDelay./numDelay;
end

