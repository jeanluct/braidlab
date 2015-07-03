function [varargout] = loopsigma(sigma_idx,lp)
%LOOPSIGMA   Act on a loop with a braid group generator sigma.
%
%   UP = LOOPSIGMA(SIGMA_IDX,LP) acts on the loop LP (encoded in Dynnikov
%   coordinates) with the braid generator whose indices are stored in SIGMA_IDX,
%   and returns the new loop.  SIGMA_IDX can be a positive or negative integer
%   (inverse generator), and can be specified as a vector, in which case all
%   the generators are applied to the loop sequentially from left to right.
%
%   LP is specified as a row vector, or a matrix whose each row corresponds
%   to a separate loop.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic         <marko@math.wisc.edu>
%
%   This file is part of Braidlab.
%
%   Braidlab is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   Braidlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
% LICENSE>

% set to true to use Matlab instead of C++ version of the algorithm
global BRAIDLAB_braid_nomex;
useMatlabVersion = any(BRAIDLAB_braid_nomex);

if isempty(sigma_idx)
  varargout{1} = lp;
  if nargout > 1
    varargout{2} = reshape([],[size(lp,1) 0]);
  end
  return
end

% If MEX file is available, use that.
if ~useMatlabVersion && exist('loopsigma_helper','file') == 3
  if isa(lp,'double') || isa(lp,'single') || isa(lp,'int32') || isa(lp,'int64')
    [varargout{1:nargout}] = loopsigma_helper(sigma_idx,lp);
    return

  elseif isa(lp,'vpi')

    % Convert u to cell of strings to pass to C++ file.
    ustr = cell(size(lp));
    for i = 1:size(lp,1)
      for j = 1:size(lp,2)
        ustr{i,j} = strtrim(num2str(lp(i,j)));
      end
    end

    % Call MEX function, but make sure to check if it was compiled with GMP
    % (multiprecision).  It will return an error if it wasn't.
    compiled_with_gmp = true;
    try
      [varargout{1:nargout}] = loopsigma_helper(sigma_idx,ustr);
    catch err
      if strcmp(err.identifier,'BRAIDLAB:loopsigma_helper:badtype')
        compiled_with_gmp = false;
      else
        rethrow(err)
      end
    end

    if compiled_with_gmp
      % Convert cell of strings back to vpi.
      uvpi = vpi(zeros(size(lp)));
      for i = 1:size(lp,1)
        for j = 1:size(lp,2)
          uvpi(i,j) = vpi(varargout{1}{i,j});
        end
      end

      varargout{1} = uvpi;
      return
    end
  end
end

n = size(lp,2)/2 + 2;
a = lp(:,1:n-2); b = lp(:,(n-1):end);
ap = a; bp = b;

pos = @(x)max(x,0); neg = @(x)min(x,0);

% If nargout > 1, record the state of pos/neg operators.
% There are at most maxopSign such choices for each generator.
maxopSign = 5;
if nargout > 1, opSign = zeros(size(lp,1),length(sigma_idx),maxopSign); end

for j = 1:length(sigma_idx)
  i = abs(sigma_idx(j));
  if sigma_idx(j) > 0
    switch(i)
     case 1
      bp(:,1) = sumg( a(:,1) , pos(b(:,1)) );
      ap(:,1) = sumg( -b(:,1) , pos(bp(:,1)) );

      if nargout > 1
        opSign(:,j,1) = sign(b(:,1));
        opSign(:,j,2) = sign(bp(:,1));
      end

     case n-1
      bp(:,n-2) = sumg( a(:,n-2) , neg(b(:,n-2)) );
      ap(:,n-2) = sumg( -b(:,n-2) , neg(bp(:,n-2)) );

      if nargout > 1
        opSign(:,j,1) = sign(b(:,n-2));
        opSign(:,j,2) = sign(bp(:,n-2));
      end

     otherwise
      c = sumg( a(:,i-1), -a(:,i), -pos(b(:,i)), neg(b(:,i-1)) );
      ap(:,i-1) = sumg( a(:,i-1), -pos(b(:,i-1)), -pos(sumg(pos(b(:,i)), c)) );
      bp(:,i-1) = sumg( b(:,i), neg(c) );
      ap(:,i) = sumg( a(:,i), -neg(b(:,i)), -neg(sumg(neg(b(:,i-1)), -c)) );
      bp(:,i) = sumg( b(:,i-1), -neg(c) );

      if nargout > 1
        opSign(:,j,1) = sign(b(:,i));
        opSign(:,j,2) = sign(b(:,i-1));
        opSign(:,j,3) = sign(c);
        opSign(:,j,4) = sign(pos(b(:,i)) + c);
        opSign(:,j,5) = sign(neg(b(:,i-1)) - c);
      end
    end
  elseif sigma_idx(j) < 0
    switch(i)
     case 1
      bp(:,1) = sumg(-a(:,1), pos(b(:,1)) );
      ap(:,1) = sumg(b(:,1), -pos(bp(:,1)) );

      if nargout > 1
        opSign(:,j,1) = sign(b(:,1));
        opSign(:,j,2) = sign(bp(:,1));
      end

     case n-1
      bp(:,n-2) = sumg(-a(:,n-2), neg(b(:,n-2)) );
      ap(:,n-2) = sumg(b(:,n-2), - neg(bp(:,n-2)) );

      if nargout > 1
        opSign(:,j,1) = sign(b(:,n-2));
        opSign(:,j,2) = sign(bp(:,n-2));
      end

     otherwise
      d = sumg(a(:,i-1), -a(:,i), pos(b(:,i)), -neg(b(:,i-1)));
      ap(:,i-1) = sumg(a(:,i-1), pos(b(:,i-1)), pos(sumg(pos(b(:,i)),- d)) );
      bp(:,i-1) = sumg(b(:,i), -pos(d));
      ap(:,i) = sumg(a(:,i), neg(b(:,i)), neg(sumg(neg(b(:,i-1)), d)) );
      bp(:,i) = sumg(b(:,i-1), pos(d) );

      if nargout > 1
        opSign(:,j,1) = sign(b(:,i));
        opSign(:,j,2) = sign(b(:,i-1));
        opSign(:,j,3) = sign(pos(b(:,i)) - d);
        opSign(:,j,4) = sign(d);
        opSign(:,j,5) = sign(neg(b(:,i-1)) + d);
      end
    end
  end
  a = ap; b = bp;
end
varargout{1} = [ap bp];

if nargout > 1
  opSign = reshape(opSign,[size(lp,1) maxopSign*length(sigma_idx)]);
  varargout{2} = opSign;
end
