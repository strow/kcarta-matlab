
function cmprun(glist, vlist)

% function cmprun(glist, vlist)
%
% compression script
%
% existing data is not molested, so if you want to
% update data, the old stuff should be deleted first

if nargin < 2
  vlist = 605:25:2805; % default to all frequency chunks
end
if nargin < 1
  glist = 1:32;	       % default to all non-xsec gasses
end

abseps = 1e-8;

% load reference profile to check gasses available
load /home/motteler/abscmp/refpro
glist = intersect(glist, refpro.glist);
clear refpro

% loop on gas IDs
for gid = glist

   % set directories, depending on gas ID
   switch gid
     case 1
       gdir = 'absdat/abs.h2o'; 
       cdir = 'absdat/kcomp.h2o'; 
     case 2
       gdir = 'absdat/abs.co2';
       cdir = 'absdat/kcomp';
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

    if exist(fmon) == 2  % monochromatic data exists

      if exist(fcmp) == 2  % compressed data exists

        % we found compressed data, so just print a message
        fprintf(1, 'cmprun: %s already exists\n', fcmp);
      else

        % check for old data with max below abseps
        eval(['load ',fmon]);
        if max(max(max(k))) <= abseps
	  fprintf(1, 'cmprun: WARNING gas %d chunk %d max k <= abseps\n', ...
		  gid, vchunk);
	end
	clear k
		  
        % we have monochromatic absorption data to work on and
	% there's no current compressed data, so do the compression
        B = absbasis(gid, gdir, vchunk);
        absbcmp(gid, gdir, cdir, vchunk, B);
      end

    end
  end % vchunk loop
end % gid loop

