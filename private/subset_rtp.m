function [head, prof]=subset_rtp(headin, profin, glist, clist, plist);

% function [head, prof]=subset_rtp(headin, profin, glist, clist, plist);
%
% Subsets an RTP head & prof structure.
%
% Input:
%    headin = RTP "head" structure
%    profin = RTP "prof" structure
%    glist = (1 x ngas) list of gas IDs to be retained
%    clist = (1 x nchan) list of channel IDs to be retained
%    plist = (1 x nprof) list of profile indices to be retained
%
% Note: if g/c/plist=[], all elements are retained
% 
% Output:
%    head = subsetted "head" structure
%    prof = subsetted "prof" structure
%
% Warning: does not subset non-standard RTP variables! (not even gamnt)
% Note: assumes all profin fields are dimensioned [<whatever> x nprof]
%

% Created: 13 September 2001, Scott Hannon
% Last update: 1 February 2002, Scott Hannon - add new rtpV103 vars
% Update: 25 June 2002, Scott Hannon - add new rtpV105 vars
% Fix: 22 Oct 2002 Scott Hannon - "calflg" corrected to calflag.
% Update: 15 July 2005, Scott Hannon - re-write checks to make it work
%    with pullchans RTP files. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%
% Check headin & profin
%%%%%%%%%%%%%%%%%%%%%%%

% Check for required header fields
if (~isfield(headin,'ngas'))
   disp('Error: input head lacks ngas');
   return
end
ngasin=headin.ngas;
%
if (~isfield(headin,'nchan'))
   disp('Error: input head lacks nchan');
   return
end
nchanin=headin.nchan;
%
% Note: assumes all the 2nd dimension of all profin fields is nprofin
names = fieldnames(profin);
eval( ['d = size(profin.' names{1} ');' ] )
nprofin = d(2);

% Check gas info
if (length(glist) > 0)
   if (~isfield(headin,'glist'))
      disp('Error: input head lacks glist');
      return
   end
   if (~isfield(headin,'gunit'))
      disp('Error: input head lacks gunit');
      return
   end
   %
   ngas=length(glist);
   [c,indg,ib]=intersect(headin.glist,glist);
   if (length(indg) ~= ngas)
      disp('Error: input structures do not contain all gases in glist');
      return
   end
else
   indg=1:ngasin;
   ngas=ngasin;
end

% Check channel info
if (length(clist) > 0)
   if (~isfield(headin,'ichan'))
      disp('Error: input head lacks ichan');
      return
   end
   %
   nchan=length(clist);
   [c,indc,ib]=intersect(headin.ichan,clist);
   if (length(indc) ~= nchan)
      disp('Error: input structures do not contain all channels in clist');
      return
   end
   if (~isfield(profin,'robs1'))
      if (~isfield(profin,'rcalc'))
         disp('Error: no robs1 or rcalc fields for clist to subset');
         return
      end
   end
else
   indc=1:nchanin;
   nchan=nchanin;
end

% Check profile info
if (length(plist) > 0)
   nprof = length(plist);
   % Note: glist is not necessarily sorted
   junk = max( abs( plist - round(plist) ) );
   if (junk > 0)
      disp('Error: plist contains a non-integer index')
      return
   end
   if (min(plist) < 1)
      disp('Error: plist contains a negative or zero index')
      return
   end
   if (max(plist) > nprofin)
      disp('Error: plist contains an index larger than nprofin')
      return
   end
   indp=plist;
else
   indp=1:nprofin;
   nprof=nprofin;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create output "head" structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (isfield(headin,'ptype'))
   head.ptype=headin.ptype;
end
if (isfield(headin,'pfields'))
   head.pfields=headin.pfields;
else
   head.pfields=1;
end
%
if (isfield(headin,'pmin'))
   head.pmin=headin.pmin;
end
if (isfield(headin,'pmax'))
   head.pmax=headin.pmax;
end
%
head.ngas=ngas; % already tested for existance
if (isfield(headin,'glist'))
   head.glist=headin.glist(indg);
end
if (isfield(headin,'gunit'))
   head.gunit=headin.gunit(indg);
end
head.nchan=nchan; % already tested for existance
%
if (isfield(headin,'ichan'))
   head.ichan=headin.ichan(indc);
