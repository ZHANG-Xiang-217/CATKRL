function successRate = testClusteringKRL(state, input, output, opt)
%TESTCLUSTERINGKRL Success rate of a stored clustering KRL decoder on held-out data.
%   input: dim x N; output: 1 x N.

predictAction = zeros(1, size(input, 2));
for iTime = 1:size(input, 2)
    predictAction(iTime) = clusteringQAGKRLDecodingByDistanceWithSurprise( ...
        input(:, iTime), state.cluster, state.weightToOutput, opt.kernelWidth, state.centroid);
end
successRate = mean(predictAction == output);

end
