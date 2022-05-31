load('badtrain.mat')

class(b)
b2 = braid(b);  % convert to true braid

k = length(b2);

%b2.n
%max(abs(b2.word))

test = '1';

switch lower(test)
  case '1'
    tic; trn1 = train(b2); toc;
    tic; trn2 = train(b2); toc; % hangs
  case '2'
    % shorten braid to 220 generators
    b3 = braidlab.braid(b2.word(1:220));
    b3.n
    b3.length
    tic; trn1 = train(b3); toc;
    tic; trn2 = train(b3); toc; % does not hang!
  otherwise
    error
end
