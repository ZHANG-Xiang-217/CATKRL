function [U,pointPCA,vec] = jPCA(P)
%JPCA Summary of this function goes here
%   X is n by d matrix, n is sample,
% ref: https://scholar.harvard.edu/files/shamim/files/draft_pjpca.pdf?m=1405613874

P=P-mean(P,1);

A=P(1:end-1,:)\diff(P);
[C, ~, B] = svd(A,'econ');
Q=C*B';
[V,D]=eig((Q-Q')/2);

% [~, ~, Q] = svd(P,'econ');
% [V,D]=eig((Q-Q')/2);

% A=diff(P);
% B=P(1:end-1,:);
% m=size(A,1);
% n=size(A,2);
% p=size(B,2);
% % Define the objective function for the optimization problem
% objective_function = @(X) norm(A - B * reshape(X, [p, n]), 'fro');
% % Define the non-linear constraint function to enforce skew-symmetry
% constraint_function = @(X) skew_symmetric_constraints(X, [p, n]);
% % Set the initial guess for the optimization
% initial_guess = zeros(numel(B) * (n / m), 1);
% % Set the optimization options
% options = optimoptions('fmincon', 'Algorithm', 'interior-point', 'Display', 'off');
% % Solve the skew-symmetric least squares problem using fmincon
% [X_opt, ~, exitflag, ~] = fmincon(objective_function, initial_guess, [], [], [], [], [], [], constraint_function, options);
% X_opt = reshape(X_opt, [p, n]);
% [V,D]=eig(X_opt);

 [~,idx]=sort(diag(abs(D)),'descend');
 D=D(:,idx);V=V(:,idx);

% % Find the first conjugate pair in the vector
vec=diag(D);
% found = false;
% for iIndex = 1:length(vec)
%     for jIndex = iIndex+1:length(vec)
%         if vec(iIndex) == conj(vec(jIndex))
%             index1 = iIndex;
%             index2 = jIndex;
%             found = true;
%             break;
%         end
%     end
%     if found
%         break;
%     end
% end
% U(:,1)=(V(:,index1)+V(:,index2));
% U(:,2)=1j*(V(:,index1)-V(:,index2));

% Generate U
U=zeros(size(D));
if mod(size(D,1),2)==0
    U(:,1:2:end)=V(:,1:2:end)+V(:,2:2:end);
    U(:,2:2:end)=1j*(V(:,1:2:end)-V(:,2:2:end));
else
    U(:,1:2:end-1)=V(:,1:2:end-1)+V(:,2:2:end-1);
    U(:,2:2:end-1)=1j*(V(:,1:2:end-1)-V(:,2:2:end-1));
    U(:,end)=V(:,end);
end

pointPCA=P*U;

end

% Function to enforce skew-symmetry constraints
function [c, ceq] = skew_symmetric_constraints(X, B_size)
    X_matrix = reshape(X, B_size);
    ceq = reshape(X_matrix + X_matrix', [], 1);
    c = [];
end
