function plot_mod(varargin)
%PLOT   Plot a loop.
%   PLOT(L,COLOR,X,PRAD) plots a representative of the equivalence class
%   define by the loop L.  COLOR may be speficied optionally, as well as the
%   position X of the punctures (default integers).  strings. Position of
%   the punctures can also be selected by inputing their positions as X.
%   The default is to have them at integer values along the x-axis.  The
%   puncture radius can be set with PRAD, otherwise the code selects the
%   best size for a given loop.
%
%   This is a method for the LOOP class.
%   See also LOOP.

%% List of option names that can be used

optionNames = [
    'LineColor       '
    'LineStyle       '
    'LineWidth       '
    'PunctureColor   '
    'PunctureSize    '
    'PuncturePosition'
    ];

names = lower(optionNames);
m = size(names,1);

%% Creation of the options structure

options = [];

for j = 1:m
  options.(deblank(optionNames(j,:))) = [];
end

%% Checking the number of input arguments is valid

% Must be of the form L then option name then option value

if rem(nargin,2) ~= 1
  error(message('BRAIDLAB:loop:plot:ArgNameValueMismatch',...
                'Number of inputs must be odd'));
end

%% Assigning input options

L = varargin{1};

if ~isscalar(L)
  error('BRAIDLAB:loop:plot','Can only plot scalar loop, not array of loops.');
end

i = 2;

val = 0;

while i <= nargin
  arg = varargin{i};

  if ~val
    if ~ischar(arg)
      error(message('BRAIDLAB:loop:plot:NoPropName', i));
    end

    lowArg = lower(arg);
    j = strmatch(lowArg,names);
    if isempty(j)                       % if no matches
      error(message('BRAIDLAB:loop:plot:InvalidPropName', arg));
    elseif length(j) > 1                % if more than one match
      % Check for any exact matches (in case any names are subsets of others)
      k = strmatch(lowArg,names,'exact');
      if length(k) == 1
        j = k;
      else
            matches = deblank(optionNames(j(1),:));
        for k = j(2:length(j))'
                matches = [matches ', ' deblank(optionNames(k,:))]; %#ok<AGROW>
        end
            error(message('BRAIDLAB:loop:plot:AmbiguousPropName',arg,matches));
      end
    end
    val = 1;                      % we expect a value next

  else
    options.(deblank(optionNames(j,:))) = arg;
    val = 0;

  end
  i = i + 1;
end

if isempty(options.LineColor);  options.LineColor = 'b'; end
if isempty(options.LineStyle);  options.LineStyle = '-'; end
if isempty(options.LineWidth);  options.LineWidth = 2; end
if isempty(options.PunctureColor); options.PunctureColor = 'r'; end


%% Set the coordinates of the loop

[a,b] = L.ab;
n = L.n;

% Convert Dynnikov coding to intersection numbers.
[mu,nu] = L.intersec;

% Extend the coordinates.
B = [-nu(1)/2 b nu(end)/2];
% A = [0 a 0];

% Convert to older P,M,N notation.
M = [nu(1)/2 mu(2*(1:(n-2))-1) nu(n-1)/2];
N = [nu(1)/2 mu(2*(1:(n-2))) nu(n-1)/2];
b = B;

%% Set the position of the punctures

if isempty(options.PuncturePosition);
    options.PuncturePosition = [(1:n)' 0*(1:n)'];
end

X = options.PuncturePosition;

if n ~= length(X)
  error('BRAIDLAB:loop:badlen','Length of X does not match loop.')
end

Xs = sortrows(X);

d =  hypot(diff(Xs(:,1)),diff(Xs(:,2)));

%%

% The gap between lines.
% (clarify: gap vs pgap?)
% TODO: Keep punctures same size (need special gap near x-axis).
gap = zeros(size(d));
for i = 1:n-1
  gap(i) = min(d(i)/M(i),d(i)/N(i))*.7;
end
pgap = zeros(n,1);
pgap(1) = gap(1);
pgap(end) = gap(end);
for i = 2:n-1
  pgap(i) = min(gap(i),gap(i-1));
end
pgap = min(pgap)/2+zeros(n,1);

if isempty(options.PunctureSize);
    options.PunctureSize = .15*min(gap);
end

prad = options.PunctureSize;

if prad > min(gap)
  warning('BRAIDLAB:loop:badrad', ...
        ['Puncture radius is too large.  For this loop the value' ...
         'can''t exceed %f.'],min(gap))
     prad = .15*min(gap);
