function [loops, loopIndex, system_braid] = Step1_PairLoopModification(b)
%STEP1_PAIRLOOPMODIFICATION calculates a set of pair loops for a given
% braid and applies the braid.
%  DYN = STEP1_PAIRLOOPMODIFICATION(B) returns a set of loops which are the
%  result of applying the braid B to a set of pair-loops.  The
%  pair-loops are determined by the number of punctures in the system.

%% Convert the input b into a braid class object if it is not already

if isa(b,'braidlab.braid')
    system_braid = b;
else
    system_braid = braidlab.braid(b);
end

%% Compact the braid to accelerate action on the loops

system_braid = system_braid.compact;

%% Create pair-loops

% Calculate the Dynnikov coordinates for the loops which connect pairs of
% punctures.  Dyn_cell is a cell structure containing the Dynnikov
% coordinates for that cell.  Dyn is the list of Dynnikov coordinates and
% Dyn_ind is the list of indexes of punctures enclosed by the loop in the
% corresponding row in Dyn.

[pairLoops, loopIndex] = braidlab.lcs.p2ploop(system_braid.n);

%% Act on the pair-loops

% The generators are applied to the pair-loops.

loops = system_braid*pairLoops; 