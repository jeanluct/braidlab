function [L, A, B] = getSubsetLoop( varargin )
%GETSUBSETLOOP Generate loops enclosing punctures specified in the exclusion
%matrix.
%
% For contiguous punctures, generated loops are so-called "relaxed" loops,
% i.e., the intersection number of the loop with the horizontal axis is the
% minimal nonzero value -- two.
% Ex 1 relaxed loop enclosing punctures 2 - 5
%       -------------------
%    x |  x    x    x    x | x
%       -------------------
%
% For non-contiguous punctures, the generated loop can be visualized by
% modifying the smalles relaxed loop enclosing all desired punctures (as
% above), and then modifying it to "skip" undesired punctures among the
% contiguous ones by pulling the loop entirely "over" or "under" the
% puncture.
% Ex 2 loop enclosing punctures 2,3,5, skipping puncture 4 from "below"
%       -----------    ---
%    x |  x    x  | x | x | x
%      |           ---    |
%       ------------------
% Ex 3 loop enclosing punctures 2,3,5, skipping puncture 4 from "above"
%       ------------------
%      |           ---    |
%    x |  x    x  | x | x | x
%       -----------    ---
%
% For more on Dynnikov coordinates see Yurttaş, S. Öykü. 2013. “Geometric
% Intersection of Curves on Punctured Disks.” Journal of the Mathematical
% Society of Japan 65 (4): 1153–68. doi:10.2969/jmsj/06541153.
%
% L = GETSUBSETLOOP( EXCLUSIONMATRIX )
% EXCLUDED is a matrix where each row is treated as a exclusion vector.
% An exclusion vector has N elements (for N punctures). Its k-th element
% corresponds to the k-th puncture in the following way:
% -- if 0,  k-th puncture is included in the set
% -- if ~= 0,  k-th puncture is included in the set
%    additionally, for non-zero elements, the sign of the value indicates
%    the direction in which the puncture is excluded:
%    > 0 -- from below (Example 2 above)
%    < 0 -- from above (Example 3 above)
%    The sign is taken into account only for excluded punctures that are %
%    between the first and the last included puncture.
% Outputs a braidlab.loop vector.
%
% L = GETSUBSETLOOP( N, EXCLUSIONCELL )
% N is the number of punctures.
% EXCLUDED is a cell-array where each element is the vector of indices of
% punctures that are to be *excluded* from the loop. As above, the sign of
% the index determines the manner in which the puncture is excluded::
%    > 0 -- from below (Example 2 above)
%    < 0 -- from above (Example 3 above)
%    The sign is taken into account only for excluded punctures that are %
%    between the first and the last included puncture.
% Outputs a braidlab.loop vector.
%
% [L,A,B] = GETSUBSETLOOP(...)
%     As above, but also returns A and B components of Dynnikov coordinates.
%

%
% The examples above can be generated using the following vectors and/or
% cell arrays:
%
% Example 1: [  1  0  0  0  0  1 ] or {1,  6}
% Example 2: [  1  0  0  1  0  1 ] or {1,  4, 6}
% Example 3: [  1  0  0 -1  0  1 ] or {1, -4, 6}
%
%

if nargin == 0
  error('At least one input needed');
end

if nargin == 2
  N = varargin{1};
  exclusioncell = varargin{2};
  %% Generate the exclusion matrix based on the exclusion list

  validateattributes(N, {'numeric'},...
                     {'scalar','finite','nonnan','>',2});
  validateattributes(exclusioncell, {'cell'},{'vector'});

  K = numel(exclusioncell);
  exclusionmatrix = zeros(K,N);

  for k = 1:numel(exclusioncell)
    exclusionList = exclusioncell{k};
    validateattributes(exclusionList, {'numeric'},...
                       {'vector','finite','integer','nonnan'});
    exclusionList = unique(exclusionList);

    exclvector = zeros(1,N);
    exclvector( abs(exclusionList(exclusionList < 0)) ) = -1;
    exclvector( abs(exclusionList(exclusionList > 0)) ) = 1;

    exclusionmatrix(k,:) = exclvector;

  end

else
  exclusionmatrix = varargin{1};
end

validateattributes( exclusionmatrix, {'numeric'}, ...
                    {'nonnan','2d','finite'} );

exclusionmatrix = sign(exclusionmatrix);

% number of loops
K = size(exclusionmatrix,1);

% number of punctures
N = size(exclusionmatrix,2);

% Dynnikov A and B coordinates
A = zeros( K, N-2 );
B = zeros( K, N-2 );

% for each exclusion vector
for k = 1:K

  excvector = exclusionmatrix(k,:);

  Nin = sum( excvector == 0 );

  assert( Nin > 1 && Nin < N, 'Select at least 2 and at most N-1 punctures' );

  % find the first and last *included* element
  first = find( excvector == 0, 1, 'first');
  last = find( excvector == 0, 1, 'last');

  % the B coordinates determine the relaxed loop
  if first > 1
    assert( first - 1 >= 1 && first - 1 <= N-2 );
    B( k, first-1 ) = -1;
  end
  if last < N
    assert( last - 1 >= 1 && last - 1 <= N-2 );
    B( k, last-1 ) = 1;
  end

  % the A coordinates are set to +1 where exclusion should go above
  % and to -1 where exclusion should go below
  setvector = excvector;
  setvector(1:first) = 0;
  setvector(last:end) = 0;

  % the first and last puncture don't have a parallel in the setvector
  % so they are skipped (the loop always winds around them, not above or below)
  A(k, :) = setvector(2:end-1);

end

L = braidlab.loop( [A,B] );