end
if (isfield(headin,'vchan'))
   head.vchan=headin.vchan(indc);
end
if (isfield(headin,'vcmin'))
   head.vcmin=headin.vcmin;
   if (nchanin ~= nchan)
      disp('You should verify head.vcmin is correct for the new channel set')
   end
end
if (isfield(headin,'vcmax'))
   head.vcmax=headin.vcmax;
   if (nchanin ~= nchan)
      disp('You should verify head.vcmax is correct for the new channel set')
   end
end
%
if (isfield(headin,'mwnchan'))
   head.mwnchan=headin.mwnchan;
else
   head.mwnchan=0;
end
if (isfield(headin,'mwfchan'))
   head.mwfchan=headin.mwfchan;
end
if (isfield(headin,'udef1'))
   head.udef1=headin.udef1;
end
if (isfield(headin,'udef2'))
   head.udef2=headin.udef2;
end
if (isfield(headin,'udef'))
   head.udef=headin.udef;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create output "prof" structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Location
if (isfield(profin,'plat'))
   prof.plat=profin.plat(indp);
end
if (isfield(profin,'plon'))
   prof.plon=profin.plon(indp);
end
if (isfield(profin,'ptime'))
   prof.ptime=profin.ptime(indp);
end
%
% Land
if (isfield(profin,'landfrac'))
   prof.landfrac=profin.landfrac(indp);
end
if (isfield(profin,'landtype'))
   prof.landtype=profin.landtype(indp);
end
if (isfield(profin,'smoist'))
   prof.smoist=profin.smoist(indp);
end
%
% Surface
if (isfield(profin,'stemp'))
   prof.stemp=profin.stemp(indp);
end
if (isfield(profin,'spres'))
   prof.spres=profin.spres(indp);
end
if (isfield(profin,'salti'))
   prof.salti=profin.salti(indp);
end
%
% Emissivity & reflectivity
if (isfield(profin,'nrho'))
   prof.nrho=profin.nrho(indp);
   if (isfield(profin,'rfreq'))
      prof.rfreq=profin.rfreq(:,indp);
   end
   if (isfield(profin,'rho'))
      prof.rho=profin.rho(:,indp);
   end
end
if (isfield(profin,'nemis'))
   prof.nemis=profin.nemis(indp);
   if (isfield(profin,'efreq'))
      prof.efreq=profin.efreq(:,indp);
   end
   if (isfield(profin,'emis'))
      prof.emis=profin.emis(:,indp);
   end
end
%
% Angles
if (isfield(profin,'scanang'))
   prof.scanang=profin.scanang(indp);
end
if (isfield(profin,'satzen'))
   prof.satzen=profin.satzen(indp);
end
if (isfield(profin,'satazi'))
   prof.satazi=profin.satazi(indp);
end
if (isfield(profin,'solzen'))
   prof.solzen=profin.solzen(indp);
end
if (isfield(profin,'solazi'))
   prof.solazi=profin.solazi(indp);
end
%
% MW "a" and "b" scan angle and satellite zenith angle
if (isfield(profin,'mwasang'))
   prof.mwasang=profin.mwasang(indp);
end
if (isfield(profin,'mwaszen'))
   prof.mwaszen=profin.mwaszen(indp);
end
if (isfield(profin,'mwbsang'))
   prof.mwbsang=profin.mwbsang(indp);
end
if (isfield(profin,'mwbszen'))
   prof.mwbszen=profin.mwbszen(indp);
end
%
% Profiles
if (isfield(profin,'nlevs'))
   prof.nlevs=profin.nlevs(indp);
end
if (isfield(profin,'plevs'))
   prof.plevs=profin.plevs(:,indp);
end
if (isfield(profin,'plays'))
   prof.plays=profin.plays(:,indp);
end
if (isfield(profin,'palts'))
   prof.palts=profin.palts(:,indp);
end
if (isfield(profin,'ptemp'))
   prof.ptemp=profin.ptemp(:,indp);
end
for ig=1:ngas
   gstr=int2str(head.glist(ig));
   if (isfield(profin,['gas_' gstr]))
      eval(['prof.gas_' gstr '=profin.gas_' gstr '(:,indp);']);
   else
      disp(['Warning: expected profin field gas_' gstr ' does not exist'])
      return
   end
