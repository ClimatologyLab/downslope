function [atop,abottom]=gettopbottom(lat,lon,level,f,f2,meanz);
% this function finds the approximate pressure levels that correspond with
% the topography; default is to use a 4-km global DEM, although this can be
% examined with other data
latbounds=[min(lat(:)) max(lat(:))];
lonbounds=[min(lon(:)) max(lon(:))];
nlev=length(level);

 m=matfile('globalhab.mat');
 llat=m.mlat(:,1);
 if lonbounds(1)<0 lonbounds=lonbounds+360;end
 llon=m.mlon(1,:);
 fa1=find(llat>=min(latbounds) & llat<=max(latbounds));
 fa2=find(llon>=min(lonbounds) & llon<=max(lonbounds));
 
 % add a ~20-km buffer to the grid we will extract
 fa1=fa1(1)-5:fa1(length(fa1))+5;
 fa2=fa2(1)-5:fa2(length(fa2))+5;
 mlat=m.mlat(fa1,fa2);
 mlon=m.mlon(fa1,fa2);
 el=m.el(fa1,fa2);
 
% this calculates a moving window of maximum elevation for radius=0.4 degrees 
elmax=radiusinterp(mlon,mlat,el,.4,1);

% now find the topography of ERA5 or equivalent

m=matfile('era5_topo.mat');
zbot=m.z(f2,f)';

% interpolate elmax to ERA5 grid
[lon,lat]=meshgrid(lon,lat);
elmaxera=interp2(mlon,mlat,elmax,lon,lat);

% figure out what pressure levels these correspond to

for i=1:size(lon,1);
    for j=1:size(lon,2);
        atop(i,j)=interp1(squeeze(meanz(i,j,:)),[1:nlev],elmaxera(i,j),'nearest');
        abottom(i,j)=interp1(squeeze(meanz(i,j,:)),[1:nlev],zbot(i,j),'nearest');
        if elmaxera(i,j)<meanz(i,j,1) atop(i,j)=1;end
        if zbot(i,j)<meanz(i,j,1) abottom(i,j)=1;end
    end
end


atop(isnan(atop)==1)=nlev;
abottom(isnan(abottom)==1)=nlev;
abottom(find(atop<abottom))=atop(find(atop<abottom));
