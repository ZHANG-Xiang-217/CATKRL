%% CATKRL on recorded data: transfer from the one-lever to the two-lever task
% Rat 025 (R2 in the manuscript), one one-lever and one two-lever session.
% Pipeline: PCA + jPCA -> DBSCAN -> ICP alignment -> decoders trained
% one-lever -> two-lever -> one-lever, tested on held-out trial segments.
clc; clear; close all;
addpath('alignment', 'decoding', 'training', 'draw_figures', 'utils');

opt = opt_Setup_real();
rng(opt.seed);
if ~isfolder(opt.resultDir), mkdir(opt.resultDir); end

%% Neural patterns in the jPCA space
if opt.useSavedFeatures
    f = load(fullfile(opt.dataDir, opt.featureFile));
    Z1all = f.oneLeverFeature;
    Z2all = f.twoLeverFeature;
    y1 = f.oneLeverLabel;
    y2 = f.twoLeverLabel;
    segment1 = ceil((1:numel(y1))'/5);
    segment2 = ceil((1:numel(y2))'/5);
else
    [X1, y1, segment1] = loadSession(fullfile(opt.dataDir, opt.oneLeverFile), opt.channels, opt.taps);
    [X2, y2, segment2] = loadSession(fullfile(opt.dataDir, opt.twoLeverFile), opt.channels, opt.taps);
    [Z1all, Z2all] = projectToJPCA(X1, X2, opt.reduceDim);
end
Z1 = Z1all(:, 1:opt.decodingDim);
Z2 = Z2all(:, 1:opt.decodingDim);

if strcmp(opt.alignmentData, 'all')
    [R, t, info] = alignTasks(Z1all, Z2all, opt.epsOneLever, opt.epsTwoLever, ...
        opt.minPts, opt.decodingDim);
end

%% Train and test the decoders
for iRepeat = 1:opt.repeatTime
    % Held-out trial segments; the two-lever actions are balanced
    test1 = splitBySegment(y1, segment1, opt.testFraction);
    test2 = splitBySegment(y2, segment2, opt.testFraction);
    split.train1 = find(~test1);
    split.test1 = find(test1);
    split.train2 = find(~test2);
    split.train2 = split.train2(balanceActions(y2(split.train2)));
    split.test2 = find(test2);
    split.test2 = split.test2(balanceActions(y2(split.test2)));

    if strcmp(opt.alignmentData, 'train')
        % Alignment estimated from the training patterns only, then frozen
        [R, t, info] = alignTasks(Z1all(split.train1, :), Z2all(split.train2, :), ...
            opt.epsOneLever, opt.epsTwoLever, opt.minPts, opt.decodingDim);
    end
    Z2aligned = t+Z2*R;
    alignment(iRepeat) = struct('R', R, 't', t, ...
        'nCluster', [numel(info.clusterIdx1) numel(info.clusterIdx2)]); %#ok<SAGROW>

    result = runTransfer(Z1, y1, Z2, y2, Z2aligned, split, opt);
    successRate(iRepeat, :, :) = result.successRate; %#ok<SAGROW>
    for iMethod = 1:numel(result.names)
        predict{iMethod}(iRepeat, :) = result.predict{iMethod}; %#ok<SAGROW>
    end
    target(iRepeat, :) = result.output; %#ok<SAGROW>
    fprintf('Repeat %d/%d: clusters %d (one-lever) / %d (two-lever), rotation %.1f deg\n', ...
        iRepeat, opt.repeatTime, alignment(iRepeat).nCluster, acosd(min(1, (trace(R)-1)/2)));
end
names = result.names;
testNames = result.testNames;
taskEnd = result.taskEnd;

%% Results
printTestResults(successRate, names, testNames);
colors = [0 0 1; 0 0.8 0; 1 0 0];

figure('Name', 'Alignment', 'Position', [50 500 1200 380]);
plotAlignment(gcf, Z1(split.train1, :), y1(split.train1), Z2(split.train2, :), ...
    y2(split.train2), Z2aligned(split.train2, :));

figure('Name', 'Learning curves', 'Position', [50 50 700 380]);
plotLearningCurves(gca, predict, target, opt.windowSize, taskEnd, names, colors);
title('One-lever \rightarrow two-lever \rightarrow one-lever');

figure('Name', 'Held-out tests', 'Position', [780 50 800 420]);
plotTestResults(gca, successRate, names, testNames, colors);

save(fullfile(opt.resultDir, 'rat025_results.mat'), 'opt', 'names', 'testNames', ...
    'successRate', 'alignment', 'predict', 'target', 'taskEnd');
