
% simple views from concatenated water chunks

pind = 3;
gdir = '.';
gid = 1;
lay = 50
tem = 6;

fr2 = [];
k2 = [];

for vchunk = 805:25:1730

  eval(sprintf('load %s/g%dv%dp%d.mat', gdir, gid, vchunk, pind));

  fr2 = [fr2; fr(:)];

  k2 =  [k2; k(:,lay,tem)];

  fprintf(1,'.');
end
fprintf(1, '\cr')

