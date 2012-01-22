function [loops loopIndex] = Step1_PairLoopModification(b)

%STEP1_PAIRLOOPMODIFICATION calculates a set of pair loops for a given
% braid and applies the braid.
%  DYN = STEP1_PAIRLOOPMODIFICATION(B) returns a set of loops which are the
%  result of applying the braid B to a set of pair-loops.  The
%  pair-loops are determined by the number of punctures in the system.

% Convert the input b into an a braid class object if it is not already a
% braid
if isa(b,'braidlab.braid')
    braid = b;
else
    braid = braidlab.braid(b);
end

% Calculate the Dynnikov coordinates for the loops which connect pairs of
% punctures.  Dyn_cell is a cell structure containing the Dynnikov
% coordinates for that cell.  Dyn is the list of Dynnikov coordinates and
% Dyn_ind is the list of indexes of punctures enclosed by the loop in the
% corresponding row in Dyn.

[pairLoops, loopIndex] = p2ploop(braid.n);

% The generators are applied to the pair-loops.

loops = b*pairLoops; 