function [predictAction, state] = trainClusteringKRL(input, output, opt, recordIdx)
%TRAINCLUSTERINGKRL Train the clustering kernel RL decoder sample by sample.
%   input: dim x T neural patterns; output: 1 x T true actions (reward is
%   given when the decoded action equals the true action).
%   CATKRL is this decoder applied to aligned task-2 patterns.
%   state{k}: decoder parameters stored at time recordIdx(k).

actionNum = 3;
cluster = {input(:, 1)};
weightToOutput = {zeros(actionNum, 1)};
centroid = input(:, 1);
clusterSize = 1;
trueClusterLabel = {output(1)};
predictAction = ones(1, size(input, 2));
state = cell(1, numel(recordIdx));

for iTime = 2:size(input, 2)
    [action, chosenProbability, minDistanceC, nearestCenter, minDistanceQ, nearestPoint] = ...
        clusteringQAGKRLDecodingByDistanceWithSurprise(input(:, iTime), cluster, ...
        weightToOutput, opt.kernelWidth, centroid);

    if action == output(iTime)
        fDelta = errorTransform(1-chosenProbability);
    else
        fDelta = errorTransform(-1);
    end

    [cluster, weightToOutput, centroid, clusterSize, trueClusterLabel] = ...
        clusteringQAGKRLUpdateByDistance(input(:, iTime), action, fDelta, ...
        cluster, weightToOutput, centroid, clusterSize, opt.learningRate, ...
        opt.qThreshold, opt.cThreshold, minDistanceC, nearestCenter, ...
        minDistanceQ, nearestPoint, 1, trueClusterLabel, output(iTime));
    predictAction(iTime) = action;

    for k = find(iTime == recordIdx)
        state{k} = struct('cluster', {cluster}, 'weightToOutput', {weightToOutput}, ...
            'centroid', centroid);
    end
end

end
