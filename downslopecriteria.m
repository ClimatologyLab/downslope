function [downslope]=downslopecriteria(stableair,xwind,omega,wnd,gridres);

% gridres is the horizontal resolution of the grid in km

%parameters 
celllength=25;

% thresholds you can set
dirlength=60;
omegac=6;
stablec=65;
xwindc=13;


for i=1:360
gridd2(:,:,i)=advectit(celllength,i-1,dirlength,gridres);
end


om=omega>=omegac;
st=stableair>=stablec;
xx=xwind>=xwindc;
clear omega stableair xwind

parfor j=1:size(wnd,3)
st2(:,:,j)=projectgrid(gridd2,wnd(:,:,j),st(:,:,j));
xx2(:,:,j)=projectgrid(gridd2,wnd(:,:,j),xx(:,:,j));
end

downslope=st2&xx2&om;clear om st xx st2 xx2

end



function [gridout]=projectgrid(gridd2,wd,varr);
s=size(wd);
buffer=size(gridd2,1)-1;
buffer2=buffer/2;

gridout=logical(zeros(size(wd,1)+buffer,size(wd,2)+buffer));
wd=single(wd);wd(varr==0)=NaN;
gridd2=gridd2(:,:,2:2:360);
for j=1:180
f=find(wd==j);
jj=ceil(f/s(1));
ii=mod(f,s(1));ii(ii==0)=s(1);
for i=1:length(f)
 gridout(ii(i):ii(i)+buffer,jj(i):jj(i)+buffer)=gridout(ii(i):ii(i)+buffer,jj(i):jj(i)+buffer)|gridd2(:,:,j);
end
end

gridout(:,1:buffer2)=gridout(:,1:buffer2)+gridout(:,size(wd,2)+1:size(wd,2)+buffer2);
gridout=gridout(buffer2+1:size(gridout,1)-buffer2,buffer2+1:size(gridout,2)-buffer2);
end

function [gridd]=advectit(lengthres,winddir,dirlength,gridres);
celllength=ceil(lengthres/gridres);
ncell=ceil(dirlength/gridres)*2+1;
gridd=logical(zeros(ncell,ncell));
dX=-(ncell-1)/2:1:(ncell-1)/2;
dY=-(ncell-1)/2:1:(ncell-1)/2;
[dX,dY]=meshgrid(dX,dY);
for i=1:round(dirlength/celllength);
upoints=-i*sin(winddir*pi/180);
vpoints=-i*cos(winddir*pi/180);
dists = reshape(sqrt((dX-upoints).^2+(dY-vpoints).^2),size(dX));
gridd=gridd | dists<1.5;
end

end
