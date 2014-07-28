function qjacnew = doQjacOutput(gasprofQG,qjac,iDoJac,...
                                iJacobOutput,iNumLayer,freq,rad25);

%% this function does the iJacobOutput = 0,1 options for qjac
%% iJacobOutput = 0 : qjac --> qjac x gasamt
%% iJacobOutput = 1 : qjac --> dBT/dq x gasamt

for ix = 1 : length(iDoJac)
  woof = fliplr(gasprofQG(ix,:)); woof = woof';
  gasprofX(ix,:,:) = (woof*ones(1,10000))';
  end
qjacnew = qjac .* gasprofX;

if iJacobOutput == +1
  for ix = 1 : length(iDoJac)
    woof = squeeze(qjacnew(ix,:,:));
    qjacnew(ix,:,:) = woof .* (dbtdr(freq,rad25')'*ones(1,iNumLayer));
    end
  end      
