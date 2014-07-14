
% NAME
%
%   kcabs -- dump unchunked absorption coefficients
%
% SYNOPSIS
%
%   kcabs(rin, aout, fout, kopts)
%
% INPUTS
%
%   rin    - an nlev RTP input profile
%   aout   - output filename for binary absorption data
%   fout   - output filename for binary frequency list
%   kopts  - optional parameters
% 
% OUTPUTS
%
%   aout   - an npt by nlev binary file of absorption data
%   fout   - an npt binary file, the frequency grid for aout
% 
% DESCRIPTION
% 
%   kcabs produces a set of mixed absorption coefficients over
%   an arbitrary frequency interval.  Most of the specifications
%   for this output, including the constituent set and pressure
%   levels, are taken from the input profile.  An exception is
%   the frequency range, which is specified as a parameter.
% 
%   The main job of kcabs is to "unchunk" the data from kcmix.
%   Due to the way the coefficient data is tabulated, kcmix works
%   in 10^4 point chunks.  Because of the potentially large data
%   sets, the unchunking is done by writing data to a file, with
%   with fseeks to the desired 10^4-point blocks.
% 
%   For a given requested interval [rv1,rv2], let [v1,v2] be the
%   interval at chunk boundaries, spanning [rv1,rv2] interval.
%   The output fout is a concatenation of the frequencies of the
%   requested chunks, from v1 to v2.
% 
%   NOTE: the frequency list fout need not be continuously spaced,
%   it is simply a list of the frequencies at which the tabulations 
%   were done.
% 
%  The optional parameters that can be set with kopts include the 
%  coefficient directory and reference profile
%
%   kcabs does the work of the Fortran kcarta and matlab readkc 
%   unchunker.
%
% BUGS
%
%   the spanning frequency calculation uses the old 25cm chunking 
%   for now; it should be updated when we get a new variable frequency
%   scale
%
% AUTHOR
%
%   H. Motteler
%   20 Apr 02

function kcabs(rin, aout, fout, kopts);

% read the specified profile
[head, hattr, prof, pattr] = rtpread2(fin);

% defaults from RTP fields
rv1 = head.vcmin;       % default min requested frequency
rv2 = head.vcmax;       % default max requested frequency
glist = head.glist;     % default consitituent list

% general defaults
refp = 'refpro.mat';                    % matlab reference profile
cdir = '/asl/data/kcarta/v20.matlab';   % path to compressed data 

% override defaults with values passed in as kopts fields
optvar = fieldnames(kopts);
for i = 1 : length(optvar)
  vname = optvar{i}
  if ~exist(vname, 'var')
    warning(sprintf('kcabs -- unexpected option %s', vname))
  end
  eval(sprintf('%s = kopts.%s;', vname, vname));
end

% allow for constituent subsets from kopts
glist = intersect(glist, head.glist);
gind = interp1(head.glist, 1:head.ngas, glist, 'nearest');
ngas = length(gind);

% get the list of requested chunks
chunklist = clist(rv1, rv2);
nchunks = length(chunklist);

% get the number of profiles
npro = length(prof);

% pre-extend the output file

% get the spanning frequencies and chunk list

% loop on chunks
for ic = 1: length(chunklist);

  % get the mixed absorptions
  [absc, ftmp] = kcmix2(ptmp, vchunk, cdir, refp);

  % loop on layers, do the seek and then the write

end % loop on chunks

