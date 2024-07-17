function biasIdx = DMTS_tri_side_bias(sessionParser)
leftTrials = sessionParser.config.trialTypes.Left;
rightTrials = sessionParser.config.trialTypes.Right;
leftTrialsIdx = sessionParser.trial_intersection_BpodParser('trialType', 'Left');
rightTrialsIdx = sessionParser.trial_intersection_BpodParser('trialType', 'Right');

choicePort = {'Port1In', 'Port2In', 'Port3In'};

waitForChoiceState = sessionParser.state_times('WaitForChoicePoke');
choiceMade = cellfun(@(x) x(end, 2), waitForChoiceState);
leftChosen = zeros(1, sessionParser.session.nTrials);
rightChosen = zeros(1, sessionParser.session.nTrials);

choiceTimeAll = cellfun(@(x) sessionParser.event_times('event', x, ...
    'withinState', 'WaitForChoicePoke', 'trialized', true), choicePort, 'uni', 0);

for lt = find(leftTrialsIdx)
    portIdx = ismember(leftTrials, sessionParser.session.TrialTypes(lt));
    leftChoiceTime = choiceTimeAll{portIdx}(lt);
    leftChosen(lt) = any(ismember(leftChoiceTime{1}, choiceMade(lt)));
    rightChosen(lt) = ~any(ismember(leftChoiceTime{1}, choiceMade(lt)));
end
for rt = find(rightTrialsIdx)
    portIdx = ismember(rightTrials, sessionParser.session.TrialTypes(rt));
    rightChoiceTime = choiceTimeAll{portIdx}(rt);
    rightChosen(rt) = any(ismember(rightChoiceTime{1}, choiceMade(rt)));
    leftChosen(rt) = ~any(ismember(rightChoiceTime{1}, choiceMade(rt)));

end

biasIdx = mean(rightChosen) - mean(leftChosen);