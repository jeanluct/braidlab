function M = update_rules_matrix(b,pn,N)

if nargin < 3, N = 2*b.n-2; end

n = N/2 + 2; % Maximum generator index for this loop size.

M = speye(N,N);

a0 = 0; b0 = N/2;

pos = @(x) x > 0; neg = @(x) x < 0;

maxpn = 5;
pn = reshape(pn,[length(b) maxpn]);

for j = 1:length(b)
  i = abs(b.word(j));
  T = speye(N,N);
  if b.word(j) > 0
    switch(i)
     case 1
      % pn(:,j,1) = sign(b(:,1));
      % pn(:,j,2) = sign(bp(:,1));
      %ap(:,1) = -b(:,1) + pos(a(:,1) + pos(b(:,1)));
      T(a0+1,b0+1) = -1 + pos(pn(j,1))*pos(pn(j,2));
      T(a0+1,a0+1) = pos(pn(j,2));
      %bp(:,1) = a(:,1) + pos(b(:,1));
      T(b0+1,a0+1) = 1;
      T(b0+1,b0+1) = pos(pn(j,1));
     case n-1
      % pn(:,j,1) = sign(b(:,n-2));
      % pn(:,j,2) = sign(bp(:,n-2));
      %ap(:,n-2) = -b(:,n-2) + neg(a(:,n-2) + neg(b(:,n-2)));
      T(a0+n-2,b0+n-2) = -1 + neg(pn(j,1))*neg(pn(j,2));
      T(a0+n-2,a0+n-2) = neg(pn(j,2));
      %bp(:,n-2) = a(:,n-2) + neg(b(:,n-2));
      T(b0+n-2,a0+n-2) = 1;
      T(b0+n-2,b0+n-2) = neg(pn(j,1));
     otherwise
      % pn(:,j,1) = sign(b(:,i));
      % pn(:,j,2) = sign(b(:,i-1));
      % pn(:,j,3) = sign(c);
      % pn(:,j,4) = sign(pos(b(:,i)) + c);
      % pn(:,j,5) = sign(neg(b(:,i-1)) - c);

      %c = a(:,i-1) - a(:,i) - pos(b(:,i)) + neg(b(:,i-1));
      c = pn(j,3);
      %ap(:,i-1) = a(:,i-1) - pos(b(:,i-1)) - pos(pos(b(:,i)) + c);
      T(a0+i-1,a0+i-1) = 1 - pos(pn(j,4)) * (1);
      T(a0+i-1,b0+i-1) = -pos(pn(j,2)) - pos(pn(j,4)) * (neg(pn(j,2)));
      T(a0+i-1,a0+i)   = -pos(pn(j,4)) * (-1);
      %bp(:,i-1) = b(:,i) + neg(c);
      T(b0+i-1,b0+i) = 1 + neg(c) * (-pos(pn(j,1)));
      T(b0+i-1,a0+i-1) = neg(c) * (1);
      T(b0+i-1,a0+i)   = neg(c) * (-1);
      T(b0+i-1,b0+i-1) = neg(c) * (neg(pn(j,2)));
      %ap(:,i) = a(:,i) - neg(b(:,i)) - neg(neg(b(:,i-1)) - c);
      T(a0+i,a0+i)   = 1 + neg(pn(j,5)) * (-1);
      T(a0+i,b0+i)   = -neg(pn(j,1)) + neg(pn(j,5)) * (-pos(pn(j,1)));
      T(a0+i,a0+i-1) = neg(pn(j,5)) * (1);
      %bp(:,i) = b(:,i-1) - neg(c);
      T(b0+i,b0+i-1) = 1 - neg(c) * (neg(pn(j,2)));
      T(b0+i,a0+i-1) = -neg(c) * (1);
      T(b0+i,a0+i)   = -neg(c) * (-1);
      T(b0+i,b0+i)   = -neg(c) * (-pos(pn(j,1)));
    end
  elseif b.word(j) < 0
    switch(i)
     case 1
      % pn(:,j,1) = sign(b(:,1));
      % pn(:,j,2) = sign(bp(:,1));
      %ap(:,1) = b(:,1) - pos(-a(:,1) + pos(b(:,1)));
      T(a0+1,b0+1) = 1 - pos(pn(j,2)) * (pos(pn(j,1)));
      T(a0+1,a0+1) = -pos(pn(j,2)) * (-1);
      %bp(:,1) = -a(:,1) + pos(b(:,1));
      T(b0+1,a0+1) = -1;
      T(b0+1,b0+1) = pos(pn(j,1));
     case n-1
      % pn(:,j,1) = sign(b(:,n-2));
      % pn(:,j,2) = sign(bp(:,n-2));
      %ap(:,n-2) = b(:,n-2) - neg(-a(:,n-2) + neg(b(:,n-2)));
      T(a0+n-2,b0+n-2) = 1 - neg(pn(j,2)) * (neg(pn(j,1)));
      T(a0+n-2,a0+n-2) = -neg(pn(j,2)) * (-1);
      %bp(:,n-2) = -a(:,n-2) + neg(b(:,n-2));
      T(b0+n-2,a0+n-2) = -1;
      T(b0+n-2,b0+n-2) = neg(pn(j,1));
     otherwise
      % pn(:,j,1) = sign(b(:,i));
      % pn(:,j,2) = sign(b(:,i-1));
      % pn(:,j,3) = sign(pos(b(:,i)) - d);
      % pn(:,j,4) = sign(d);
      % pn(:,j,5) = sign(neg(b(:,i-1)) + d);

      %d = a(:,i-1) - a(:,i) + pos(b(:,i)) - neg(b(:,i-1));
      d = pn(j,4);
      %ap(:,i-1) = a(:,i-1) + pos(b(:,i-1)) + pos(pos(b(:,i)) - d);
      T(a0+i-1,a0+i-1) = 1 + pos(pn(j,3)) * -(1);
      T(a0+i-1,b0+i-1) = pos(pn(j,2)) + pos(pn(j,3)) * -(-neg(pn(j,2)));
      T(a0+i-1,a0+i)   = pos(pn(j,3)) * -(-1);
      %bp(:,i-1) = b(:,i) - pos(d);
      T(b0+i-1,b0+i)   = 1 - pos(d) * (pos(pn(j,1)));
      T(b0+i-1,a0+i-1) = -pos(d) * (1);
      T(b0+i-1,a0+i)   = -pos(d) * (-1);
      T(b0+i-1,b0+i-1) = -pos(d) * (-neg(pn(j,2)));
      %ap(:,i) = a(:,i) + neg(b(:,i)) + neg(neg(b(:,i-1)) + d);
      T(a0+i,a0+i)   = 1 + neg(pn(j,5)) * (-1);
      T(a0+i,b0+i)   = neg(pn(j,1)) + neg(pn(j,5)) * (pos(pn(j,1)));
      T(a0+i,a0+i-1) = neg(pn(j,5)) * (1);
      %bp(:,i) = b(:,i-1) + pos(d);
      T(b0+i,b0+i-1) = 1 + pos(d) * (-neg(pn(j,2)));
      T(b0+i,a0+i-1) = pos(d) * (1);
      T(b0+i,a0+i)   = pos(d) * (-1);
      T(b0+i,b0+i)   = pos(d) * (pos(pn(j,1)));
    end
  end
  M = T*M;
end
