function biasIdx = DMTS_tri_side_bias(sessionParser)

leftTrials = [1 4 5];
leftTrialsIdx = ismember(sessionParser.session.TrialTypes, leftTrials);
rightTrials = [2 3 6];
rightTrialsIdx = ismember(sessionParser.session.TrialTypes, rightTrials);

choicePort = {'Port1In', 'Port2In', 'Port3In'};

waitForChoiceState = sessionParser.state_times('WaitForChoicePoke');
choiceMade = cellfun(@(x) x(end, 2), waitForChoiceState);
leftChosen = zeros(1, sessionParser.session.nTrials);
rightChosen = zeros(1, sessionParser.session.nTrials);
for lt = find(leftTrialsIdx)
    portIdx = ismember(leftTrials, sessionParser.session.TrialTypes(lt));
    leftChoice = choicePort{portIdx};
    leftChoiceTime = sessionParser.event_times('event', leftChoice, 'withinState', 'WaitForChoicePoke', 'trials', lt);
    leftChosen(lt) = any(ismember(leftChoiceTime{1}, choiceMade(lt)));
    rightChosen(lt) = ~any(ismember(leftChoiceTime{1}, choiceMade(lt)));
end
for rt = find(rightTrialsIdx)
    portIdx = ismember(rightTrials, sessionParser.session.TrialTypes(rt));
    rightChoice = choicePort{portIdx};
    rightChoiceTime = sessionParser.event_times('event', rightChoice, 'withinState', 'WaitForChoicePoke', 'trials', rt);
    rightChosen(rt) = any(ismember(rightChoiceTime{1}, choiceMade(rt)));
    leftChosen(rt) = ~any(ismember(rightChoiceTime{1}, choiceMade(rt)));

end

biasIdx = mean(rightChosen) - mean(leftChosen);