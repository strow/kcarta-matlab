
glist = [1:28, 51:63];
vlist = 605 : 2805;
dtype = 'ieee-be';

% loop on gas IDs
for gid = glist

  if gid == 1
    cdir = '/home/motteler/absdat/kcomp.h2o';
    fdir = '/home/motteler/absdat/fbin/h2o.ieee-be';
  elseif 1 < gid  & gid <= 50
    cdir = '/home/motteler/absdat/kcomp';
    fdir = '/home/motteler/absdat/fbin/etc.ieee-be';
  else
    cdir = '/home/motteler/absdat/kcomp.xsec';
    fdir = '/home/motteler/absdat/fbin/etc.ieee-be';
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

