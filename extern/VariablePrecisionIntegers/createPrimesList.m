function createPrimesList
% createPrimesList - For users of older matlab releases, this function will generate a compatible _primeslist_ file
% usage: createPrimesList
%
% Note that createPrimesList will take a half minute or so to run, but
% having done so, then it needs never run it again, as it will overwrite
% your _primeslist_ file in the @vpi directory. Thenceforth, users of vpi
% with older matlab releases will be able to use factor. factor actually
% will call createPrimesList automatically if it has a problem loading
% that file.
%
% see also: getprimeslist, primes
%
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 7/22/09


% get the path to the vpi directory
% we know that createPrimesList must live there
vpipath = which('createPrimesList');
vpipath = fileparts(vpipath);

% this is the full name (path included) of the
% _primeslist_ .mat file
primeslistfilename = fullfile(vpipath,'@vpi','_primeslist_.mat');

% create the primeslist variable
primeslist = primes(2^26);

% since no pair of primes are spaced farther
% apart than 220 in this range, we can compress
% the entire list by a simple diff then a uint8.
primeslist = uint8(diff(primeslist));

% and save it to the proper location
save(primeslistfilename,'primeslist')






