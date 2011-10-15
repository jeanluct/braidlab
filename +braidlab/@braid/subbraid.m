function bs = subbraid(b,s)
%SUBBRAID   Extract a subset of strings from a braid.
%   BS = SUBBRAID(B,S) returns the subbraid BS, obtained by discarding
%   all strings in B but the ones specified in S.  S is a vector which
%   is a subset of 1:N, where N is the number of strings in the braid.
%
%   This is a method for the BRAID class.
%   See also BRAID.

if isempty(s)
  error('BRAIDLAB:braid:subbraid:badstring', ...
	'Specify some substrings.')
end

if min(s) < 1 | max(s) > b.n
  error('BRAIDLAB:braid:subbraid:badstring', ...
	'Substring out of range.')
end

nn = length(s);

p = 1:b.n;
bs = [];

for i = 1:length(b)
  gen = abs(b.word(i)); % unsigned generator
  i1 = find(p(gen) == s); i2 = find(p(gen+1) == s);
  if ~isempty(i1) & ~isempty(i2)
    % The current generator involves two of our substrings.
    % Find the position of all sub-strings in p.
    pos = find(ismember(p,s));
    % Of the substrings, find the order of the one we just switched.
    % This gives the unsigned generator for the subbraid.
    sgen = find(p(pos) == s(i1));
    % Restore sign and append to list.
    bs = [bs sign(b.word(i))*sgen];
  end
  p([gen gen+1]) = p([gen+1 gen]); % update permutation
end

bs = braidlab.braid(bs,nn);
