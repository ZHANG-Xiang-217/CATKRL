function [order, taskEnd] = buildSchedule(nOneLever, nTwoLever, epochNum)
%BUILDSCHEDULE Training order one-lever -> two-lever -> one-lever.
%   order: 2 x T, row 1 is the task (1 or 2), row 2 the training-sample index
%   within that task. Samples are repeated epochNum times and shuffled within
%   each block. taskEnd: last time step of each block.

block = {repmat(1:nOneLever, 1, epochNum), repmat(1:nTwoLever, 1, epochNum), ...
    repmat(1:nOneLever, 1, epochNum)};
task = [1 2 1];
order = [];
for k = 1:3
    idx = block{k}(randperm(numel(block{k})));
    order = [order [task(k)*ones(1, numel(idx)); idx]]; %#ok<AGROW>
end
taskEnd = cumsum(cellfun(@numel, block));

end
