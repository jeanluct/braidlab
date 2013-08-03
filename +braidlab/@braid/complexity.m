function c = complexity(b)
%COMPLEXITY   Dynnikov-Wiest geometric complexity of a braid.
%   C = COMPLEXITY(B) returns the Dynnikov-Wiest complexity of a braid:
%
%     C(B) = log2|B.E| - log2|E|
%
%   where E is a canonical curve diagram, and |L| gives the number of
%   intersections of the curve diagram L with the real axis.
%
%   References:
%
%   I. A. Dynnikov and B. Wiest, "On the Complexity of Braids," 
%   Journal of the European Mathematical Society 9 (2007), 801-840.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.LOOPCOORDS, LOOP.INTAXIS.

E = braidlab.loop(b.n);
c = log2(intaxis(b*E)-2) - log2(intaxis(E)-2);
