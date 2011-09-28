function [varargout] = split_gencross(X,t)

import braidlab.color_braiding

if size(t,1) < size(t,2), t = t.'; end % Make sure t is a column vector.

ndat = length(t);          % number of data points
blk = 100;                 % the size of each block
nblk = ceil(ndat/blk);     % number of blocks

% Loop over blocks
gen = []; tcr = []; b1 = 1;
for b = 1:nblk
  b0 = b1;
  badblock = true;
  while badblock
    b1 = min(b0+blk,ndat)
    tblk = t(b0:b1);
    Xblk = X(b0:b1,:,:);
    for I = 1:size(X,3)
      for J = I+1:size(X,3)
	if Xblk(1,1,I) == Xblk(1,1,J)
	  disp('bad block separation.')
	else
	  badblock = false;
	end
      end
    end
  end
  [gen1 tcr1] = color_braiding(Xblk,tblk);
  gen = [gen; gen1];
  tcr = [tcr; tcr1];
end

varargout{1} = gen;
if nargout > 1, varargout{2} = tcr; end
%if nargout > 2, varargout{3} = cross_cell; end
