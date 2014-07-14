function [fc,qc]=quickconvolve(f,raaR,rFWHM,spacing)
% function [fc,qc]=quickconvolve(f,raaR,rFWHM,spacing)
% this function convolves input matrix raaR (at wavenumber f) with a
% set of equal gaussians whose FWHM is input, as is the channel spacing

[nn1,mm1] = size(f);
[nn,mm] = size(raaR);

l1 = length(f);
l2 = length(raaR);
if (l1 ~=  l2)
  error('f,raaR are of different lengths!')
  end
if mm1 < nn1
  f = f';
  end
if mm < nn
  raaR = raaR';
  end
[nn,mm] = size(raaR);


% first build up the gaussian
rSQW = rFWHM/2.0;
rSQW = log(2.0)/(rSQW*rSQW);
rSQW = sqrt(rSQW); 
 
rFS = -5.0*rFWHM; 
rFE = +5.0*rFWHM;
 
%compute how many points the gaussian needs to be
rFreqSpacing = (f(length(f))-f(1))/length(f);
      
raF = rFS:rFreqSpacing:rFE;
if (mod(length(raF),2) ~= 1)
   raF(length(raF)+1) = raF(length(raF))+rFreqSpacing;
   end

raSRF = rSQW*rSQW*raF.*raF;
raSRF = exp(-raSRF); 
rSum = sum(raSRF);
raSRF = raSRF/rSum;

%plot(raF,raSRF);title('gaussian SRF');
 
% now go thru and convolve!!!
ll = length(f);
center = (length(raF)+1)/2;
step = round(spacing/rFreqSpacing);
num_channels = (f(length(f))-f(1))/spacing;
num_channels = fix(num_channels); %round down
zaza = ones(nn,1)*raSRF;
fc = zeros(1,num_channels);
qc = zeros(nn,num_channels);

imax = 0;
for ii = 1:num_channels
  ind = (1:length(raF))+(ii-1)*step;
  if ((ind(1) <= ll) & (ind(length(ind)) <= ll))
    imax = ii;
    fc(ii) =  sum(raSRF.*f(ind));
    haha   =  zaza.*raaR(:,ind);
    haha   =  haha';
    qc(:,ii) = (sum(haha))';
    end
  end

fc = fc(1:imax);
qc = qc(:,1:imax);

%plot(fc,qc)

qc = qc';
