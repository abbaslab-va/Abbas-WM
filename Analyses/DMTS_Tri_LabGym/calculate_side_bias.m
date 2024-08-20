function biasIdx = calculate_side_bias(sessionParser)
    % Returns a value from -1:1, indicating the bias towards port visits after delay towards
    % the left choice port (-1 = 100% correct left, 0% correct right) or right choice port
    % (1 = 0% correct left, 100% correct right)

    leftTrials = sessionParser.config.trialTypes.Left;
    rightTrials = sessionParser.config.trialTypes.Right;
    leftTrialsIdx = sessionParser.trial_intersection_BpodParser('trialType', 'Left');
    rightTrialsIdx = sessionParser.trial_intersection_BpodParser('trialType', 'Right');
    choicePort = {'Port1In', 'Port2In', 'Port3In'};
    
    waitForChoiceState = sessionParser.state_times('WaitForChoicePoke', 'returnEnd', true, 'trialized', true);
    choiceMade = cellfun(@(x) cat(1, x{:}), waitForChoiceState, 'uni', 0);
    leftChosen = zeros(1, sessionParser.session.nTrials);
    rightChosen = zeros(1, sessionParser.session.nTrials);
    
    choiceTimeAll = cellfun(@(x) sessionParser.event_times('event', x, ...
        'withinState', 'WaitForChoicePoke', 'trialized', true), choicePort, 'uni', 0);
    
    for lt = find(leftTrialsIdx)
        portIdx = ismember(leftTrials, sessionParser.session.TrialTypes(lt));
        leftChoiceTime = choiceTimeAll{portIdx}(lt);
        leftChosen(lt) = any(ismember(leftChoiceTime{1}, choiceMade{lt}(1)));
        rightChosen(lt) = ~any(ismember(leftChoiceTime{1}, choiceMade{lt}(1)));
    end
    for rt = find(rightTrialsIdx)
        portIdx = ismember(rightTrials, sessionParser.session.TrialTypes(rt));
        rightChoiceTime = choiceTimeAll{portIdx}(rt);
        rightChosen(rt) = any(ismember(rightChoiceTime{1}, choiceMade{rt}(1)));
        leftChosen(rt) = ~any(ismember(rightChoiceTime{1}, choiceMade{rt}(1)));
    end
    if any(leftChosen & rightChosen)
        disp("POOP")
    end
    biasIdx = mean(rightChosen) - mean(leftChosen);
end