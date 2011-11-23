function [b,tc] = crosstimes(XY,t)

% Call as braid.crosstimes.

% Allow default empty braid: return trivial braid with one string.
if nargin < 1
  error('BRAIDLAB:braid:braidcross:nargin',...
        'Need at least one input argument.')
end

if nargin < 1
   t = 1:size(XY,1);
end

if size(XY,2) ~= 2 | max(size(size(XY))) ~= 3
  error('BRAIDLAB:braid:braidcross:badarray',...
        'Bad dimensions for argument XY(:,1:2,:).')
end

if size(XY,1) ~= length(t)
  error('BRAIDLAB:braid:braidcross:badarray',...
        'Insonsistent sizes for argument XY and t.')
end

[b,tc] = color_braiding(XY,t);

% Make sure tc is row/column vector like t.
if size(t,1) > size(t,2)
  tc = reshape(tc,[length(tc) 1]);
else
  tc = reshape(tc,[1 length(tc)]);
end
