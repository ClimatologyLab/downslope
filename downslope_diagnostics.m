function [stability,omega,xwind,wdirection]=downslope_diagnostics(lon,lat,level,plev,u,v,w,t,z);

% load in a topography/dem grid; here use the era5 layer
m=matfile('era5_topo.mat');
lat1=m.lat;
lon1=m.lon;
% only extra relevant grid
f2=find(lon1>=min(lon(:)) & lon1<=max(lon(:)));
f=find(lat1>=min(lat(:)) & lat1<=max(lat(:)));


% find the maximum pressure level data from height fields
meanz=max(z,[],4);

% finds approximate pressure level corresponding with 4-km topographic grid and model grid
[atop,abottom]=gettopbottom(lat,lon,level,f,f2,meanz);

% prepares header for later use
[header,header2]=prepareheader(lon,lat,level,abottom,atop);

% calculate the four variables 1) mountain top stability, 2) omega, 3)
% cross barrier wind, and 4) wind direction
[stability,omega,xwind,wdirection]=terraincontrols_monthshort_new(lon,lat,atop,abottom,header2,u,v,w,t,z,plev);
