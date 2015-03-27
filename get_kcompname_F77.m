function    cgxfile = get_kcompname_F77(ropt0,vchunk,gid,prefix);
%
% this gets the kCOMP name for the f77 files
% note : uses two hardcoded numbers
%
kpathh2o = ropt0.kpathh2o;
kpathhDo = ropt0.kpathhDo;
kpathco2 = ropt0.kpathco2;
kpathetc = ropt0.kpathetc;

% get file name of compressed data for this gas and chunk
if (gid >= 3 & gid < 100)
  cgxfile = sprintf('%s%s%d_g%d.dat', kpathetc, prefix, vchunk, gid);
elseif gid == 2
  cgxfile = sprintf('%s%s%d_g2.dat', kpathco2, prefix, vchunk);
elseif (gid == 1)
  if length(strfind(kpathh2o,'H2008')) == 1
    %% H2008
    overlaps1 = [1105 : 1705];
    overlaps2 = [2405 : 2805];
  elseif length(strfind(kpathh2o,'H2012')) == 1
    %% H2012
    overlaps1 = [0605 : 1955];
    overlaps2 = [2405 : 3355];
  else
     %% have not broken out the database
    overlaps1 = [];  
  end

  overlaps = [overlaps1 overlaps2];
  if length(intersect(overlaps,vchunk)) == 1
    %% HDO chunks and H20 chunks
    cgxfile = sprintf('%s%s%d_g1.dat', kpathhDo, prefix, vchunk);
  else
    %% H2o only (ie no HDO isotopes here!!!
    cgxfile = sprintf('%s%s%d_g1.dat', kpathh2o, prefix, vchunk);
  end
elseif (gid == 103)
  %% only exist for certain bands so don't worry
  cgxfile = sprintf('%s%s%d_g103.dat', kpathhDo, prefix, vchunk);
end

%if gid == 1 | gid == 103
%  fprintf(1,'freq = %4i gid = %3i cgxfile = %s does it exist = %2i \n',vchunk,gid,cgxfile,exist(cgxfile))
%end