function [h,ha,p,pa] = doload(dirin,fin,klayers_code,iAirs,junkdir);
%%%%% this function loads in the granule of data we are interested in
%%%%% if the data is a levels file, no need to do anything;
%%%%     else run through klayers

junkdir = klayers_code.junkdir;

filein = [dirin '/' fin];

if (iAirs >= 0)
  klayers = ['!' klayers_code.airs ' fin=' filein];
elseif (iAirs == -1)
  klayers = ['!' klayers_code.aeri ' fin=' filein];
else
  error('unknown instrument!!!')
end

[h,ha,p,pa] = rtpread(filein); 
if h.ptype == 0 
  disp('running thru klayers'); 

  %%%run filename(ii) thru klayers   
  rstr = num2str(floor(100000000*rand));  
  fklayers1 = [junkdir '/blah1.op.rtp' rstr];  
  klayers=[klayers ' fout=' fklayers1 ' nwant=-1 >& /dev/null'];  
  %klayers=[klayers ' fout=' fklayers1 ' nwant=-1'];  
  fprintf(1,'klayers = %s \n',klayers);  
  eval([klayers]);  

  [h,ha,p,pa] = rtpread(fklayers1); 
  rmer = ['!/bin/rm ' fklayers1]; eval(rmer);  %%%%remove klayers run  

end

fprintf(1,'loaded in profile(s) from %s ....\n',filein)
disp(' ')