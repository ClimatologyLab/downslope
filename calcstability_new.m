function [stability,dpotdx,dpotdy,pottemp]=calcstability_new(t,z,abottom,level);


plev=repmat(level,[1 size(z,3) size(z,1) size(z,2)]);
plev=1000./permute(single(plev),[3 4 2 1]);
plev=reshape(single(plev).^.287,size(plev));
pottemp=single(t).*plev;clear t plev
pottemp=double(pottemp);
[dpotdx,dpotdy,a,stability]=gradient(pottemp);
clear a
[a,a,a,stabilityz]=gradient(z);
dpotdy=-dpotdy;
stability=squeeze(stability./stabilityz);
stability=permute(stability,[4 3 1 2]);
dpotdx=permute(dpotdx,[4 3 1 2]);
dpotdy=permute(dpotdy,[4 3 1 2]);


for j=1:11
    f=find(abottom==j);
    stability(1:j,:,f)=NaN;
    dpotdx(1:j,:,f)=NaN;    
    dpotdy(1:j,:,f)=NaN;
end

stability=permute(stability,[3 4 2 1]);
dpotdx=permute(dpotdx,[3 4 2 1]);
dpotdy=permute(dpotdy,[3 4 2 1]);