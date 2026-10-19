function [predictAction,weightFromInputToHiddenRecorded,...
    weightFromHiddenToOutputRecorded,actionProbability]=AGREL(...
    spike,action,learningRate,hiddenUnitNum,recordIdx)
% AGREL
% The row of spike represents channels, the column represents time

% spike=spike./max(spike,[],2); % Normalize

predictAction=ones(1,size(spike,2));

%% Initialization
actionNum=max(action);
weightFromInputToHidden=2*rand(hiddenUnitNum,size(spike,1))-1;
weightFromHiddenToOutput=2*rand(actionNum,hiddenUnitNum)-1;
actionProbability=zeros(size(spike,2),actionNum);

for iSpike=1:size(spike,2)
    
    %% Caluculate the output
    inputUnit=spike(:,iSpike);
    hiddenUnit=mySigmoid(weightFromInputToHidden*inputUnit);
    outputUnit=weightFromHiddenToOutput*hiddenUnit;
    
    %% Select action based on softmax
    pOutput=softmax(outputUnit);
    cumP=cumsum(pOutput);
    rnd=rand();
    chooseAction=find(rnd<=cumP,1);
    predictAction(iSpike)=chooseAction;
    actionProbability(iSpike,:)=pOutput;
    
    %% Calculate reward and error
    if chooseAction==action(iSpike)
        r=1;
        delta=r-pOutput(chooseAction);
        fDelta=errorTransform(delta);
    else
        r=0;
        delta=-1;
        fDelta=errorTransform(delta);
    end
    
    %% Update weight
    weightFromHiddenToOutput(chooseAction,:)=weightFromHiddenToOutput(chooseAction,:)+...
        learningRate*fDelta*hiddenUnit';
    weightFromInputToHidden=weightFromInputToHidden+...
        learningRate*fDelta*...
        (hiddenUnit.*(1-hiddenUnit).*weightFromHiddenToOutput(chooseAction,:)')*...
        inputUnit';
    
    %% Record weight
    [~,I]=find(iSpike==recordIdx);
    % More than one requested checkpoint can refer to the same sample
    % (for example transfer/memory checkpoint 0).  Store the identical
    % state in every corresponding output slot.
    for iRecord=I
        weightFromHiddenToOutputRecorded{iRecord}=weightFromHiddenToOutput;
        weightFromInputToHiddenRecorded{iRecord}=weightFromInputToHidden;
    end
    
end

end
