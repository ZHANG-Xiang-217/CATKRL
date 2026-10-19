function opt = opt_Setup_real()
%OPT_SETUP_REAL Settings for main_real.m (rat 025, R2 in the manuscript).

opt.seed = 0;
opt.dataDir = 'data';
opt.resultDir = 'results';
opt.oneLeverFile = 'rat025_one_lever.mat';
opt.twoLeverFile = 'rat025_two_lever.mat';
opt.featureFile = 'rat025_jpca_features.mat';

% true: decode the saved jPCA coordinates used for the results in the paper;
% false: recompute the coordinates from the binned spike counts
opt.useSavedFeatures = true;

% Neural features: selected channels at the reference bin and preceding bins
opt.channels = [2 3 12 18 30 32];
opt.taps = 0:4;
opt.reduceDim = 5;          % principal components kept before jPCA
opt.decodingDim = 3;        % jPCA dimensions used for ICP and decoding

% Alignment: DBSCAN on all jPCA dimensions, ICP on the decoding dimensions
opt.epsOneLever = 0.15;     % DBSCAN neighbourhood radius, one-lever task
opt.epsTwoLever = 0.4;      % DBSCAN neighbourhood radius, two-lever task
opt.minPts = 30;            % minimum points per DBSCAN cluster
% 'all': estimate the alignment from all patterns of both sessions, as for the
%        results in the paper (label-free, but includes the held-out patterns);
% 'train': estimate it from the training patterns only
opt.alignmentData = 'all';

% Held-out test set, drawn by trial segment (5 consecutive patterns)
opt.testFraction = 0.2;

% Training schedule: one-lever -> two-lever -> one-lever
opt.repeatTime = 5;         % repeats with different splits and orders (20 in the paper)
opt.epochNum = 2;           % passes over each training set
opt.windowSize = 200;       % sliding window for the learning curves
opt.checkpoint = 200;       % samples after a task switch for the initial-transfer test

% Clustering KRL (CATKRL uses the same settings on aligned inputs)
opt.kernelWidth = 1.5;
opt.learningRate = 0.1;
opt.qThreshold = 0;
opt.cThreshold = 2.5;

% AGREL
opt.hiddenUnitNum = 25;
opt.learningRateAGREL = 0.025;

end
