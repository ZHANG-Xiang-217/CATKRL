function [X, label, segment] = loadSession(fileName, channels, taps)
%LOADSESSION Load one preprocessed session and build the neural patterns.
%   X: patterns x features, spike counts normalised by their within-session
%   maximum; features are the selected channels at each tap (rows of spike
%   are ordered channel + 32*tap).
%   segment: trial-segment index; the 5 patterns of one segment overlap in time.

d = load(fileName, 'spike', 'label');
spike = d.spike./max(d.spike, [], 2);
spike(isnan(spike)) = 0;

row = [];
for iTap = taps
    row = [row channels+32*iTap]; %#ok<AGROW>
end
X = spike(row, :)';
label = d.label(:);
segment = ceil((1:numel(label))'/5);

end
