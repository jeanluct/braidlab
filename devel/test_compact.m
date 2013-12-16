% Test braid compaction algorithm

% The compact method has been problematic.  Use this test when in doubt.
% This is also useful for optimizing.

% Reference values:
%
%  n   k   avg compaction
%  3   10  50.16%
%  4   10  62.24%
%  7   10  73.62%
%  7   20  65.49%
%  10  20  70.00%
%  10  30  67.25%

rng('default')
n = 10;  % how many strings
k = 30; % how many generators
compfrac = [];
for i = 1:1000
  b = braid('random',n,k); bc = compact(b);
  if b ~= bc
    error('There was a problem with compact: the braids are not equal.')
  end
  compfrac = [compfrac bc.length/b.length];
end

hist(compfrac)
fprintf('Compaction: average %.2f%% (best %.2f%%, worst %.2f%%)\n', ...
	100*mean(compfrac),100*min(compfrac),100*max(compfrac))
