% Check quality and speed of convergence of entropy for difficult braids.
% Goal is to achieve near machine precision.

% The predicted number of iterations matches the numerics fairly well,
% showing that the power iteration is working as expected.  There's not
% much room for improvement unless we somehow introduce a dynamic shift.

global BRAIDLAB_debuglvl
BRAIDLAB_debuglvl = 1;

n = 78;
tol = 1e-15;

% Predict the number of iterations from the spectral gap between the
% first two roots.
r = psiroots(n);
Niter = ceil(-log10(tol) / log10(abs(r(1)/r(2))));
ee = log(abs(r(1)));
fprintf('Predict %d iterations needed\n',Niter)

b = braidlab.braid('psi',n);  % low entropy braid

% For train tracks, the low entropy actually helps the method.  But the
% iterative method is better for high entropy.
%
% However, the train track method fails for n>77, with the message 'Growth
% not decreasing in fold and minimum tolerance of 1.00e-14 reached.'
tic
try
  etr = entropy(b,'trains');
catch err
  if strcmp(err.identifier,'BRAIDLAB:braid:train_helper:notdecr')
    warning('Growth not decreasing... giving up on train tracks.')
  end
  etr = 0;
end
toc

% Now do the iteration method.  Takes a while, but can achieve machine
% precision!
tic
[e,u] = entropy(b,tol,Niter);
toc
fprintf('Predicted %d iterations\n',Niter)

fprintf('Error: iter=%e  train=%e\n',abs(e-ee),abs(etr-ee))

clear -global BRAIDLAB_debuglvl
