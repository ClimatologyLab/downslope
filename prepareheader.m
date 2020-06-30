function [header,header2]=prepareheader(lon,lat,levels,abottom,atop);
header=logical(ones(size(lat,1),size(lon,2),length(levels))); % this sets anything below era terrain to missing
header2=logical(ones(size(lat,1),size(lon,2),length(levels)));
for i=1:size(header,1);
for j=1:size(header,2);
o=abottom(i,j);
if o>1
header(i,j,1:o)=0;
end
o=atop(i,j);
if o>2
header2(i,j,1:o-1)=0;
end;
end;end