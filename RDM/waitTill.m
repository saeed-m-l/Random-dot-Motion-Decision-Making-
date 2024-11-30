function waitTill(t0, t1, t2)

% 2 = from exponential, with min = t0, max = t2 & mean = t1

% t0 = min
% t1 = mean
% t2 = max
    
interval = t2 + 1;

while interval > t2
    interval = exprnd(t1) + t0;
end

WaitSecs(interval);
    
end
