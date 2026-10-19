function [predictAction,chosenProbability,minDistanceC,nearestCenter,...
    minDistanceQ,nearestPoint,probabilityForAllAction] =...
    clusteringQAGKRLDecodingByDistanceWithSurprise(...
    spike, cluster, weightToOutput, kernelWidth ,centroid)
%     initialNumCount,initialNumCountThr, legacy parameter
%NICEJACCALCULATEACTION Summary of this function goes here
%   spike, n x 1, n is dimension
%   activatedAction: column vector for the index of activated action

    distanceToCenter=spike-centroid;
    distanceToCenter=sqrt(sum(distanceToCenter.^2,1));
    minDistanceC=min(distanceToCenter);
    nearestCenter=find(distanceToCenter==minDistanceC,1);
    
    distanceToPoint=spike-cluster{nearestCenter}; 
    distanceToPoint=sqrt(sum(distanceToPoint.^2)); 
    minDistanceQ=min(distanceToPoint);
    nearestPoint=find(distanceToPoint==minDistanceQ,1);
    
    %% Decide the action strategy
%     if initialNumCount(nearestCenter)<=initialNumCountThr
%         actionStrategy='maxValue';
%     else
        actionStrategy='softmax';
%     end
    
    %% Caluculate the output
    tempKernel=gaussianKernel(spike,cluster{nearestCenter},kernelWidth);
    tempKernel=tempKernel';
    qOutput=weightToOutput{nearestCenter}*tempKernel;
    
    %% Select action based on softmax
    if strcmp(actionStrategy,'maxValue')
        pOutput=[];
        pOutput=softmax(qOutput);
        chooseAction=find(pOutput==max(pOutput));
        if length(chooseAction)>1
           chooseAction=chooseAction(randi(length(chooseAction))); 
        end
        predictAction=chooseAction;
        chosenProbability=pOutput(chooseAction);
    else
        pOutput=[];
        pOutput=softmax(qOutput);
        cumP=cumsum(pOutput);
        rnd=rand();
        chooseAction=find(rnd<=cumP,1);
        predictAction=chooseAction;
        chosenProbability=pOutput(chooseAction);
    end
    
    probabilityForAllAction=pOutput;

end

