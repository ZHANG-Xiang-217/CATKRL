function plotLearningCurves(ax, predict, output, windowSize, taskEnd, names, colors)
%PLOTLEARNINGCURVES Sliding-window success rate, mean and SD across repeats.
%   predict{iMethod}: repeat x T decoded actions; output: repeat x T true actions.

hold(ax, 'on');
h = gobjects(1, numel(predict));
for iMethod = 1:numel(predict)
    hit = double(predict{iMethod} == output);
    rate = movmean(hit, [windowSize-1 0], 2, 'Endpoints', 'fill');
    m = mean(rate, 1, 'omitnan');
    s = std(rate, 0, 1, 'omitnan');
    x = 1:numel(m);
    valid = ~isnan(m);
    fill(ax, [x(valid) fliplr(x(valid))], [m(valid)+s(valid) fliplr(m(valid)-s(valid))], ...
        colors(iMethod, :), 'FaceAlpha', 0.25, 'EdgeColor', 'none');
    h(iMethod) = plot(ax, x, m, 'Color', colors(iMethod, :), 'LineWidth', 1.5);
end
for k = 1:numel(taskEnd)-1
    xline(ax, taskEnd(k), 'k--');
end
ylim(ax, [0 1]);
xlim(ax, [0 taskEnd(end)]);
xlabel(ax, 'Training samples');
ylabel(ax, 'Success rate');
legend(ax, h, names, 'Location', 'southeast', 'Box', 'off');

end
