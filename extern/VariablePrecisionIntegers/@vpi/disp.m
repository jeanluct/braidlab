function expression = disp(INT)
% vpi/disp: Disp a vpi object
%
% arguments:
%  INT     - a vpi object
%
%
%  See also: display
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

Nint = numel(INT);
Isize = size(INT);

if Nint == 0
  % an empty array
  disp('   []')
elseif Nint > 1
  % an array with 2 or more elements
  
  % What is the shape of INT? A 3-d array
  % or more will be dumped out in order,
  % one element at a time.
  maxord = 1 + max(order(INT(:)));
  if (length(size(INT)) > 2) || ((maxord > 36) && (size(INT,2) > 1))
    % 3+ dimensions, or really large numbers in an array
    for i = 1:Nint
      % make a tag that identifies each element
      tag = 'vpi element: (';
      ind = i-1;
      for j = 1:length(Isize)
        [ind,k] = quotient(ind,Isize(j));
        if j == 1
          tag = [tag,num2str(k+1)]; %#ok
        else
          tag = [tag,',',num2str(k+1)]; %#ok
        end
      end
      tag = [tag,')']; %#ok
      disp(' ')
      disp(tag)
      disp(INT(i))
    end
  elseif size(INT,2) == 1
    % a column vector
    for i = 1:Nint
      disp(INT(i))
      if maxord > 72
        disp(' ')
      end
    end
  else
    % a row vector, or an array. How big are the numbers?
    Nord = order(INT);
    maxord = max(Nord(:));
    
    % they are small enough to dump out in columns
    ncols = min(Isize(2),floor(80/(maxord+4)));
    colsize = maxord+4;
    colindex = 1:ncols;
    
    % the while loop will grab ncols columns at a time
    while ~isempty(colindex)
      % just append the j'th column
      block = '';
      for j = colindex
        column_j = repmat(' ',Isize(1),colsize);
        % and insert each element as characters, one at a time
        for i = 1:Isize(1)
          expr = disp(INT(i,j));
          expr = [repmat(' ',1,colsize-length(expr)),expr]; %#ok
          column_j(i,:) = expr;
        end
        
        block = [block,column_j]; %#ok
      end
      
      if ncols < Isize(2)
        disp(' ')
        disp(['Columns ',num2str(colindex(1)),' through ',num2str(colindex(end))])
      end
      disp(block)
      
      % increment to the next block of columns
      colindex = colindex + ncols;
      colindex(colindex > Isize(2)) = [];
    end
  end
else
  % A scalar vpi
  
  % how many non-zero digits, in case of any
  % "leading" zeros
  n = find(INT.digits,1,'last');
  if isempty(n)
    n = 1;
  end
  
  % do we need a minus sign in front?
  if INT.sign>0
    % no
    expression = ['   ',sprintf('%1d',INT.digits(n:-1:1))];
  else
    % yes
    expression = ['  -',sprintf('%1d',INT.digits(n:-1:1))];
  end
  
  % is it longer than one line?
  pagewidth = 80;
  if n > pagewidth
    % wrap it to more than one line. First
    % append some blanks to the end if necessary.
    r = rem(length(expression),72);
    if r ~= 0
      expression = [expression,repmat(' ',1,72 - r)];
    end
    expression = reshape(expression,72,[])';
  end
  if nargout == 0
    disp(expression)
    clear expression
  end
end