end
if (isfield(profin,'gxover'))
   prof.gxover=profin.gxover(indg,indp);
end
if (isfield(profin,'txover'))
   prof.txover=profin.txover(indp);
end
if (isfield(profin,'co2ppm'))
   prof.co2ppm=profin.co2ppm(indp);
end
%
% Clouds and wind
if (isfield(profin,'cfrac'))
   prof.cfrac=profin.cfrac(indp);
end
if (isfield(profin,'ctype'))
   prof.ctype=profin.ctype(indp);
end
if (isfield(profin,'cemis'))
   prof.cemis=profin.cemis(indp);
end
if (isfield(profin,'cprtop'))
   prof.cprtop=profin.cprtop(indp);
end
if (isfield(profin,'cprbot'))
   prof.cprbot=profin.cprbot(indp);
end
if (isfield(profin,'cngwat'))
   prof.cngwat=profin.cngwat(indp);
end
if (isfield(profin,'cpsize'))
   prof.cpsize=profin.cpsize(indp);
end
if (isfield(profin,'wsource'))
   prof.wsource=profin.wsource(indp);
end
if (isfield(profin,'wspeed'))
   prof.wspeed=profin.wspeed(indp);
end
%
% Microwave surface
if (head.mwnchan > 0)
   if (isfield(profin,'mwnemis'))
      prof.mwnemis=profin.mwnemis(indp);
   end
   if (isfield(profin,'mwefreq'))
      prof.mwefreq=profin.mwefreq(:,indp);
   end
   if (isfield(profin,'mwemis'))
      prof.mwemis=profin.mwemis(:,indp);
   end
   if (isfield(profin,'mwnstb'))
      prof.mwnstb=profin.mwnstb(indp);
   end
   if (isfield(profin,'mwsfreq'))
      prof.mwsfreq=profin.mwsfreq(:,indp);
   end
   if (isfield(profin,'mwstb'))
      prof.mwstb=profin.mwstb(:,indp);
   end
end
%
% Radiance
if (head.pfields > 1)
   if (isfield(profin,'pobs'))
      prof.pobs=profin.pobs(indp);
   end
   if (isfield(profin,'zobs'))
      prof.zobs=profin.zobs(indp);
   end
   if (isfield(profin,'upwell'))
      prof.upwell=profin.upwell(indp);
   end
   %
   if (isfield(profin,'rcalc'))
      prof.rcalc=profin.rcalc(indc,indp);
   end
   if (isfield(profin,'mwcalc'))
      prof.mwcalc=profin.mwcalc(:,indp);
   end
   %
   if (isfield(profin,'rlat'))
      prof.rlat=profin.rlat(indp);
   end
   if (isfield(profin,'rlon'))
      prof.rlon=profin.rlon(indp);
   end
   if (isfield(profin,'rfill'))
      prof.rfill=profin.rfill(indp);
   end
   if (isfield(profin,'rtime'))
      prof.rtime=profin.rtime(indp);
   end
   %
   if (isfield(profin,'robs1'))
      prof.robs1=profin.robs1(indc,indp);
   end
   if (isfield(profin,'irinst'))
      prof.irinst=profin.irinst(indp);
   end
   %
   if (isfield(profin,'calflag'))
      prof.calflag=profin.calflag(indc,indp);
   end
   %
   if (isfield(profin,'mwobs'))
      prof.mwobs=profin.mwobs(:,indp);
   end
   if (isfield(profin,'mwinst'))
      prof.mwinst=profin.mwinst(indp);
   end
   %
   if (isfield(profin,'findex'))
      prof.findex=profin.findex(indp);
   end
   if (isfield(profin,'atrack'))
      prof.atrack=profin.atrack(indp);
   end
   if (isfield(profin,'xtrack'))
      prof.xtrack=profin.xtrack(indp);
   end
end
%
if (isfield(profin,'udef1'))
   prof.udef1=profin.udef1(indp);
end
if (isfield(profin,'udef2'))
   prof.udef2=profin.udef2(indp);
end
if (isfield(profin,'udef'))
   prof.udef=profin.udef(:,indp);
end

%%% end of file %%%
