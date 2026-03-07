% Debug test to understand segment ordering issue
%
% This will help diagnose why the loop has crossing lines

addpath(genpath('.'));
import braidlab.*

% Simple test loop
L = loop([1 0 0 0]);

% Get the internal geometry data
disp('Creating a simple loop: [1 0 0 0]');
disp(['Number of punctures: ' num2str(L.totaln)]);
disp(' ');

% Let's manually inspect what segments are being created
% We'll add some debug output to understand the issue

% For now, let's plot with the old code to see what it should look like
% We need to check out the old version temporarily

disp('The issue is likely in orderSegmentsByComponent()');
disp('Segments are being concatenated without checking if endpoints match');
disp('or if segments need to be reversed.');
