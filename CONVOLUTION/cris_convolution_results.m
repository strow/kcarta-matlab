addpath /home/sergio/MATLABCODE/FCONV
addpath /home/sergio/MATLABCODE/FFTCONV/CRIS

clear rconv fconv

figure(1); clf
  plot(freqs,rad2bt(freqs,radsOut.radAllChunks))
  
  %% calcs
  [rconv1, fconv1] = kcarta_fconvkc(radsOut.radAllChunks,freqs,'crisB1','hamming',6);
  [rconv2, fconv2] = kcarta_fconvkc(radsOut.radAllChunks,freqs,'crisB2','hamming',6);
  [rconv3, fconv3] = kcarta_fconvkc(radsOut.radAllChunks,freqs,'crisB3','hamming',6);
  fconv = [fconv1; fconv2; fconv3];
  rconv = [rconv1 rconv2 rconv3]; 
  %[B,I,J] = unique(fconv); fconv = fconv(I); rconv=rconv(I);
  plot(fconv,rad2bt(fconv,rconv'),'r')
  pause(0.1);

if iDoJac > 0
  clear qjac_conv tjac_conv wgt_conv sjac_conv ejac_conv
  iJacobOutput = stuff.iJacobOutput;
  [aa,iNumLayer] = size(jacsOut.tjacAllChunks);
  for ix = 1 : length(iDoJac)
    woof = squeeze(jacsOut.qjacAllChunks(ix,:,:));
    [qjac_conv1,fconv1] = kcarta_fconvkc(woof,freqs,'crisB1','hamming',6);
    [qjac_conv2,fconv2] = kcarta_fconvkc(woof,freqs,'crisB2','hamming',6);
    [qjac_conv3,fconv3] = kcarta_fconvkc(woof,freqs,'crisB3','hamming',6);
    xyz = [qjac_conv1 qjac_conv2 qjac_conv3];
    qjac_conv(ix,:,:) = xyz';  qjjj = xyz';
    end

  [tjac_conv1,fconv1] = kcarta_fconvkc(jacsOut.tjacAllChunks, freqs, ...
                                     'crisB1','hamming',6);
  [tjac_conv2,fconv2] = kcarta_fconvkc(jacsOut.tjacAllChunks, freqs, ...
                                     'crisB2','hamming',6);
  [tjac_conv3,fconv3] = kcarta_fconvkc(jacsOut.tjacAllChunks, freqs, ...
                                     'crisB3','hamming',6);
  xyz = [tjac_conv1 tjac_conv2 tjac_conv3];
  tjac_conv = xyz';

  [wgt_conv1,fconv1] = kcarta_fconvkc(jacsOut.wgtAllChunks, freqs, ...
                                     'crisB1','hamming',6);
  [wgt_conv2,fconv2] = kcarta_fconvkc(jacsOut.wgtAllChunks, freqs, ...
                                     'crisB2','hamming',6);
  [wgt_conv3,fconv3] = kcarta_fconvkc(jacsOut.wgtAllChunks, freqs, ...
                                     'crisB3','hamming',6);
  xyz = [wgt_conv1 wgt_conv2 wgt_conv3];
  wgt_conv = xyz';

  figure(2); clf
  pcolor(fconv,1:iNumLayer,qjjj'); shading interp; colorbar;
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
    [rconv1, fconv1]=kcarta_fconvkc(jacsOut.sjacAllChunks,freqs,'crisB1','hamming',6);
    [rconv2, fconv2]=kcarta_fconvkc(jacsOut.sjacAllChunks,freqs,'crisB2','hamming',6);
    [rconv3, fconv3]=kcarta_fconvkc(jacsOut.sjacAllChunks,freqs,'crisB3','hamming',6);
    sjac_conv = [rconv1 rconv2 rconv3]; 
    [rconv1, fconv1]=kcarta_fconvkc(jacsOut.ejacAllChunks,freqs,'crisB1','hamming',6);
    [rconv2, fconv2]=kcarta_fconvkc(jacsOut.ejacAllChunks,freqs,'crisB2','hamming',6);
    [rconv3, fconv3]=kcarta_fconvkc(jacsOut.ejacAllChunks,freqs,'crisB3','hamming',6);
    ejac_conv = [rconv1 rconv2 rconv3]; 
    end

  end
