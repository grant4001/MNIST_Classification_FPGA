function er=checkvalues( x, z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idx = find(x==Inf);
if(length(idx) > 0)
    z(idx)
    error('Inf');
end
idx=find(isnan(x));
if(length(idx) > 0)
    z(idx)
    error('NaN');
end