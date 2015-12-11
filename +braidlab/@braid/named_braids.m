function [W,N] = named_braids( name, varargin )
%NAMED_BRAIDS
% First argument is a string.
switch lower(b)
  case {'halftwist','delta'}
    [W,N] = braidlab.braid.named_braid_halftwist(varargin);
  case {'fulltwist','delta2'} % just double-up halftwist
    [W,N] = braidlab.braid.named_braid_halftwist(varargin);
    W = [W W];
  case {'hironakakin','hironaka-kin','hk'}
    [W, N] = braidlab.braid.named_braid_hk( varargin );
  case {'venzkepsi','psi'}
    [W, N] = braidlab.braid.named_braid_venzke( varargin );
  case {'rand','random'}
    [W,N] = braidlab.braid.named_braid_random( varargin );
  case {'normal','binomal','norm','binom'}
    [W,N] = braidlab.braid.named_braid_binom( varargin );
  otherwise
    [W, N] = braidlab.braid.knot2braid( varargin );
end
