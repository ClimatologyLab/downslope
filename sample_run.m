% read in some example data, here Nov 2018 data for western US from ERA5
load exampledata.mat

t=permute(t,[2 1 3 4]);
u=permute(u,[2 1 3 4]);
v=permute(v,[2 1 3 4]);
w=permute(w,[2 1 3 4]);
z=permute(z,[2 1 3 4]);
% these are pressure level data from 1000-500hPa by 50hPa 
plev=1000:-50:500;

% multiply w by 10 since diagnostics are saved as integers
w=w*10;

[stab,om,xwind,wdirr]=downslope_diagnostics(lon,lat,1:11,1000:-50:500,u,v,w,t,z);

% now this goes through and looks for union of criteria to assign
% logistically whether grids qualify as downslope or now, these criteria
% are easily adjusted within the function

downslope=downslopecriteria(permute(stab,[2 3 1]),permute(xwind,[2 3 1]),permute(om,[2 3 1]),permute(wdirr,[2 3 1]),25);

