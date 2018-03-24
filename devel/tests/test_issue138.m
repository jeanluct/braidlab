function test_issue128

import braidlab.*

global BRAIDLAB_debuglvl BRAIDLAB_braid_nomex

BRAIDLAB_debuglvl = 1;

fprintf('Enable braid MEX file:\n')
BRAIDLAB_braid_nomex = false;
tic, bigTEPO(1894), toc
tic, bigTEPO(1895), toc

fprintf('Disable braid MEX file:\n')
BRAIDLAB_braid_nomex = true;
tic, bigTEPO(1894), toc
tic, bigTEPO(1895), toc

%=========================================================================
function [TEPO,b] = bigTEPO(n)
% Computes the TEPO (with respect to the new generating set) of a family of
% high-TEPO braids.

import braidlab.*

% First operation: swap punctures 1 and n, 2 and n-1, etc.
b = braid([],n);
for i = 1:floor(n/2)
  b = b*bigGen(i,n-i+1,n,'new');
end

% Second operation: two more inverse twists to make it pseudo-Anosov.
twist1 = bigGen(1,floor(n/2),n,'new');
twist2 = bigGen(floor(n/2)+1,n,n,'new');
b = b*inv(twist1)*inv(twist2);

TEPO = entropy(b)/2;

%=========================================================================
function [b] = bigGen(i,j,n,type)
% New, newer, or ribbon generator swapping punctures i and j in B_n.

import braidlab.*

switch type
  case 'new'
    K = [i+1:j-1];
    b = braid([K(end:-1:1) i -K],n);
  case 'newer'
    K = [i+1:j-1];
    b = braid([K(end:-1:1) i K],n);
  case 'ribbon'
    b = braid([],n);
    for k = i:j-1
      b = b*braid(j-1:-1:k,n);
    end
  otherwise
    error('type must be new, newer, or ribbon.');
end
