%==========================================================================
% Feed forward of  BatchNorm 
%==========================================================================
% Version: 
% Created By: Zhengyu Chen
% Modified on: 03/27/19
% *************************************************************************

function [out, mu, vari, X_norm] = batchNorm_forward(X, gamma, beta)
mu      = mean(reshape(X, 1, []));
vari     = var(reshape(X, 1, []));
X_norm  = (X - mu) ./ sqrt(vari + 1e-8);
out     = gamma * X_norm + beta;
