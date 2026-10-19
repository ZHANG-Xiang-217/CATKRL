function plotAlignment(fig, Z1, y1, Z2, y2, Z2aligned)
%PLOTALIGNMENT Neural patterns of both tasks in jPCA space, before and after alignment.

color = [1 0.5 0; 0 0.7 0; 0 0 1];      % Rest, Press high lever, Press low lever
data = {Z1, y1, 'One-lever task'; Z2, y2, 'Two-lever task'; Z2aligned, y2, 'Two-lever task after alignment'};
for k = 1:3
    ax = subplot(1, 3, k, 'Parent', fig);
    hold(ax, 'on');
    for iAction = unique(data{k, 2})'
        idx = data{k, 2} == iAction;
        scatter3(ax, data{k, 1}(idx, 1), data{k, 1}(idx, 2), data{k, 1}(idx, 3), 4, ...
            color(iAction, :), 'filled');
    end
    title(ax, data{k, 3});
    xlabel(ax, 'jPC1'); ylabel(ax, 'jPC2'); zlabel(ax, 'jPC3');
    view(ax, [30 40]); grid(ax, 'on');
end
legend(ax, {'Rest', 'Press high lever', 'Press low lever'}, 'Location', 'northeast', 'Box', 'off');

end
