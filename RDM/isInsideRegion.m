
function inside = isInsideRegion(pos, center, radius)
   
        n = size(pos,1);
        d = ((pos-repmat(center,n,2))./repmat(radius,n,2));
        inside = sqrt(sum(d.^2,2))<=1;

end





