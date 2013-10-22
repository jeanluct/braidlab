function [S,rowind]=sortrows(A,cols)
% SORTROWS - sorts the rows of an array
%
% Usage: S=sortrows(A)
%        S=sortrows(A,cols)
%        [S,rowind]=sortrows(...)
%
% Intended for use with John D'Errico's Variable Precision Integer toolbox
% but it works with ordinary arrays and should work with any array types
% for which "sort" and "==" are defined.
%
% See the help for the built-in sortrows function.

% Author:
%   Ben Petschel 20/7/2009
% Change history:
%   20/7/2009: initial release


if nargin<2,
  cols=1:size(A,2);
end;

if isempty(A),
  S=A;
  return;
else
  sortlist={1:size(A,1),1}; % row numbers to sort using column
  rowind=1:size(A,1); % row indexes of final sort
end;


while ~isempty(sortlist),
  thissort=sortlist{end,1};
  i=sortlist{end,2};
  sortlist=sortlist(1:end-1,:);
  % sort rows using cols(i) according to sign
  if cols(i)>0,
    [s,ind]=sort(A(rowind(thissort),cols(i)));
  else
    [s,ind]=sort(A(rowind(thissort),-cols(i)),'descend');
  end;
  rowind(thissort)=rowind(thissort(ind));
  % now see which rows need to be sorted further
  if i<numel(cols),
    j=1;
    for k=2:numel(s),
      if s(k)~=s(j),
        % reached the end of an identical list, so process (j:k-1)
        if j<k-1,
          % two or more elements are equal, so sort them later
          sortlist=[sortlist;{thissort(j:k-1),i+1}];
        end;
        j=k;
      elseif k==numel(s) && j<k,
        sortlist=[sortlist;{thissort(j:k),i+1}];
      end;
    end;
  end;
end;
S=A(rowind,:);

end % function vpi/sortrows(...)

