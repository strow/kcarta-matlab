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
  overlaps1 = [1105 : 1705];
  overlaps2 = [2405 : 2805];
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
