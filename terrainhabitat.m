function [mlon,mlat,delx,dely,el,downslopehab,elmax,elmin]=terrainhabitat(latbounds,lonbounds);

% loads in a dataset of terrain/DEM with lat/lon elevation
m=matfile('terraterrain.mat');
mlat=m.lat;
mlon=m.lon;
f=find(mlat>=min(latbounds) & mlat<=max(latbounds));
f2=find(mlon>=min(lonbounds) & mlon<=max(lonbounds));
mlat=mlat(f);mlon=mlon(f2);
el=m.el(f,f2);

% this is the horizontal resolution in km of your DEM data
hres=4;

% specific the output resolution
ores=

% two requirements
% (1) elevational difference of at least X-m drop within a 60-km distance
radius=60; % how many kilometers radius should be
deltad=200; % elevational between highest mountain and local elevation
% AND
% (2) elevational gradient of at least Y-m per kilometer locally
slopethresh=20; %elevational change per 1000-m


[mlon,mlat]=meshgrid(mlon,mlat);

% find peaks first by latitude then longitude
% loop over points to see if the distance between local prominences 
for i=1:length(mlon);
 r=lldist(mlat(i),mlon(i),mlat(:),mlon(:),1);;
 r=find(r<=radius);
 can(i)=el(r)-el(i)>=deltad;
end


% need to also be sure it is on a slope
[delx4,dely4]=gradient(el);

delx4=delx4/hres;
dely4=dely4/hres;

del4=reshape(sqrt(delx4(:).^2+dely4(:).^2),size(dely4));
slopecheck=del4>=slopethresh;


% maxslope for all spatial scales
downslopehab=can&slopecheck;

function  dist = lldist(lag1,lon1,lag2,lon2,method)
% calculate distance between two points on earth's surface
% given by their latitude-longitude pair.
% Input lag1,lon1,lag2,lon2 are in degrees, without 'NSWE' indicators.
% Input method is 1 or 2. Default is 1.
% Method 1 uses plane approximation,
% only for points within several tens of kilometers (angles in rads):
% d =
% sqrt(R_equator^2*(lag1-lag2)^2 + R_polar^2*(lon1-lon2)^2*cos((lag1+lag2)/2)^2)
% Method 2 calculates sphereic geodesic distance for points farther apart,
% but ignores flattening of the earth:
% d =
% R_aver * acos(cos(lag1)cos(lag2)cos(lon1-lon2)+sin(lag1)sin(lag2))
% Output dist is in km.
% Returns -99999 if input argument(s) is/are incorrect.
% Flora Sun, University of Toronto, Jun 12, 2004.
if nargin < 4
    dist = -99999;
    disp('Number of input arguments error! distance = -99999');
    return;
end
if abs(lag1)>90 | abs(lag2)>90 | abs(lon1)>360 | abs(lon2)>360
    dist = -99999;
    disp('Degree(s) illegal! distance = -99999');
    return;
end
if lon1 < 0
    lon1 = lon1 + 360;
end
if lon2 < 0
    lon2 = lon2 + 360;
end
% Default method is 1.
if nargin == 4
    method == 1;
end
if method == 1
    km_per_deg_la = 111.3237;
    km_per_deg_lo = 111.1350;
    km_la = km_per_deg_la .* (lag1-lag2);
    % Always calculate the shorter arc.
    if abs(lon1-lon2) > 180
        dif_lo = abs(lon1-lon2)-180;
    else
        dif_lo = abs(lon1-lon2);
    end
    km_lo = km_per_deg_lo .* dif_lo .* cos((lag1+lag2)*pi/360);
    dist = reshape(sqrt(km_la(:).^2 + km_lo(:).^2),size(km_lo));
else
    R_aver = 6374;
    deg2rad = pi/180;
    lag1 = lag1 * deg2rad;
    lon1 = lon1 * deg2rad;
    lag2 = lag2 * deg2rad;
    lon2 = lon2 * deg2rad;
    dist = R_aver .* acos(cos(lag1).*cos(lag2).*cos(lon1-lon2) + sin(lag1).*sin(lag2));
end


