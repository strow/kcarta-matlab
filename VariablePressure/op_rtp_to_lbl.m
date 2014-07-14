function kcprofile = op_rtp_to_lbl(profnum, gasid, head, prof, refpro);

% copied from /asl/matlab/rtptools/op_rtp_to_txt_lbl.m and modified
% so that things directly become a structure, rather than writing to a
% text file. This can then be used by matlab version of kcarta

% function op_rtp_to_txt_lbl(filename, profnum, gasid, head, prof);
%
% Take a KLAYERS "op" type output file in RTP format and pull out
% out the data for the specified profile and gas ID and write it
% to a text file in the format used by UMBC-LBL (run7).
%
% Input:
%    filename : (string) name of text file to create
%    profnum  : (1 x 1) index of desired profile in "prof"
%    gasid    : (1 x 1) gas ID
%    head     : (RTP head structure)
%    prof     : (RTP prof structure)
%
% Output: kcprofile with
%  profile.glist
%  profile.mtemp
%  profile.mpres
%  profile.gpart
%  profile.gamnt

% WARNING : if gasID == 30.34.35.37.41 then gasAmt is set to 0 (as these
%           gases would be double counted as xsec gases)

% Created 23 April 2002, Scott Hannon - based on "op_rtp_to_txt.m" for KCARTA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check ptype
if (~isfield(head,'ptype'))
   error('head field ptype not found')
else
   if (head.ptype < 1)
      error('head field ptype must be a "layers" profile (ptype=1 or 2)')
   end
end

kAvog = 6.023e26;

gasid0 = gasid;

if gasid == 103
  gasid = 1;
  end

% Check glist
if (~isfield(head,'glist'))
  error('head field glist not found')
else
  igas=find( head.glist == gasid );
  if (length(igas) ~= 1 & gasid0 ~= 103)
    iUse = find(refpro.glist == gasid);
    if length(iUse) ~= 1
      error('huhuhuhuh?? wierd profile stuff, dude!')
      end
    fprintf(1,' warning : using ref profile gas amt for gid %3i\n',gasid)
    kcprofile.glist = gasid;
    nlays = prof.nlevs(profnum)-1;

    % Determine layer thinckness
    zlo=prof.palts(1:nlays,  profnum);
    zhi=prof.palts(2:nlays+1,profnum);
    zmean=(zlo + zhi)/2000; % mean altitude in km
    dz=abs(zhi - zlo);

    temp = prof.ptemp(1:nlays,profnum);
    pres = prof.plays(1:nlays,profnum)/1013.25;

    % Calc partial pressure (in atm)
    amount = interp1(log10(refpro.mpres*1013.25),refpro.gamnt(:,iUse),...
                      log10(prof.plays(1:nlays,profnum)));
    amount = amount * 6.02214199E+26;
    pp = amount .* temp ./ ( 2.6867775E+19 * 273.15 * 100*dz );
    % Convert amount from molecules/cm^2 to kilomoles/cm^2
    amount=amount/6.02214199E+26;

  elseif (length(igas) ~= 1 & gasid0 == 103)
    amount = prof.gas_1;
    temp   = prof.ptemp;
    end

  if length(igas) ~= 1
    kcprofile.mtemp = temp;
    kcprofile.mpres = pres;
    kcprofile.gpart = pp;
    kcprofile.gamnt = amount;
    end

  if length(intersect(gasid,[30 34 35 37 41])) == 1
    fprintf(1,' warning : set gas %3i amt to 0; included in xsec! \n',gasid)
    amount = zeros(size(amount));
    kcprofile.gamnt = amount;
    end
  disp('lkjk  ufekhje  kjhfkjh fhfa')
  return
  end

disp('kjslkjsg')

% Check gunit
if (~isfield(head,'gunit'))
   error('head field gunit not found')
else
   ii=head.gunit( igas );
   if (ii ~= 1)
      error('head field gunit must have code=1 (molecules/cm^2)')
   end
end

% Check nlevs
if (~isfield(prof,'nlevs'))
   error('prof field nlevs not found')
end
nlevs=prof.nlevs(profnum);
nlays=nlevs - 1;

gasstr=['gas_' int2str(gasid)];
if (isfield(prof,gasstr))

   % Get layer gas amount and temperature
   eval(['amount=prof.' gasstr '(1:nlays,profnum);']);
   temp=prof.ptemp(1:nlays,profnum);

   % Determine layer thinckness
   zlo=prof.palts(1:nlays,profnum);
   zhi=prof.palts(2:nlevs,profnum);
   zmean=(zlo + zhi)/2000; % mean altitude in km
   dz=abs(zhi - zlo);

   % Calc partial pressure (in atm)
   pp = amount .* temp ./ ( 2.6867775E+19 * 273.15 * 100*dz );
   % Convert amount from molecules/cm^2 to kilomoles/cm^2
   amount=amount/6.02214199E+26;

%   %%%%%%%%%%%% this has been replaced
%   %%%% Open output file
%   fid=fopen(filename,'w');
%   % Write output
%   for il=1:nlays
%      fprintf(fid, '% 4d % 11.4e % 11.4e % 8.3f % 11.4e\n', ...
%         il, prof.plays(il,profnum)/1013.25, pp(il), temp(il), amount(il) );
%      end
%   % close output file
%   ii=fclose(fid);
   kcprofile.glist = gasid;
   for il=1:nlays
     mmtemp(il) = temp(il);
     mmpres(il) = prof.plays(il,profnum)/1013.25;
     mgpart(il) = pp(il);
     mgamnt(il) = amount(il);
     end

   kcprofile.mtemp = mmtemp';
   kcprofile.mpres = mmpres';
   kcprofile.gpart = mgpart';
   kcprofile.gamnt = mgamnt';

   if length(intersect(gasid,[30 34 35 37 41])) == 1
     fprintf(1,' warning : set gas %3i amt to 0; included in xsec! \n',gasid)
     mgamnt = zeros(size(mgamnt));
     kcprofile.gamnt = mgamnt';
     end

else
   error(['prof does not contain field ' gasstr])
end

%%% end of function %%%
