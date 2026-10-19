function [Z1, Z2, W] = projectToJPCA(X1, X2, reduceDim)
%PROJECTTOJPCA PCA followed by jPCA on the patterns of both tasks.
%   X1, X2: patterns x features of the one-lever and two-lever tasks.
%   Each task is centred on its own mean before projection.
%   Z1, Z2: patterns x reduceDim jPCA coordinates; W: features x reduceDim.

X = [X1; X2];
Ureduce = pca(X);
U = jPCA((X-mean(X))*Ureduce(:, 1:reduceDim));
W = real(Ureduce(:, 1:reduceDim)*U);

Z1 = (X1-mean(X1))*W;
Z2 = (X2-mean(X2))*W;

end
