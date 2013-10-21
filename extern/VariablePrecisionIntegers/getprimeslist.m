function primeslist = getprimeslist
% loads the primeslist file, and decompresses it, returning the list of primes up to 2^26
% usage: primeslist = getprimeslist
%
% see also: createprimeslist, primes
%
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 7/22/09

% load the compressed form
load _primeslist_

% these are uint8 numbers, where I simply stored
% difference between consecutive primes as a uint8.
% this works, since the largest such difference was
% never more than 220 up to that point.
% The act of decompressing the list takes no more
% than a double and a cumsum.
primeslist = cumsum([2,double(primeslist)]);




