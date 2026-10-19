function plotTestResults(ax, successRate, names, testNames, colors)
%PLOTTESTRESULTS Held-out success rate, mean and SD across repeats.
%   successRate: repeat x test x method.

m = reshape(mean(successRate, 1), size(successRate, 2), []);
s = reshape(std(successRate, 0, 1), size(successRate, 2), []);
b = bar(ax, m, 'grouped');
hold(ax, 'on');
for iMethod = 1:numel(names)
    b(iMethod).FaceColor = colors(iMethod, :);
    errorbar(ax, b(iMethod).XEndPoints, m(:, iMethod), s(:, iMethod), 'k', 'LineStyle', 'none');
end
yline(ax, 1/3, 'k--');
xticks(ax, 1:numel(testNames));
xticklabels(ax, testNames);
xtickangle(ax, 20);
ylabel(ax, 'Held-out success rate');
ylim(ax, [0 1]);
legend(ax, b, names, 'Location', 'northeastoutside', 'Box', 'off');

end
