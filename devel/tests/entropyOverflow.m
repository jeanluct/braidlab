function Ls = entropyOverflow(strands, Ntries)
%% Ls = entropyOverflow(strands, Ntries)
% Push braidlab to entropy overflow, just to test the boundaries.
%
% We generate braids of pre-specified number of strands with more
% and more generators, until the entropy computation overflows. Then
% we do a simple binary search to zero in on precisely the number of
% generators causing overflow.
%
% Generators are drawn at random using uniform distribution over
% numbers between (-Nstrands, Nstrands). Braidlab automatically
% discards sigma_0 generators, meaning that the braids sometimes end
% up being shorter than recorded, as sigma_0 should not correspond
% to any operation. We don't attempt to correct for that number.
%
% ** Inputs: **
%
% strands - list of numbers of strands for which to test, e.g., [3,
% 10, 100]
%
% Ntries  - attempts to determine at which length of braid overflow
% happens (optional)
%
% ** Outputs: **
%
%Ls      - number of generators in the braid causing overflow
%

import braidlab.*

% default number of attempts
if ~exist('Ntries','var') || isempty(Ntries)
  Ntries=100;
end

% output structure
Ls = nan(size(strands));

% loop in parallel over all numbers of strands
parfor s = 1:length(strands)

  Nstrands = strands(s);

  % boundaries of the length interval we are searching
  Llower = 1;
  Lupper = inf; % initial length


  Nleft = Ntries;
  while Nleft > 0

    % the attempt is either in the middle of the interval
    if Lupper < inf
      L = round((Llower + Lupper)/2);
      % or just go as far as you can if we haven't had overflow yet
    else
      L = 2*Llower;
    end

    %% produce a valid set of generators
    rng(1); % we need a repeatable set of generators
    maxIndAllowed = Nstrands-1;
    g = randi( [-maxIndAllowed, maxIndAllowed], [1, L] ); % discrete integer distribution
    maxIndex = max(abs(g(:)));
    assert( maxIndex <= maxIndAllowed, 'Generator index is badly set')

    %% produce a braid
    B = braid(g, Nstrands);

    fprintf('S: %d, Tries left %d, L = %d in [%d, %d], max index used %d...', ...
      Nstrands, Nleft, L, Llower, Lupper, maxIndex );
    overflow = false;

    %% overflow is detected using braidlab's internal error reporting
    % the error code has to contain 'BRAIDLAB' and 'overflow' in it
    try
      % compute the entropy using
      % braidlab.braid/entropy
      E = entropy(B, [], 1);
    catch ME
      if ~isempty(strfind(ME.identifier, 'BRAIDLAB')) && ...
          ~isempty(strfind(ME.identifier,'overflow'))
        overflow = true;
      else
        rethrow ME;
      end
    end

    %% on overflow, set the upper boundary of the length interval
    if overflow
      fprintf('caught overflow error.\n');
      Lupper = L;
      Ls(s) = B.length; % store braid length as output
    else
      fprintf('no overflow.\n');
      Llower = L;
    end

    %% termination is when the boundaries surround only a single number
    if abs(Llower-Lupper) <= 1
      fprintf('S: %d, Zeroed in at %d.\n', Nstrands, L);
      Nleft = -1;
    else
      Nleft = Nleft-1;
    end

  end
end

end
