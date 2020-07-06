function [mlon,mlat,delx,dely,el,downslopehab,elmax,elmin]=terrainhabitat(latbounds,lonbounds);
m=matfile('terraterrain');
mlat=m.lat;mlon=m.lon;
f=find(mlat>=min(latbounds) & mlat<=max(latbounds));
f2=find(mlon>=min(lonbounds) & mlon<=max(lonbounds));
mlat=mlat(f);mlon=mlon(f2);
el=m.el(f,f2);

% two requirements
% (1) elevational difference of at least 300m drop within a 50-km distance
% OR
% (2) elevational gradient of at least 10m per kilometer between mountain
% top and valley floor

option=1;

% loop across all possible points, find all points within a given radius,
% require high point to be at least deltad higher
radius=60;
deltad=200;

[mlon,mlat]=meshgrid(mlon,mlat);


% find peaks
el2=islocalmax(el,'MinSeparation',20);
el22=islocalmax(el,2,'MinSeparation',20);
el2=el2.*el22;
f=find(el2==1);
ef=el(f);
ff=find(ef>200);
f=f(ff);
lonpeak=mlon(f);
latpeak=mlat(f);
cd ../
parfor i=1:length(f);
 r(i).data=find(lldist(latpeak(i), lonpeak(i),mlat(:), mlon(:),1)<radius);
end
maxel=el;
for i=1:length(f);
    maxel(r(i).data)=max(maxel(r(i).data),el(f(i)));
end
can=maxel-el>deltad;

% need to also be sure it is on a slope
[delx4,dely4]=gradient(el);
dely4=-dely4;

% aggregate up to 8-km
el2=movmean(movmean(el,2)',2)';
[delx8,dely8]=gradient(el2);
dely8=-dely8;

% aggregate up to 16-km
el2=movmean(movmean(el,4)',4)';
[delx16,dely16]=gradient(el2);
dely16=-dely16;

% aggregate up to 32-km
el2=movmean(movmean(el,8)',8)';
[delx32,dely32]=gradient(el2);
dely32=-dely32;

del4=reshape(sqrt(delx4(:).^2+dely4(:).^2),size(dely4));
del8=reshape(sqrt(delx8(:).^2+dely8(:).^2),size(dely4));
del16=reshape(sqrt(delx16(:).^2+dely16(:).^2),size(dely4));
del32=reshape(sqrt(delx32(:).^2+dely32(:).^2),size(dely4));


% maxslope for all spatial scales
maxdel=max(max(max(del16,del32),del8),del4);
downslopehab=can&maxdel>40;

% spread this out to 30-km, technically this is 
habsmooth=radiusinterp(mlon,mlat,downslopehab,20/111,1);

delx=delx32;dely=dely32;
