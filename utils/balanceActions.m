function idx = balanceActions(label)
%BALANCEACTIONS Undersample the two-lever data as in the paper: the two press
%   actions get the same count, and Rest matches their combined count.

idxA = find(label == 1);
idxB = find(label == 2);
idxC = find(label == 3);
nPress = min(numel(idxB), numel(idxC));
idxB = datasample(idxB, nPress, 'Replace', false);
idxC = datasample(idxC, nPress, 'Replace', false);
idxA = datasample(idxA, min(numel(idxA), 2*nPress), 'Replace', false);
idx = sort([idxA; idxB; idxC]);

end
