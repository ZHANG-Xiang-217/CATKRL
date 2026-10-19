function isTest = splitBySegment(label, segment, testFraction)
%SPLITBYSEGMENT Hold out whole trial segments, stratified by action.
%   Patterns of one segment share time bins, so they are kept on the same
%   side of the split.

isTest = false(size(label));
segmentId = unique(segment);
segmentLabel = arrayfun(@(s) label(find(segment == s, 1)), segmentId);
for iAction = unique(segmentLabel)'
    candidate = segmentId(segmentLabel == iAction);
    candidate = candidate(randperm(numel(candidate)));
    held = candidate(1:round(testFraction*numel(candidate)));
    isTest(ismember(segment, held)) = true;
end

end
