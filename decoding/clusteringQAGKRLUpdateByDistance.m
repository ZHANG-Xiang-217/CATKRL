function [ cluster, weightToOutput, centroid,clusterSize,...
    trueClusterLabel ] = clusteringQAGKRLUpdateByDistance(...
    spike,chooseAction,fDelta,...
    cluster,weightToOutput,centroid,clusterSize,learningRate,qThreshold,cThreshold,...
    minDistanceC,nearestCenter,minDistanceQ,nearestPoint,transferOption,...
    trueClusterLabel,groundTruthAction)
%NICEJACUPDATE Summary of this function goes here
%   spike is a column vector

    actionNum=size(weightToOutput{1},1);
    tempWeight=zeros(actionNum,1); 
    tempWeight(chooseAction)=learningRate*fDelta;
    switch transferOption
        case 0      % The case without transfer
            if minDistanceC<=cThreshold       
                if minDistanceQ>qThreshold   % cluster and retain
                    weightToOutput{nearestCenter}=[...
                        weightToOutput{nearestCenter} ...
                        tempWeight];
                    centroid(:,nearestCenter)=(clusterSize(nearestCenter)*...
                        centroid(:,nearestCenter)+...
                        spike)/(clusterSize(nearestCenter)+1);
                    cluster{nearestCenter}=[cluster{nearestCenter} spike];
                    clusterSize(nearestCenter)=clusterSize(nearestCenter)+1;
                    trueClusterLabel{nearestCenter}=[...
                        trueClusterLabel{nearestCenter} groundTruthAction];
                else                        % cluster and merge
                    weightToOutput{nearestCenter}(:,nearestPoint)=tempWeight+...
                        weightToOutput{nearestCenter}(:,nearestPoint);
                end
            else                            % new cluster
                % Initialization
                centroid=[centroid spike];
                clusterSize=[clusterSize 1];
                weightToOutput{length(clusterSize)}=tempWeight;           
                cluster{length(clusterSize)}=spike;
                trueClusterLabel{length(clusterSize)}=groundTruthAction;
            end
        case 1      % The case using transfer from the nearest cluster
            if minDistanceC<=cThreshold       
                if minDistanceQ>qThreshold   % cluster and retain
                    weightToOutput{nearestCenter}=[...
                        weightToOutput{nearestCenter} ...
                        tempWeight];
                    centroid(:,nearestCenter)=(clusterSize(nearestCenter)*...
                        centroid(:,nearestCenter)+...
                        spike)/(clusterSize(nearestCenter)+1);
                    cluster{nearestCenter}=[cluster{nearestCenter} spike];
                    clusterSize(nearestCenter)=clusterSize(nearestCenter)+1;
                else                        % cluster and merge
                    weightToOutput{nearestCenter}(:,nearestPoint)=tempWeight+...
                        weightToOutput{nearestCenter}(:,nearestPoint);
                end
            else                            % new cluster using transfer
                % Initialization
                centroid=[centroid spike];
                clusterSize=[clusterSize 1];
                weightToOutput{length(clusterSize)}=[...
                        weightToOutput{nearestCenter} ...
                        tempWeight];          
                cluster{length(clusterSize)}=[cluster{nearestCenter} spike];
            end
            
        otherwise     
    end
end

