
function testset(glist, vlist, topts)

% function testset(glist, vlist, topts)
%
% This script calls testchunk() on a range of gasses and
% frequencies, to test a set of compressed absorption files
% against the corresponding monochromatic data.
%
% It also checks the HITRAN database and warns about missing 
% monochromatic or compressed data files
%
% if topts.testchunk = 0, testchunk() is not called, and only
% the test for missing files is done
%
% note: the cross-section gasses are not checked here; they
% are compressed as they are generated and no monochromatic 
% tabulation is saved
%

% set test defaults
if nargin < 3
  topts.testchunk = 1;     % default to call testchunk
  topts.tlist = [1 6 11];  % default temperature offset indices
  topts.plist = [1 3 5];   % default part. press. offset indices
end
if nargin < 2
  vlist = 605:25:2805;     % default is all frequency chunks
end
if nargin < 1
  glist = 1:32;            % default is all non-xsec gasses
end

% load reference profile to check gasses available
load /home/motteler/abscmp/refpro
glist = intersect(glist, refpro.glist);
clear refpro

misabs = []; % (gid,vchunk) pairs of missing mono abs data
miscmp = []; % (gid,vchunk) pairs of missing compressed data

% loop on gas IDs
for gid = glist

   % set directories, depending on gas ID
   switch gid
     case 1
       gdir = 'absdat/abs.h2o'; 
       cdir = 'absdat/kcomp.h2o'; 
     case 2
       gdir = 'absdat/abs.co2';
       cdir = 'absdat/kcomp.co2';
     otherwise
       gdir = 'absdat/abs.etc';
       cdir = 'absdat/kcomp';
     end

  % loop on chunk start freq's
  for vchunk = vlist

    % get monochromatic and compressed filenames
    if gid == 1
      fmon = sprintf('%s/g%dv%dp3.mat', gdir, gid, vchunk);
    else
      fmon = sprintf('%s/g%dv%d.mat', gdir, gid, vchunk);        
    end
    fcmp = sprintf('%s/cg%dv%d.mat', cdir, gid, vchunk);

    % check HITRAN database for any lines in this interval
    v1 = vchunk;
    v2 = vchunk + 25 - .0025;
    s = read_hitran(v1, v2, 0, gid, '/asl/data/hitran/h98.by.gas');

    if length(s.igas) > 0 
      if exist(fmon) ~= 2
        fprintf(1, 'WARNING: no absorption data for gid %d at %d 1/cm\n', ...
                gid, v1);
	misabs = [misabs; [gid, v1]];
      elseif exist(fcmp) ~=2
        fprintf(1, 'WARNING: no compressed data for gid %d at %d 1/cm\n', ...
                gid, v1);
	miscmp = [miscmp; [gid, v1]];
      else

        % call testchunk to check the quality of this chunk
	if topts.testchunk
          testchunk(gid, gdir, cdir, vchunk, topts);
	end
      end
    end

    % the following condition should never occur!
    if exist(fmon) == 2  & exist(fcmp) == 2 & length(s.igas) == 0 & gid < 51
      fprintf(1, 'WARNING: no HITRAN lines for gid %d at %d 1/cm\n', gid, v1);
    end

  end % vchunk loop
end % gid loop

save -ascii misabs misabs 
save -ascii miscmp miscmp

