function [out]=radiusinterp(lon,lat,data,radi,type);
if ndims(data)==3
    permute(data,[3 1 2]);
end
out=zeros(size(data));
d=diff(lon(1,1:2));
step=ceil(radi/d/2);
step2=2*step;

for i=1:step:size(lon,2)
    ll=i-step2:i+step2;
    if ll(1)<=0 ll=1:i+step2;end
    if max(ll)>size(lon,2) ll=i-step2:size(lat,2);end
    for j=1:step:size(lat,1)
        lo=j-step2:j+step2;
        if lo(1)<=0 lo=1:j+step2;end
        if max(lo)>size(lat,1) lo=j-step2:size(lat,1);end
       dY = lat(lo,ll) - lat(j,1);
       dX = lon(lo,ll) - lon(1,i);
       dists = sqrt(dX.^2+dY.^2); 
       indices = find(dists<=radi);
       if ndims(data)==2
       dd=data(lo,ll);
       out1=NaN*ones(length(lo),length(ll));
       switch type
           case 1, out1(indices)=max(dd(indices));out(lo,ll)=max(out(lo,ll),out1);
           case 2, out1(indices)=prctile(dd(indices),90);out(lo,ll)=nanmean(out1(:));
       end
       else
           dd=data(:,lo,ll);
       out1=NaN*ones(size(data,1),length(lo),length(ll));
       switch type
           case 1, out1(:,indices)=repmat(max(dd(:,indices),[],2),[1 length(indices)]);
                dd=out(:,lo,ll);dd(:,:,:,4)=out1;
                out(:,lo,ll)=max(dd,[],4);
           case 2, out1(:,indices)=prctile(dd(:,indices),90,2);out(:,lo,ll)=nanmean(out1(:));
       end
       end
    end
end
if ndims(data)==3
    permute(data,[2 3 1]);
end
