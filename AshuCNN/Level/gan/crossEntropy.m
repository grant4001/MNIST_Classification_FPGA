function out = crossEntropy(x, y, type) 
eps = 1e-12;

out = -(y.*log(x + eps) + (1-y).*log(1-x + eps));% x: output from CNN/TCNN, y: target
switch type 
    case 'mean'
        out = mean(out);
    case 'none'

    otherwise
        error 'not implemented yet'
end
