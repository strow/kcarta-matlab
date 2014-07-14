function [rch, wch] = kcarta_fconvkc(rkc_in, wkc_in0, ifp, atype, aparg)

%% copied from /home/sergio/MATLABCODE/FCONV/fconvkc_serg.m

% [rch, wch] = kcarta_fconvkc(rkc, wkc, ifp, atype, aparg)
% this simply takes in the radiance info, and then depending on ifp, sets
% everything up so that (Howard Motteler) fconv or (Scott Hannon) s2fconvkc
% can be run for KCARTA outputs

%%% big difference : here the wkc == input kcarta wavenumbers are required
%%% so the code checks the input wkc is correct length; if not it extends 
%%% the vector(s) by zero filling (or using last datapoint)
%%% [rch, wch] = fconvkc(rkc, ifp, atype, aparg);

dkc    = 0.0025;
wkc_in = 1:length(wkc_in0);
wkc_in = wkc_in0(1) + dkc * (wkc_in - 1);

[xx,yy]=size(rkc_in);
% we want things in column order!!!!!!
if (yy > xx)
  rkc_in=rkc_in';
  end
[xx,yy]=size(rkc_in);

% read user-defined parameter assignments
% feval([ifp, '.m']);       %%%%%this is orig M5.2 code
eval(ifp);
hfr=v1:dkc:v2;   %% comes from ifp
V1 = v1; V2 = v2;

k1 = wkc_in(1);
k2 = wkc_in(length(wkc_in));

rkc=zeros(length(hfr),yy);  

iNeed = -9999;
if ((V1 >= k1) & (V2 <= k2))
  %kCARTA run has extended beyond V1,V2
  %------+----+-----------+---+------ 
  %      k1   V1          V2  k2
  ind1 = find(abs(wkc_in-V1) <= dkc/2);
  ind2 = find(abs(wkc_in-V2) <= dkc/2);
  ind = ind1:ind2;
  rkc = rkc_in(ind,:);
  iNeed = +1;         %% need to do convolution
elseif ((V1 >= k1) & (V2 > k2) & (V1 < k2))
  %kCARTA run has only extended beyond V1
  %------+----+-----------+---+------ 
  %      k1   V1          k2  V2
  ind1 = find(abs(wkc_in-V1) <= dkc/2);
  ind2 = length(wkc_in);
  indk = ind1:ind2;
  ind1 = 1;
  ind2 = find(abs(hfr-k2) <= dkc/2);
  indh = ind1:ind2;
  rkc(indh,:) = rkc_in(indk,:);
    for yyii = 1 : yy    
      rkc(max(indh)+1:length(rkc),yyii) = rkc_in(length(indk),yyii);
      end
  iNeed = +2;         %% need to do convolution
elseif ((V1 < k1) &  (V2 <= k2) & (k1 < V2))
  %kCARTA run has only extended beyond V2
  %------+----+-----------+---+------ 
  %      V1   k1          V2  k2
  ind1 = 1;
  ind2 = find(abs(wkc_in-V2) <= dkc/2);
  indk = ind1:ind2;
  ind1 = find(abs(hfr-k1) <= dkc/2);
  ind2 = length(hfr);
  indh = ind1:ind2;
  rkc(indh,:) = rkc_in(indk,:);
  iNeed = +3;         %% need to do convolution
elseif ((V1 < k1) &  (V2 > k2))
  %kCARTA run has extended less than V1,V2
  %------+----+-----------+---+------ 
  %      V1   k1          k2  V2
  indk = 1:length(wkc_in);  %% use all of kcarta input
  ind1 = find(abs(hfr-k1) <= dkc/2);
  ind2 = find(abs(hfr-k2) <= dkc/2);
  indh = ind1:ind2;
  rkc(indh,:) = rkc_in(indk,:);
  iNeed = +4;         %% need to do convolution
elseif (V2 < k1) 
  %kCARTA run in outside V1 to V2
  %------+----+-----------+---+------ 
  %      V1   V2          k1  k2
  iNeed = -1;         %% no need to do convolution
elseif (V1 > k2)
  %kCARTA run in outside V1 to V2
  %------+----+-----------+---+------ 
  %      k1   k2          V1  V2
  iNeed = -1;         %% no need to do convolution
  end

clear  nd

%ifp
%iNeed 
%[V1 V2 k1 k2]

if iNeed > 0
  %% [rch, wch] = fconvkc(rkc, ifp, atype, aparg);  %% till Dec 2010
  %% [rch, wch] = fconvkc1(rkc, ifp, atype, aparg);
  %ifp
  %atype
  %aparg
  [rch, wch] = s2fconvkc(rkc, ifp, atype, aparg);      %% Scott's new convolver
  %whos rch wch hfr rkc wkc_in0 rkc_in
  %plot(hfr,rkc,'bo-',wkc_in0,rkc_in,'r',wch,rch,'k*'); pause
elseif iNeed == -1
  rch = [];
  wch = [];
  fprintf(1,'wkc = %4i %4i ifp = %s .. no relevant kcarta data, no need to convolve \n',floor(k1),ceil(k2),ifp)
elseif iNeed == -9999
  fprintf(1,'wkc = %4i %4i ifp = %s .. something wrong \n',floor(k1),ceil(k2),ifp)
  error('something wrong')
  end

rch=rch';

