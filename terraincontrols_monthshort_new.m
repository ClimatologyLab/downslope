function [topstability,downomega,crosswind,wd]=terraincontrols_month_new(lon,lat,atop,abottom,header,header2,u,v,w,t,z,level);

t=permute(t,[1 2 4 3]);
z=permute(z,[1 2 4 3]);
u=permute(u,[1 2 4 3]);
v=permute(v,[1 2 4 3]);
w=permute(w,[1 2 4 3]);


[stability]=calcstability_new(t,z,abottom,level');
stability=int8(stability*1e4);
clear el

header=permute(repmat(header,[1 1 1 size(stability,3)]),[1 2 4 3]);
header2=permute(repmat(header2,[1 1 1 size(stability,3)]),[1 2 4 3]);
nlevels=size(u,4);

for j=1:4
    dataout=int8(zeros(size(u,3),size(u,1),size(u,2)));
    switch j,
        case 1, data=u.*single(header2);aa=atop;
        case 2, data=v.*single(header2);aa=atop;
        case 3, data=stability.*int8(header2);aa=atop;
        case 4, data=w.*single(header);aa=atop;
        case 5, data=dpotdx;aa=atop;
        case 6, data=dpotdy;aa=atop;
    end
% set all data below terrain to NaN
% data=int8(data).*int8(header);
    for i=1:nlevels
      	ll=i:i+2; % wind level
      	lp=i-1:i+1; % pot temp level
      	ls=i:i+2; % stability level
      	lw=1:i+1; % omega level

       
       	ll=intersect(1:nlevels,ll);
       	lp=intersect(1:nlevels,lp);
       	ls=intersect(1:nlevels,ls);
       	lw=intersect(1:nlevels,lw);
        fy=find(aa==i);
         switch j,
             case 1, datatemp=permute(nanmean(data(:,:,:,ll),4),[3 1 2]);
             case 2, datatemp=permute(nanmean(data(:,:,:,ll),4),[3 1 2]);
             case 3, datatemp=permute(max(data(:,:,:,ls),[],4),[3 1 2]);
             case 4, datatemp=permute(max(data(:,:,:,lw),[],4),[3 1 2]);
            case 5, datatemp=permute(nanmean(data(:,:,:,lp),4),[3 1 2]);
            case 6, datatemp=permute(nanmean(data(:,:,:,lp),4),[3 1 2]);
    end
    % set information for grids at each pressure level
    dataout(:,fy)=datatemp(:,fy); 
    end
    dataout=permute(datatemp,[2 3 1]);
    switch j,
        case 1, mntwndu=dataout;
        case 2, mntwndv=dataout;
        case 3, mntstab=dataout;
        case 4, mntomega=dataout;
        case 5, mntdpdx=dataout;
        case 6, mntdpdy=dataout;
    end
end
clear u v w stability
mntwndu=single(mntwndu);
mntwndv=single(mntwndv);

% next calculate cross barrier wind speed

[xwind32]=crossbarrier_new(lon,lat,mntwndu,mntwndv,1);
crosswind=uint8(single(xwind32));clear xwind32
wd=uint8(winddir(single(mntwndu),single(mntwndv))/2);
clear mntwndu mntwndv mntdp*

topstability=int8(mntstab); % units of 10k/km
downomega=int8(mntomega);

load maskhab;maskhab=find(hab==1);
% now only save


%topstability,downomega,crosswind,wd
topstability=permute(topstability,[3 1 2]);
%topstability=topstability(:,maskhab);

downomega=permute(downomega,[3 1 2]);
%downomega=downomega(:,maskhab);

crosswind=permute(crosswind,[3 1 2]);
%crosswind=crosswind(:,maskhab);

wd=permute(wd,[3 1 2]);
%wd=wd(:,maskhab);


