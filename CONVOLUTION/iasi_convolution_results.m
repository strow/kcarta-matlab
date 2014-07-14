addpath /home/sergio/MATLABCODE/FCONV
addpath /home/sergio/MATLABCODE/FFTCONV

clear rconv fconv
figure(1); clf
  plot(freqs,rad2bt(freqs,radsOut.radAllChunks))
  
  %% calcs
  [rconv, fconv] = kcarta_fconvkc(radsOut.radAllChunks,freqs,'iasi12992','gauss',6);

  plot(fconv,rad2bt(fconv,rconv'),'r')
  pause(0.1);

if iDoJac > 0
  clear qjac_conv tjac_conv wgt_conv sjac_conv ejac_conv
  iJacobOutput = stuff.iJacobOutput;
  [aa,iNumLayer] = size(jacsOut.tjacAllChunks);
  for ix = 1 : length(iDoJac)
    woof = squeeze(jacsOut.qjacAllChunks(ix,:,:));
    [xyz,fconv] = kcarta_fconvkc(woof,freqs,'iasi12992','gauss',6);
    qjac_conv(ix,:,:) = xyz';
    end
  [tjac_conv,fconv] = kcarta_fconvkc(jacsOut.tjacAllChunks,freqs,'iasi12992','gauss',6);
  [wgt_conv,fconv]  = kcarta_fconvkc(jacsOut.wgtAllChunks, freqs,'iasi12992','gauss',6);

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
    [sjac_conv,fconv] =kcarta_fconvkc(jacsOut.sjacAllChunks,freqs,'iasi12992','gauss',6);
    [ejac_conv,fconv] =kcarta_fconvkc(jacsOut.ejacAllChunks,freqs,'iasi12992','gauss',6);
    end

  end
