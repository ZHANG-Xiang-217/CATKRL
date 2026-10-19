function [R, t, info] = alignTasks(Z1, Z2, eps1, eps2, minPts, alignDim)
%ALIGNTASKS Align task 2 to task 1 through their most similar neural clusters.
%   Z1, Z2: patterns x dim of task 1 (target) and task 2 (source).
%   1. DBSCAN on all columns of each task.
%   2. The cluster pair with the smallest covariance matrix distance
%      (eigenvalue spectra, first alignDim columns) is selected.
%   3. ICP on that pair gives the rotation R and translation t.
%   Aligned task-2 patterns are t + Z2(:, 1:alignDim)*R.

clusterIdx1 = dbscan(Z1', eps1, minPts);
clusterIdx2 = dbscan(Z2', eps2, minPts);
if isempty(clusterIdx1) || isempty(clusterIdx2)
    error('alignTasks:noCluster', ...
        'DBSCAN found no cluster (task 1: %d, task 2: %d).', ...
        numel(clusterIdx1), numel(clusterIdx2));
end

target = cellfun(@(i) Z1(i, 1:alignDim), clusterIdx1, 'UniformOutput', false);
source = cellfun(@(i) Z2(i, 1:alignDim), clusterIdx2, 'UniformOutput', false);

distance = zeros(numel(source), numel(target));
for iSource = 1:numel(source)
    [~, ~, latentSource] = pca(source{iSource});
    for iTarget = 1:numel(target)
        [~, ~, latentTarget] = pca(target{iTarget});
        distance(iSource, iTarget) = sqrt(sum(log(latentSource./latentTarget).^2));
    end
end
[~, k] = min(distance(:));
[iSource, iTarget] = ind2sub(size(distance), k);

[R, t, costValue, midR, midT] = ICP(source(iSource), target(iTarget));

info.clusterIdx1 = clusterIdx1;
info.clusterIdx2 = clusterIdx2;
info.pair = [iTarget iSource];
info.distance = distance;
info.costValue = costValue;
info.midR = midR;
info.midT = midT;

end
