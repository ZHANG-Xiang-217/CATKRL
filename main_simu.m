%% Simulated neurons (Fig. 3)
% Three neurons in two tasks. Neuron 1 changes its preferred action between
% tasks while the shapes of the shared action clusters and their distance
% stay similar, which rotates the Rest-to-Press direction in a 2-D linear
% feature space.
clc; clear; close all;
addpath('draw_figures', 'utils');

opt = opt_Setup_simu();
if ~isfolder(opt.resultDir), mkdir(opt.resultDir); end

%% Simulated spike counts
dataFile = fullfile(opt.dataDir, opt.dataFile);
if opt.regenerate || ~isfile(dataFile)
    sim = simulateNeurons(opt);
    save(dataFile, '-struct', 'sim');
else
    sim = load(dataFile);
end

%% Tuning: mean and SD of each neuron for each action
actionName = {'Rest', 'Press high lever', 'Press low lever'};
fprintf('%-10s%-8s%-18s%8s%8s%8s\n', 'Neuron', 'Task', 'Action', 'Mean', 'SD', 'n');
for iNeuron = 1:3
    for task = 1:2
        for a = unique(sim.label{task})'
            v = sim.spike{task}(sim.label{task} == a, iNeuron);
            fprintf('%-10d%-8d%-18s%8.2f%8.2f%8d\n', iNeuron, task, actionName{a}, mean(v), std(v), numel(v));
        end
    end
end

%% Feature space: first two principal components of task 1
W = pca(sim.spike{1});
W = W(:, 1:2);
restToPress = mean(sim.spike{1}(sim.label{1} == 2, :))-mean(sim.spike{1}(sim.label{1} == 1, :));
if restToPress*W(:, 1) < 0, W(:, 1) = -W(:, 1); end     % feature 1 points from Rest to Press
for task = 1:2
    feature{task} = (sim.spike{task}-mean(sim.spike{task}))*W; %#ok<SAGROW>
    direction(task, :) = mean(feature{task}(sim.label{task} == 2, :))- ...
        mean(feature{task}(sim.label{task} == 1, :)); %#ok<SAGROW>
end
theta = atan2d(direction(2, 2), direction(2, 1))-atan2d(direction(1, 2), direction(1, 1));
fprintf('\nRest-to-Press direction rotates by %.1f deg from task 1 to task 2\n', theta);

figure('Name', 'Fig. 3', 'Position', [50 50 1200 650]);
plotSimulation(gcf, sim, feature, W);

save(fullfile(opt.resultDir, 'simulation_results.mat'), 'opt', 'W', 'feature', 'theta');
