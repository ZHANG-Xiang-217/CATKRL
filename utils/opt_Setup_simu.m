function opt = opt_Setup_simu()
%OPT_SETUP_SIMU Settings for main_simu.m (simulated neurons of Fig. 3).

opt.seed = 0;
opt.dataDir = 'data';
opt.resultDir = 'results';
opt.dataFile = 'simulation.mat';
opt.regenerate = false;     % true: simulate again instead of loading data/simulation.mat

% Three neurons; task 1 has Rest and Press high lever, task 2 adds Press low lever.
% Spike counts are rounded Gaussian samples (negative counts set to 0).
% Rows are neurons, columns are actions (Rest, Press high, Press low).
opt.meanCount{1} = [40 20; 20 40; 25 20];
opt.meanCount{2} = [20 40 50; 20 40 20; 25 20 20];
opt.sdCount{1} = [4 4; 4 8; 4 4];
opt.sdCount{2} = [4 8 4; 4 4 4; 4 4 4];
opt.sampleNum{1} = [500 500];
opt.sampleNum{2} = [1000 500 500];

end
