clist_conv = input('Enter channel list (or -1 for all) : ');
if clist_conv == -1
  clist_conv = 1 : 2378;
  end

clear rconv fconv
addpath /asl/matlab/sconv 
addpath /asl/matlab/h4tools/
sfile = ...
  '/home/sergio/MATLABCODE/KCMIX2/KCMIXCODE/AUXFILES/srftables_031115v3.hdf';

figure(1); clf
  [rconv, fconv] = sconv2(radsOut.radAllChunks,freqs,clist_conv,sfile); 
  plot(fconv,rad2bt(fconv,rconv),'r')
  pause(0.1);

if iDoJac > 0
  clear qjac_conv tjac_conv wgt_conv sjac_conv ejac_conv
  iJacobOutput = stuff.iJacobOutput;
  [aa,iNumLayer] = size(jacsOut.tjacAllChunks);
  for ix = 1 : length(iDoJac)
    woof = squeeze(jacsOut.qjacAllChunks(ix,:,:));
    [xyz, fconv] = sconv2(woof,freqs,clist_conv,sfile); 
    qjac_conv(ix,:,:) = xyz;
    end
  [tjac_conv,fconv] = sconv2(jacsOut.tjacAllChunks,freqs,clist_conv,sfile); 
  [wgt_conv, fconv] = sconv2(jacsOut.wgtAllChunks, freqs,clist_conv,sfile); 

  figure(2); clf
  pcolor(fconv,1:iNumLayer,xyz'); shading interp; colorbar;
  if iJacobOutput == -1
      title(['dr/dq for gasID ' num2str(iDoJac(length(iDoJac)))]);
    elseif iJacobOutput == 0
      title(['dr/dq * q for gasID ' num2str(iDoJac(length(iDoJac)))]);
    elseif iJacobOutput == +1
      title(['dBT/dq*q for gasID ' num2str(iDoJac(length(iDoJac)))]);
      end

  figure(3); clf
    pcolor(fconv,1:iNumLayer,tjac_conv'); shading interp; colorbar;
    if iJacobOutput == -1
      title('dr/dT');
    elseif iJacobOutput == 0
      title('dr/dT ');
    elseif iJacobOutput == +1
      title('dBT/dT');
      end

  figure(4); clf
    pcolor(fconv,1:iNumLayer,wgt_conv'); shading interp; colorbar;
    title('Wgt');

  iDownLook = -1;
  if isfield(jacsOut,'ejacAllChunks') & isfield(jacsOut,'sjacAllChunks')
    iDownLook = +1;
    end
  if iDownLook == +1
    [sjac_conv, fconv] = sconv2(jacsOut.sjacAllChunks,freqs,clist_conv,sfile); 
    [ejac_conv, fconv] = sconv2(jacsOut.ejacAllChunks,freqs,clist_conv,sfile); 
    end

  end
