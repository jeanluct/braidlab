function b = hironakakin(m,n)
%HIRONAKAKIN   Braid from Hironaka & Kin's family.
%   B = HIRONAKAKIN(M,N) returns a member of the Hironaka & Kin family of
%   braids on m+n+1 strings:
%
%     sigma(m,n) = s(1) s(2) ... s(m) s(m) ... s(1) s(1) ... s(m+n)
%
%   B = HIRONAKAKIN(N) for N odd returns HIRONAKAKIN((N-3)/2,(N+1)/2), the
%   braid which is thought to minimize the entropy on the disk with an odd
%   number N of punctures (N>3).  This is useful for checking the
%   "worst-case scenario" for computing a positive entropy.  For large N,
%   the entropy of this braid is bounded from above by
%   log(2+sqrt(3))/((N-1)/2).
%
%   B = HIRONAKAKIN(N) for N even returns HIRONAKAKIN((N+2)/2,(N-4)/2),
%   which is pseudo-Anosov but does not minimize entropy for even N.
%
%   References:
%
%   E. Hironaka and E. Kin, "A family of pseudo-Anosov braids with small
%   dilatation," Alg. Geom. Topology 6 (2006), 699-738.
%
%   E. Lanneau and J.-L. Thiffeault, "On the minimum dilatation of braids on
%   punctured discs," Geometriae Dedicata 152 (2011), 165-182.
%
%   See also BRAID, BRAID.ENTROPY.

if nargin < 2
  if m < 5
    error('BRAIDLAD:hironakakin:badarg','Need at least five strings.')
  end
  if mod(m,2) == 1
    n = (m+1)/2;
    m = (m-3)/2;
  else
    n = (m+2)/2;
    m = (m-4)/2;
  end
end

N = m+n+1;

b = braidlab.braid([1:m m:-1:1 1:N-1],N);
