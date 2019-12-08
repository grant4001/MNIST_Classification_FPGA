%==========================================================================
% Backward of  BatchNorm 
%==========================================================================
% Version: 
% Created By: Zhengyu Chen
% Modified on: 03/27/19
% *************************************************************************

function dX = batchNorm_backward(X, mu, vari, gamma, dout)

N = size(X,1);

X_mu = X - mu;
std_inv = 1 / sqrt(vari + 1e-8);

dX_norm = dout * gamma;

dvar = sum(dX_norm .* X_mu) * (-0.5) * std_inv^3;

dmu = sum(dX_norm * (-std_inv)) + dvar * mean((-2) * X_mu);

dX = (dX_norm * std_inv) + (dvar * 2 * X_mu / N) + (dmu / N);


% dgamma = sum(dout .* X_norm);
% dbeta  = sum(dout);