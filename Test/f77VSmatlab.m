addpath /asl/matlib/h4tools
addpath /home/sergio/KCARTA/MATLAB

[h,ha,p,pa] = rtpread('/home/sergio/KCARTA/IP_PROFILES/junk49.op.rtp');
[hout,pout,iWarning,fout,rout,wmono,dallmono] = driver_process_kcarta_rtp(h,ha,p,pa,1);

[d,w] = readkcstd('/home/sergio/KCARTA/IP_PROFILES/f77H2008_kc118_ckd1/rad.dat1');

figure(1); 
  plot(wmono,rad2bt(wmono,dallmono) - rad2bt(wmono,d))
  axis([605 2830 -0.025 +0.025])
  title('BTD H2008, CKD1')
  
figure(2)
  plot(wmono,dallmono - d)
  axis([605 2830 -0.025 +0.025])
  title('Rad Diff H2008, CKD1')  