end

%% Identify hold state of the current figure

if ishold
  holdstate = true;
else
  holdstate = false;
  clf reset
end

%%  Draw punctures.

for p = 1:n
  xx = linspace(-prad,prad,100);
  yy1 = sqrt(prad^2 - xx.^2);
  yy2 = -sqrt(prad^2 - xx(end:-1:1).^2);
  col = 'r-';
  patch(Xs(p,1)+[xx xx(end:-1:1)],Xs(p,2)+[yy1 yy2],options.PunctureColor)
  hold on
end

%% Draw semicircles.

for p = 1:n
  if p == n
    nl = M(n);
  else
    nl = b(p);
  end
  x = p;
  for sc = 1:abs(nl)
    rad = sc*pgap(p);
    xx = sign(nl)*linspace(0,rad,50);
    yy1 = sqrt(rad^2 - xx.^2);
    yy2 = -sqrt(rad^2 - xx(end:-1:1).^2);
    plot(Xs(p,1)+[xx xx(end:-1:1)],Xs(p,2)+[yy1 yy2],options.LineColor,'LineWidth',options.LineWidth,'LineStyle',options.LineStyle)
  end
end

%%  Draw the upper part of the loop.

for p = 1:n-1
  x = p;

  % How many right-semicircles (b>0) around this puncture?
  if p == 1
    nr = 0;
  else
    nr = max(b(p),0);
  end
  tojoin = M(p)-nr;

  if tojoin > 0
    % How many left-semicircles (b<0) around the next puncture?
    if p < n-1
      nl = -min(b(p+1),0);
    else
      nl = 0;
    end
    % We can't joint to these left-facing loops from the left.
    tojoinup = M(p+1)-nl;
    tojoindown = max(tojoin-tojoinup,0);
    %keyboard
    % The lines that join downwards.
    for s = 1:tojoindown
      y1 = pgap(p)*(nr+s)+Xs(p,2);
      y2 = -pgap(p+1)*(nl-s+tojoindown+1)+Xs(p+1,2);
      plot([Xs(p,1) Xs(p+1,1)],[y1 y2],options.LineColor,'LineWidth',options.LineWidth,'LineStyle',options.LineStyle)
    end
    % The lines that join upwards (on the same side).
    for s = tojoindown+1:tojoin
      y1 = pgap(p)*(nr+s)+Xs(p,2);
      y2 = pgap(p+1)*(nl+s - (tojoin-tojoinup))+Xs(p+1,2);
      %if y2 <= gap*nl; y2 = -gap*(nl+3-s); end
      plot([Xs(p,1) Xs(p+1,1)],[y1 y2],options.LineColor,'LineWidth',options.LineWidth,'LineStyle',options.LineStyle)
    end
  end
end

%% Draw lower segments of the loop

for p = 1:n-1
  x = p;

  % How many right-semicircles (b>0) around this puncture?
  if p == 1
    nr = 0;
  else
    nr = max(b(p),0);
  end
  tojoin = N(p)-nr;

  if tojoin > 0
    % How many left-semicircles (b<0) around the next puncture?
    if p < n-1
      nl = -min(b(p+1),0);
    else
      nl = 0;
    end
    % We can't joint to these left-facing loops from the left.
    tojoindown = N(p+1)-nl;
    tojoinup = max(tojoin-tojoindown,0);
    % The lines that join upwards.
    for s = 1:tojoinup
      y1 = -pgap(p)*(nr+s)+Xs(p,2);
      y2 = pgap(p+1)*(nl-s+tojoinup+1)+Xs(p+1,2);
      plot([Xs(p,1) Xs(p+1,1)],[y1 y2],options.LineColor,...
	   'LineWidth',options.LineWidth,'LineStyle',options.LineStyle)
    end
    % The lines that join downwards (on the same side).
    for s = tojoinup+1:tojoin
      y1 = -pgap(p)*(nr+s)+Xs(p,2);
      y2 = -pgap(p+1)*(nl+s - (tojoin-tojoindown))+Xs(p+1,2);
      plot([Xs(p,1) Xs(p+1,1)],[y1 y2],options.LineColor,...
	   'LineWidth',options.LineWidth,'LineStyle',options.LineStyle)
    end
  end
end

if ~holdstate
  hold off
  axis equal
  axis off
end
