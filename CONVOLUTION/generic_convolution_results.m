clear rconv fconv
rFWHM = input('enter FWHM : ');
rSp   = input('enter channel spacing : ');

figure(1); clf
  [fconv,rconv] = quickconvolve(freqs,radsOut.radAllChunks,rFWHM,rSp); 
  plot(fconv,rad2bt(fconv,rconv),'r')
  pause(0.1);

if iDoJac > 0
  clear qjac_conv tjac_conv wgt_conv sjac_conv ejac_conv
  iJacobOutput = stuff.iJacobOutput;
  [aa,iNumLayer] = size(jacsOut.tjacAllChunks);
  for ix = 1 : length(iDoJac)
    woof = squeeze(jacsOut.qjacAllChunks(ix,:,:));
    [fconv,xyz] = quickconvolve(freqs,woof,rFWHM,rSp); 
    qjac_conv(ix,:,:) = xyz;
    end
  [fconv,tjac_conv] = quickconvolve(freqs,jacsOut.tjacAllChunks,rFWHM,rSp); 
  [fconv,wgt_conv] = quickconvolve(freqs,jacsOut.wgtAllChunks, rFWHM,rSp); 

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
    [fconv,sjac_conv] = quickconvolve(freqs,jacsOut.sjacAllChunks,rFWHM,rSp); 
    [fconv,ejac_conv] = quickconvolve(freqs,jacsOut.ejacAllChunks,rFWHM,rSp); 
    end

  end
