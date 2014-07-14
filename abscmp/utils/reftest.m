
% check reference gas profiles and calculate relative 
% gas weights

% load an explicit list of reference gasses
load reflist -ascii

ngas = length(reflist);

% load reference profiles into an nlayer x nfield x ngas array
%
refset = zeros(100,5,ngas);

for i = 1:ngas

  gid = reflist(i);

  gstr = ['refgas', num2str(gid)];

  eval(['load refprof/', gstr]);
  eval(['rtmp = ', gstr, ';']);
  eval(['clear ', gstr]);

  refset(:,:,i) = rtmp;

end  


% for each layer, compare nominal pressure to sum of partial
% pressures across all specified gasses
%
psum = sum(squeeze(refset(:,3,:))')';

[squeeze(refset(:, 2, 1)), psum]


% calculate relative gas weights; note gwts is indexed by
% gas ID, rather than the reflist index
%
gmax = max(reflist);
gwts = zeros(gmax, 1);

rlev = 4; % pressure level for comparisons

for i = 1:ngas
  
  gid = reflist(i);

  % weight is ratio of partial pressure to pressure
  gwts(gid) =  refset(rlev, 3, i) / refset(rlev, 2, i);

end

