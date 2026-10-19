function sim = simulateNeurons(opt)
%SIMULATENEURONS Spike counts of three simulated neurons in two tasks (Fig. 3).
%   sim.spike{task}: samples x neurons; sim.label{task}: samples x 1
%   (1 Rest, 2 Press high lever, 3 Press low lever).

rng(opt.seed);
for task = 1:2
    spike = [];
    label = [];
    for iAction = 1:numel(opt.sampleNum{task})
        n = opt.sampleNum{task}(iAction);
        mu = opt.meanCount{task}(:, iAction)';
        sd = opt.sdCount{task}(:, iAction)';
        spike = [spike; max(0, round(mu+sd.*randn(n, 3)))]; %#ok<AGROW>
        label = [label; iAction*ones(n, 1)]; %#ok<AGROW>
    end
    sim.spike{task} = spike;
    sim.label{task} = label;
end
sim.settings = opt;

end
