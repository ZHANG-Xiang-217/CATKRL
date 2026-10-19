function y = gaussianKernel( point, center, kernelWidth )
%GAUSSIANKERNEL Summary of this function goes here
%   Detailed explanation goes here
%   point: dim x 1
%   center: dim x Npts
%   y: 1 x Npts

y=exp(-sum((point-center).^2,1)/(2*kernelWidth^2));

end

