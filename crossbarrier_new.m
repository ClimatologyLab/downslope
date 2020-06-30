function [crossbarrierwind]=crossbarrier(lon,lat,u,v,isabs)
% next calculate cross barrier wind speed
% this is done at two scales (or more) where we take the maximum x-barrier
% wind depending on topographic position

% here this uses a pre-calulated terrain layer
m=matfile('terraterrain.mat');
amin=min(lon(:));
amax=max(lon(:));
if amax<0 amax=amax+360;amin=amin+360;lon=lon+360;end

tmin=min(lat(:));
tmax=max(lat(:));

tlim=find(m.lat>=tmin & m.lat<=tmax);
alim=find(m.lon>=amin & m.lon<=amax);

% load in topographic aspect
wdir4=m.wdir4(tlim,alim);
wdir32=m.wdir8(tlim,alim);

% wdir4 is the aspect of topography at a 4-km grid
% wdir32 is aspect at 32-km grid

[alon,alat]=meshgrid(m.lon(1,alim),m.lat(tlim,1));
[lon,lat]=meshgrid(lon,lat);
%do it at 4km scale and 32km scale
WDIR=winddir(u,v);
ws=reshape(sqrt(u(:).^2+v(:).^2),size(u));
clear u v

if ndims(WDIR)==2
    WDIR4=int16(interp2(lon,lat,double(WDIR),alon,alat));
    ws4=(interp2(lon,lat,double(ws),alon,alat));
else
    for ll=1:size(WDIR,3)
        WDIR4(:,:,ll)=int16(interp2(lon,lat,double(WDIR(:,:,ll)),alon,alat));
        ws4(:,:,ll)=(interp2(lon,lat,double(ws(:,:,ll)),alon,alat));
    end
end

ws4=single(ws4);

difwind4=abs(single(WDIR4-wdir4))/180*pi;
difwind32=abs(single(WDIR4-wdir32))/180*pi;

crossbarrierwind32=abs(sin(difwind32)).*ws4;
crossbarrierwind4=abs(sin(difwind4)).*ws4;

% this looks for the maximum cross barrier wind using a 4x4 moving window ~60km;
% this can be adjusted for domain size
crossbarrierwind32=movmax(movmax(crossbarrierwind32,4,2),4,1);
crossbarrierwind4=movmax(movmax(crossbarrierwind4,4,2),4,1);

if ndims(WDIR)==2

crossbarrier4=interp2(alon,alat,crossbarrierwind4,lon,lat);
crossbarrier32=interp2(alon,alat,crossbarrierwind32,lon,lat);
else
    for ll=1:size(WDIR,3)
crossbarrier4(:,:,ll)=interp2(alon,alat,crossbarrierwind4(:,:,ll),lon,lat);
crossbarrier32(:,:,ll)=interp2(alon,alat,crossbarrierwind32(:,:,ll),lon,lat);
    end
end

crossbarrierwind=max(crossbarrier4,crossbarrier32);
