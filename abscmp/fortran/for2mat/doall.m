
glist = [1:28, 51:63];
vlist = 605 : 2805;
dtype = 'ieee-le';

% loop on gas IDs
for gid = glist

  if gid == 1
    cdir = '/onion/s2/motteler/kcomp.h2o';
    fdir = '/asl/data/kcarta/v20.ieee-le/h2o.ieee-le';
  elseif 1 < gid  & gid <= 50
    cdir = '/onion/s2/motteler/kcomp.etc';
    fdir = '/asl/data/kcarta/v20.ieee-le/etc.ieee-le';
  else
    cdir = '/onion/s2/motteler/kcomp.xsec';
    fdir = '/asl/data/kcarta/v20.ieee-le/etc.ieee-le';
  end

  fprintf(1, 'gas %d...\n', gid);

  % loop on chunk start freq's
  for vchunk = vlist

    fname = sprintf('%s/r%d_g%d.dat', fdir, vchunk, gid);
    if exist(fname) == 2  

      % write matlab data when compressed data exists
      for2mat(gid, vchunk, cdir, fdir, dtype);

    end
  end % vchunk loop
end % gid loop

