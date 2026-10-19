function predictAction=AGREL_testing(...
    spike,weightFromInputToHidden,weightFromHiddenToOutput)
% AGREL
% The row of spike represents channels, the column represents time

% spike=spike./max(spike,[],2); % Normalize

predictAction=ones(1,size(spike,2));

%% Initialization
actionNum=size(weightFromHiddenToOutput,1);
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
    
end

end