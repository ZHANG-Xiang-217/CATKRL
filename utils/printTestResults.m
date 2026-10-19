function printTestResults(successRate, names, testNames)
%PRINTTESTRESULTS Print the held-out success rate, mean (SD) across repeats.
%   successRate: repeat x test x method.

fprintf('\nHeld-out success rate, mean (SD) over %d repeats\n', size(successRate, 1));
fprintf('%-36s', '');
fprintf('%18s', names{:});
fprintf('\n');
for iTest = 1:numel(testNames)
    fprintf('%-36s', testNames{iTest});
    for iMethod = 1:numel(names)
        fprintf('%11.3f (%.3f)', mean(successRate(:, iTest, iMethod)), std(successRate(:, iTest, iMethod)));
    end
    fprintf('\n');
end

end
