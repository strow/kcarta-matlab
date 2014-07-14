[aa,iNumLayer] = size(absc);

clear rconv fconv
figure(1); clf
  [fc,qc] = quickconvolve(freqs,radsOut.radAllChunks,0.5,0.5);
  plot(fc,rad2bt(fc,qc))
  
if iDoJac > 0
  clear qjac_conv tjac_conv wgt_conv sjac_conv ejac_conv
  iJacobOutput = stuff.iJacobOutput;
  [aa,iNumLayer] = size(jacsOut.tjacAllChunks);
  for ix = 1 : length(iDoJac)
    woof = squeeze(jacsOut.qjacAllChunks(ix,:,:));
    [xyz, fconv] = quickconvolve(freqs,woof,0.5,0.5);
    qjac_conv(ix,:,:) = xyz;
    end
  [fconv,tjac_conv] = quickconvolve(freqs,jacsOut.tjacAllChunks,0.5,0.5);
  [fconv,wgt_conv]  = quickconvolve(freqs,jacsOut.wgtAllChunks,0.5,0.5);

  figure(2); clf
  pcolor(fconv,1:iNumLayer,qjac_conv'); shading interp; colorbar;
  if iJacobOutput == -1
      title(['dr/dq for gasID ' num2str(iDoJac)]);
    elseif iJacobOutput == 0
      title(['dr/dq * q for gasID ' num2str(iDoJac)]);
    elseif iJacobOutput == +1
      title(['dBT/dq*q for gasID ' num2str(iDoJac)]);
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
    [sjac_conv, fconv] = quickconvolve(freqs,jacsOut.sjacAllChunks,0.5,0.5);
    [ejac_conv, fconv] = quickconvolve(freqs,jacsOut.ejacAllChunks,0.5,0.5);
    end

  end
