function out = runTransfer(Z1, y1, Z2, y2, Z2aligned, split, opt)
%RUNTRANSFER Train AGREL, clustering KRL and CATKRL on one-lever -> two-lever
%   -> one-lever and test them on held-out patterns.
%   Z1, Z2: patterns x dim of task 1 and task 2; Z2aligned: task 2 after alignment.
%   split: indices train1, test1, train2, test2.
%   out.successRate: test x method; out.predict{method}: 1 x T decoded actions.

names = {'AGREL', 'Clustering KRL', 'CATKRL'};
% Stored decoder (index into recordIdx) and task for each test
testRecord = [1 2 3 3 4];
testTask = [1 2 2 1 1];

% Training sequence
[order, taskEnd] = buildSchedule(numel(split.train1), numel(split.train2), opt.epochNum);
isTwo = order(1, :) == 2;
sample = zeros(1, size(order, 2));
sample(~isTwo) = split.train1(order(2, ~isTwo));
sample(isTwo) = split.train2(order(2, isTwo));
input = zeros(size(Z1, 2), size(order, 2));
input(:, ~isTwo) = Z1(sample(~isTwo), :)';
input(:, isTwo) = Z2(sample(isTwo), :)';
inputAligned = input;
inputAligned(:, isTwo) = Z2aligned(sample(isTwo), :)';
output = zeros(1, size(order, 2));
output(~isTwo) = y1(sample(~isTwo));
output(isTwo) = y2(sample(isTwo));
recordIdx = [taskEnd(1) taskEnd(1)+opt.checkpoint taskEnd(2) taskEnd(2)+opt.checkpoint];

[predictAGREL, weightIH, weightHO] = AGREL(input, output, ...
    opt.learningRateAGREL, opt.hiddenUnitNum, recordIdx);
[predictKRL, stateKRL] = trainClusteringKRL(input, output, opt, recordIdx);
[predictCAT, stateCAT] = trainClusteringKRL(inputAligned, output, opt, recordIdx);

successRate = nan(numel(testRecord), numel(names));
for iTest = 1:numel(testRecord)
    k = testRecord(iTest);
    if testTask(iTest) == 1
        in = Z1(split.test1, :)'; inAligned = in; target = y1(split.test1)';
    else
        in = Z2(split.test2, :)'; inAligned = Z2aligned(split.test2, :)'; target = y2(split.test2)';
    end
    successRate(iTest, 1) = mean(AGREL_testing(in, weightIH{k}, weightHO{k}) == target);
    successRate(iTest, 2) = testClusteringKRL(stateKRL{k}, in, target, opt);
    successRate(iTest, 3) = testClusteringKRL(stateCAT{k}, inAligned, target, opt);
end

out.names = names;
out.testNames = {'One-lever, end of training', 'Two-lever, initial transfer', ...
    'Two-lever, end of training', 'One-lever, memory after two-lever', ...
    'One-lever, after retraining'};
out.successRate = successRate;
out.predict = {predictAGREL, predictKRL, predictCAT};
out.output = output;
out.taskEnd = taskEnd;

end
