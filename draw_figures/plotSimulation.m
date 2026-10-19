function plotSimulation(fig, sim, feature, W)
%PLOTSIMULATION Fig. 3: tuning curves (a), ensemble patterns with the feature
%   plane (b) and patterns in the 2-D feature space (c).
%   feature{task}: samples x 2; W: 3 x 2 feature axes in the neural space.

color = [1 0 0; 0 1 0; 0 0 1];
marker = {'o', '^'};
actionName = {'Rest', 'Press high lever', 'Press low lever'};

% a: tuning curves, mean and SD of each neuron for each action
for iNeuron = 1:3
    ax = subplot(3, 3, 3*iNeuron-2, 'Parent', fig);
    hold(ax, 'on');
    for task = 1:2
        actions = unique(sim.label{task})';
        x = actions+0.08*(task-1.5);
        m = arrayfun(@(a) mean(sim.spike{task}(sim.label{task} == a, iNeuron)), actions);
        s = arrayfun(@(a) std(sim.spike{task}(sim.label{task} == a, iNeuron)), actions);
        plot(ax, x, m, 'k-');
        for k = 1:numel(actions)
            errorbar(ax, x(k), m(k), s(k), marker{task}, 'Color', color(actions(k), :), ...
                'MarkerFaceColor', color(actions(k), :));
        end
    end
    title(ax, sprintf('Neuron %d', iNeuron));
    xlim(ax, [0.7 3.3]); xticks(ax, 1:3); xticklabels(ax, {});
    if iNeuron == 2, ylabel(ax, 'Spike count'); end
end
xticklabels(ax, actionName);

% b: patterns in the neural ensemble space with the feature plane
% c: patterns projected on the feature plane
for task = 1:2
    ax = subplot(3, 3, [2 5]+task-1, 'Parent', fig);
    hold(ax, 'on');
    X = sim.spike{task};
    for a = unique(sim.label{task})'
        idx = sim.label{task} == a;
        scatter3(ax, X(idx, 1), X(idx, 2), X(idx, 3), 3, color(a, :), 'filled');
    end
    [g1, g2] = meshgrid([-28 28]);
    c = mean(X);
    surf(ax, c(1)+g1*W(1, 1)+g2*W(1, 2), c(2)+g1*W(2, 1)+g2*W(2, 2), ...
        c(3)+g1*W(3, 1)+g2*W(3, 2), 'FaceColor', [0.6 0.6 0.6], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    xlabel(ax, 'N1'); ylabel(ax, 'N2'); zlabel(ax, 'N3');
    title(ax, sprintf('Task %d', task));
    view(ax, [-50 25]); grid(ax, 'on');

    ax = subplot(3, 3, 8+task-1, 'Parent', fig);
    hold(ax, 'on');
    for a = unique(sim.label{task})'
        idx = sim.label{task} == a;
        scatter(ax, feature{task}(idx, 1), feature{task}(idx, 2), 3, color(a, :), 'filled');
    end
    rest = mean(feature{task}(sim.label{task} == 1, :));
    press = mean(feature{task}(sim.label{task} == 2, :));
    quiver(ax, rest(1), rest(2), press(1)-rest(1), press(2)-rest(2), 0, ...
        'Color', [0 0.63 0.91], 'LineWidth', 2, 'MaxHeadSize', 0.5);
    axis(ax, 'equal'); axis(ax, [-30 35 -25 35]); box(ax, 'on');
    xlabel(ax, 'Feature 1'); ylabel(ax, 'Feature 2');
end

end
