function [R,t,costValue,midR,midT,midCorr] = ICP(sourceCluster,targetCluster)
%   Iterative Closest Point method

%   sourceCluster and targetCluster are cell array
%   For each cluster, row is sample, column is dimension
%   R is the rotational matrix, t is the translation vector

% Find the most similar pairs
sourceClusterNum=length(sourceCluster);
targetClusterNum=length(targetCluster);
similarClusterMatrix=zeros(sourceClusterNum,targetClusterNum);
for iSource=1:sourceClusterNum
    tempA=sourceCluster{iSource};
    [~,~,latentA]=pca(tempA);
    for iTarget=1:targetClusterNum
        tempB=targetCluster{iTarget};
        [~,~,latentB]=pca(tempB);
        similarClusterMatrix(iSource,iTarget)=...
            sqrt(sum((log(latentA./latentB)).^2));
    end
end
[~,similarClusterIdx]=min(similarClusterMatrix,[],2);

% Generate the corresponding matrix
sourceTotal=[];
targetTotal=[];
A=[];
for iSource=1:sourceClusterNum
   sourceTotal=[sourceTotal; sourceCluster{iSource}];
   A=[A; sourceCluster{iSource}-mean(sourceCluster{iSource})];
end
for iTarget=1:targetClusterNum
   targetTotal=[targetTotal; targetCluster{iTarget}];
end

% Intialization
dim=size(sourceCluster{1},2);
R=eye(dim);
idx=0;
corrB=zeros(size(A));

% for iter=1:iterationTime
while 1
    previousCorrB=corrB;
    idx=idx+1;

    corrB=[];
    midCorr{idx}=[];
    for iSource=1:sourceClusterNum
        mostSimilarCluster=targetCluster{similarClusterIdx(iSource)};
        mostSimilarCluster=mostSimilarCluster-mean(mostSimilarCluster);  % Notice
        D=pdist2((sourceCluster{iSource}-mean(sourceCluster{iSource}))*R,...
            mostSimilarCluster);
        [~,corrIdx]=min(D,[],2);
        corrB=[corrB; mostSimilarCluster(corrIdx,:)];
        midCorr{idx}=[midCorr{idx};...
            targetCluster{similarClusterIdx(iSource)}(corrIdx,:)];
    end
    
%     figure
%     plot(A(:,1),A(:,2),'r*');
%     hold on
%     plot(B(:,1),B(:,2),'go');
%     for iPoint=1:size(A,1)
%         plot([A(iPoint,1) corrQ(iPoint,1)],[A(iPoint,2) corrQ(iPoint,2)],'k')
%     end
%     hold off
    
    A=A-mean(A);
    corrB=corrB-mean(corrB);
    M=A'*corrB;  
    [U,~,V]=svd(M);
    dia=ones(dim,1);
    dia(end)=det(U'*V);
    R=U*diag(dia)*V';
    
    % Store the intermediate results
    midR{idx}=R;
    midT{idx}=mean(targetTotal)-mean(sourceTotal)*R;    
    costValue(idx)=norm(A*R-corrB,'fro');   
    if norm(previousCorrB-corrB)==0
       break; 
    end

end

t=mean(targetTotal)-mean(sourceTotal)*R;

end

