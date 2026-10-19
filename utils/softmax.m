function y = softmax(x)
    % Softmax function without Deep Learning Toolbox
    % x: vector of values
    % y: softmax probabilities (sums to 1)

    x = x(:);  % ensure column vector
    ex = exp(x - max(x));  % subtract max for numerical stability
    y = ex / sum(ex);
end
