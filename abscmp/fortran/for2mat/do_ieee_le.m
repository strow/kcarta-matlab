
glist = [1:28, 51:63];
vlist = 605 : 2805;
dtype = 'ieee-le';

% loop on gas IDs
for gid = glist

  if gid == 1
    cdir = '/onion/s2/motteler/kcomp.h2o';
    fdir = '/onion/s2/motteler/fbin/h2o.ieee-le';
  elseif 1 < gid  & gid <= 50
    cdir = '/onion/s2/motteler/kcomp.etc';
    fdir = '/onion/s2/motteler/fbin/etc.ieee-le';
  else
    cdir = '/onion/s2/motteler/kcomp.xsec';
    fdir = '/onion/s2/motteler/fbin/etc.ieee-le';
  end

  fprintf(1, 'gas %d...\n', gid);

  % loop on chunk start freq's
  for vchunk = vlist

    fcmp = sprintf('%s/cg%dv%d.mat', cdir, gid, vchunk);
    if exist(fcmp) == 2  

      % write fortran data when compressed data exists
      mat2for(gid, vchunk, cdir, fdir, dtype);

    end
  end % vchunk loop
end % gid loop

