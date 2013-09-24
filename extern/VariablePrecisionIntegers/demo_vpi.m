% This demo file provides some examples of how one might use
% the vpi tools in this toolbox.
%
% I originally wrote the vpi tools to play with large integers, but I did
% not have the symbolic toolbox. The beauty of matlab is that the lack
% of a tool is no problem. Just write it! This entire toolbox took me only
% a relatively short time (a man day or so) to write. I have spent more time
% documenting it and cleaning it up to put it on the FEX than I did
% writing the code. Since the first version of course, these tools have
% been enhanced many times, with many new capabilities added.
%
% Author: John D'Errico
%
% e-mail: woodchips@rochester.rr.com
%
% Release: 5.0
%
% Release date: 3/5/09

%% The creator for vpi objects is vpi
help vpi

%% Numeric variables that are no more than 2^53-1
% Only scalar variables need apply. Matrices and vectors would not be
% terribly difficult to implement, but I've not done so.
INT = vpi
INT = vpi(23)

%% For very large numbers > 2^53-1, use a character string of digits
% Remember that we can not represent numbers larger than the exactly
% as a double precision number, so a digit string is the simple
% solution.
INT = vpi('1234567890123456789012345678901')

%% They are easily converted to a structure
struct(INT)

%% Fast arithmetic manipulation of vpi numbers
INT = vpi(2999);
INT + 5
INT*123456789 - 3

%% Large powers are easy enough
INT^963

%% Modulo arithmetic - a test of Fermat's little theorem
% How about Fermat's little theorem? It states that, for prime numbers p,
%
%   mod(a^p - a,p) == 0

%%
% 17 is clearly a prime number
p = 17;
%%
% Pick some arbitrary integer for a
a = vpi('5454677099790847579707977857');

%%
% a^p-a is a moderately big number
a^p-a

%%
% but according to Fermat, the mod should be zero
mod(a^p - a,p)

%% Arithmetic operations are pretty fast
% Obviously, there are limits to any computation. So if you want to compute
% with numbers that have many millions of digits, vpi might not be up to the
% task. But reasonably large numbers are trivial to work with.
%
% For example, a moderately large factorial, with 158 digits
tic,INT = factorial(vpi(100));toc
INT

%%
% Square that number
tic,INT = INT*INT;toc

%%
% And add 1 to the result
tic,INT = INT + 1;toc

%% Work with arrays of vpi numbers
A = vpi(17);
B = A.^(1:10)
%%
% Compute the sum
sum(B)

%%
% Or the product
C = prod(B)

%%
% Of course, we know that this product is just the product of sum(1:10)==55
% powers of 17.
sum(1:10)

%%
% Taking the 55th root of C should recover 17, exactly.
nthroot(C,55)

%% 
% A fun problem was to find a pair of numbers a and b,
% such that a^b ends in the final digits 000111222333444555666777888999.
a = vpi('5243565694659215822369469611294962999');
b = 3;
a^b

%% Relational operators
% All of the standard operators are provided, <, >, <=, >=, ==, ~=, as well
% as a few others like isequal and iseven.
a = vpi(2);
b = vpi(3);

%%
% ==
a*b == 6

%% 
% >
a > b

%% 
% <=
a <= 2

%%
% Test for an even number?
iseven(vpi(2)^127)

%% Concatenation using []
[3 2]*[a,b;b,a]*[a^3 b^4]'

%% Large Fibonacci numbers
% Fibonacci numbers can be fun to play with. 
% 
% <http://en.wikipedia.org/wiki/Fibonacci_number |Fibonacci numbers|>
%
% By the way, cell arrays would be one way to store vpi objects
% when you have many of them to store. But better is to use an array
% of vpi numbers. You can work with those arrays much as with any
% regular number in MATLAB. Don't forget to preallocate space for
% these arrays rather than growing them one element at a time.
n = 20;
F = repmat(vpi(0),1,n);
F(1) = vpi(1);
F(2) = vpi(1);
for i = 3:n
  F(i) = F(i-1) + F(i-2);
end
F

%%
% Better is to use the fibonacci function. It is optimized to compute
% only a few Fibonacci (also Lucas) numbers, or the entire sequence
% quite efficiently. Thus we can compute the 5000th Fibonacci number
% along with the 5000th Lucas number in a small fraction of one second.
tic,
[F_5000,L_5000] = fibonacci(5000);
toc
F_5000
L_5000

%%
% Or compute every 10th fibonacci number
n = (0:10:100)';
[n,fibonacci(n)]

%%
% Or the first 3000 members of the sequence
F = fibonacci(1:3000);

%%
% What fun things can we see from this sequence? What for example, is the
% distribution of trailing (units) digits? See that the odd trailing digits 
% are twice as likely to occur. This is easy to understand when you
% consider that the sum of an even plus an odd number is odd, but that the
% sum of two numbers with the same parity is even. Can there ever be two
% consecutive even numbers in the Fibonacci sequence?
D = cell2mat(trailingdigit(F,1));
hist(D,100)
title 'Histogram of trailing (lowest order) Fibonacci digits'

%%
% How about the other digits of the Fibonacci numbers? Are they uniformly
% distributed? Look at the tens digits.
sub1 = @(x) x(1);
D = cellfun(@(X) sub1(X),trailingdigit(F(7:end),2));
hist(D,100)
title 'Histogram of the tens digits of the Fibonacci numbers'

%%
% Or the third digits (hundreds).
D = cellfun(@(X) sub1(X),trailingdigit(F(12:end),3));
hist(D,100)
title 'Histogram of the hundreds digits of the Fibonacci numbers'

%%
% High order (leading) digits are also interesting, perhaps more so than
% the low order (trailing) digits. The distribution of
% the leading digits will be roughly logarithmic, as predicted by 
% <http://math.suite101.com/article.cfm/benfords_law |Benford's law|>
D = cell2mat(leadingdigit(F,1));
hist(D,100)
title 'Histogram of leading (highest order) Fibonacci digits'

%%
% The second highest order digit?
sub2 = @(x) x(2);
D = cellfun(@(X) sub2(X),leadingdigit(F(7:end),2));
hist(D,100)
title 'Histogram of the second highest order Fibonacci digits'

%%
% Benford's law is somewhat paradoxical in how it works but it is logical
% in the extreme once you think carefully about it. Recall that the
% leading digits had a logarithmic distribution, so that the digit 1
% appeared most frequently. Suppose we were to double all of those numbers?
% The 1's now become 2, or 3. On the other hand, any number that previously
% started with any of {5,6,7,8,9}, now starts with a 1. 
D = cell2mat(leadingdigit(2*F,1));
hist(D,100)
title 'Did doubling the Fibbonacci numbers change the distribution of their leading digits?'

%% 
% We can also compute the modulus of immensely large Fibonacci numbers, and
% do so efficiently. For example, how large is the number fibonacci(17^17)?
%
% Using Binet's formula, and discounting the smaller term,
% we expect to see roughly 1.7e20 digits in that number.
phi = (1+sqrt(5))/2;
n*log10(phi) - log10(sqrt(5))
%%
% However, if we only wanted, say the trailing 80 digits of that number,
% it is efficiently computed. This is far too
% large of a number to compute, even using the vpi fibonacci function.
tic,[Fn,Ln] = modfibonacci(vpi(17)^17,vpi(10)^80);toc
Fn
Ln

%% Conversion from long binary to VPI
% Either from a binary character string
INT = bin2vpi('10101011110111101011101100011111001101110110110101101111111111101')
%% 
% or from a boolean numeric vector, here with 250 binary digits
B = round(rand(1,250))

%%
% There should be roughly log10(2^250) = 75.25 decimal digits
INT = bin2vpi(B)
struct(INT)

%% Conversion to written English numbers
N = vpi(17)^7
vpi2english(N)

%%
% Numbers with up to 300 digits can be written out in this form
vpi2english(vpi('3215000000000000000000000000023000000000000010002118'))

%% Numerical operations on a vpi number
% Some factoring operations need an approximate square root, the
% largest integer that is <= the true square root of the number.
%
% See that when applied to a perfect square, sqrt is exact.
N = vpi('454652364568754565342346');
NN = N*N;

%%
% This result must be exactly zero
sqrt(NN) - N

%%
% When applied to a general, non-perfectly square vpi number, the sqrt
% has the property that it is the largest vpi such that sqrt(N)^2 <= N
R = sqrt(N)

%%
% Test that R has the required property. Both of these tests must be true.
R^2 <= N
N < (R+1)^2

%%
% sqrt returns a second argument for vpi numbers. Since many numbers will
% not have an exact square root, the remainder for the square root will be
% returned. As it turns out, this is a simple way to test to see if a
% number is a perfect square.
[root,excess] = sqrt(N);
excess

%%
% But see that when the argument was a perfect square, sqrt returns that
% second argument as 0.
NN = N*N;
[root,excess] = sqrt(NN);
excess

%%
% was NN a perfect square?
excess == 0

%% n'th root, as the integer part of nthroot(K,n)
% Other roots are also provided, nthroot of a vpi
% number generates the integer part of that root,
% along with the "remainder".
K = vpi(2)^1000

%%
% R is the root, and excess is the extent that R^n falls short of K.
[R,excess] = nthroot(K,78)

%%
% This must be zero, by definition
K - (R^78 + excess)

%%
% See that R^2 <= K <= (R+1)^2
R^78 <= K
K <= (R+1)^78
 
%%
% nthroot should be correct down to the last integer digit of its result.
%
% Subtract 1 from a large power of 3.
K = vpi(3)^600 - 1
R = nthroot(K,3)

%%
% This difference should be exactly 1.
vpi(3)^200 - R

%% Trancendental functions, exp and log of a vpi number
% For fun, I decided to provide a function for exp(x), when x is a vpi
% number. Of course, I only return the integer portion of that number.
%
% For example, as a real number, exp(10) = 22026.4657948067. The vpi
% version of exp returns only the integer part of that number.
exp(vpi(10))

%%
% For larger inputs, it is more difficult to compute all of the digits,
% since matlab only provides double precision floating point numbers.
% The built-in exp(x) returns a real number on double precision input
% as long as x <= 709. But, you only get about 16 digits.
exp(709)

%%
% When x is a vpi number, exp returns all digits of the integer part.
exp(vpi(709))

%%
% Worse, for x > 709, MATLAB's floating point exponential yields inf.
exp(710)

%%
% The vpi version of exp has no such problem.
exp(vpi(710))

%%
% Even for much larger inputs, we can get all the digits to the left of the
% decimal point.
exp(vpi(10000))

%%
% Logs are available too, but there is no reason to compute the log
% as a vpi, instead log, log10, and log2 all return double precision
% numbers when applied to a vpi number.
log10(vpi(10)^1000)
log10(vpi(2))
log2(2^53)

%% Compute nchoosek(n,k) exactly for large numbers
n = 14565;
k = 3002;
tic,INT = nchoosek(vpi(n),k);toc
INT

%%
% Can we verify the above result is correct? One simple test is to compare
% the log of INT with that predicted by gammaln. Both of these results
% should be the same.
gammaln(n+1) - gammaln(k+1) - gammaln(n-k+1)
log(INT)

%% A pair of formulaic test cases
% As a test, the sum over k of the binomial coefficients nchoosek(N,k) is 2^N
N = 200;
S = 0;
for k = 0:N
  S = S + nchoosek(vpi(N),k);
end

%%
% The sum was:
S

%%
% Compare it to 2^N
vpi(2)^N

%%
% Another formulaic test case: sum{ k*nchoosek(N,k) } = N*2^(N-1)
N = 150;
S = 0;
for k = 1:N
  S = S + k*nchoosek(vpi(N),k);
end

%%
% The sum was:
S

%%
% Compare it to N*2^(N-1)
N*vpi(2)^(N-1)

%% Compute the factors of a HUGE binomial coefficient
% Sometimes, you might want to compute a REALLY HUGE binomial coefficient.
% While vpi/nchoosek will do nicely for a few thousand digits, how about
% something with millions of digits? Itturns out that computation of the
% factors of that coefficient is actually rather easy (easy is always
% relative measure). I wrote binomfactors to solve the problem.
tic,[facs,count,lognck] = binomfactors(20000000,5000000);toc

%%
% The result has a few million digits.
lognck/log(10)

%%
% as well as a few hundred thousand distinct factors
numel(facs)

%% Compute all of the factors of a large factorial
% For other purposes, one might wish to work with really large factorials,
% without resorting directly to logs and gammln.
[facs,freps] = factorialfactors(1000)

%% All of the factors of a MASSIVELY large factorial, in only a few seconds.
tic
[facs,freps] = factorialfactors(20000000);
toc

%%
% Just how large is that number? It would have over 137 million digits,
% had we computed the actual number itself.
sum(log10(facs).*freps)

%%
% We can verify that result by resorting to gammaln
gammaln(20000001)/log(10)

%% The GCD of two numbers
% The built-in gcd function
gcd(144,60)

%%
% gcd for vpi gives the same result
gcd(vpi(144),60)

%%
% But for very large numbers...
int1 = vpi('1235357889667342221345796785463432123456789979096348363656484858');
int2 = nchoosek(vpi(100),50)

%%
% gcd still works very nicely
tic,D = gcd(int1,int2);toc
D

%% The GCD of a set of numbers
gcd(vpi(144),60,192,720)

%% The LCM of two large numbers
lcm(vpi('1234523565487151848'),vpi('1234433265364467'))

%% The LCM of a set of many numbers
lcm(vpi(2),3,4,5,6,7,8,9,10,11,12,13,14,15,16)

%% Use of these tools for primality testing
% Some tests for primality of the number n require you to compute
% mod(a^d,n). However, to exponentiate and then compute the
% mod is inefficient. Better is to use powermod, which computes 
% the result in far less time. For example, even the simple
% computation of mod(123^200,497) takes about a second on my
% old machine. (If you are really serious about primality testing,
% this toolbox may not be the place to do your work anyway. It
% might be a good tool to learn something though.)
tic,M = mod(vpi(123)^200,497);toc

%%
% See that powermod is far more efficient here
tic,M = powermod(vpi(123),200,497);toc

%% Testing a large integer for primeness
% Use the isprime function for such a test. I've implemented several
% different methods that will give a good suggestion about whether a number
% is prime. One of these methods uses Fermat's little theorem. It tells us
% that is P is a prime, then for any integer a, that mod(a^(p-1),p) == 1.
% However, when p is not prime,that same formula will often yield some
% arbitrary other number, but rarely will you see 1. So the Fermat test
% for primality tries a random value of a, and looks to see if we get 1. If
% the result is 1, then we have a strong indication that the original
% number was prime. For example, is the number 271 prime? Pick some
% arbitrary value of a, say a = 12.
%
% Use powermod to compute mod(a^(p-1),p)
powermod(vpi(12),270,271)

%%
% It was 1, so 12 is called a witness for 271 being prime. This suggests strongly
% that the original P was prime, but it does not absolutely prove that fact.
% We can check some other values of a to make us more certain.
powermod(vpi(27),270,271)
powermod(vpi(182),270,271)

%%
% Of course, 271 is small enough that we can easily test it via the built-in
% function isprime.
isprime(271)

%%
% Try another number. For example 221. Is it prime? In fact, is is
% composite. 221 = 13*17
factor(221)

%%
% Apply the Fermat test.
powermod(vpi(27),220,221)
powermod(vpi(182),220,221)

%%
% Very good. We see that two different values of a predict that 221 is
% composite, since the Fermat test yielded other values than 1. Had we
% tried this test with a = 38, we would have found something interesting.
powermod(vpi(38),220,221)

%%
% Thus 38 is a Fermat "liar", a number that fails to indicate that 221 was
% composite. It suggested wrongly that 221 was indeed prime. Yet if we try a
% few different values of a, most of them suggest 221 is composite.
% Whenever these tests predict that a number is composite, they are always
% 100% correct. It is only the false positive cases where "liars" exist,
% rarely predicting that a number is prime when it was not so.
%
% The function isprime does this work for us, although for small enough
% vpi inputs, it just calls the built-in version of isprime. The limit
% for the built-in isprime is 2^32. Numbers this large have a low
% probability that they are Fermat liars. so two tests will generally
% be sufficent.
P = vpi(2)^37 - 1;
%%
% Tell it to do 3 independent tests. The result will be a compilation of
% all three tests.
ntests = 3;
isp = isprime(P,ntests)

%%
% Is P truly prime? No. So the Fermat test was correct in its prediction.
% The vpi version of factor will give us the factors though. 
factor(P)

%% Mersenne primes
% We know that for some values of p, when p is prime, that 2^p-1 is a
% Mersenne prime. 
% 
% <http://en.wikipedia.org/wiki/Mersenne_prime |Mersenne primes|>
%
% <http://primes.utm.edu/mersenne/ |History|>
%
% <http://mathworld.wolfram.com/Lucas-LehmerTest.html |Lucas-Lehmer|>
%
% For example, one such Mersenne prime is 
p = vpi(2)^61 - 1

%%
% A simple test to apply that is known to be 100% accurate
% for Mersenne primes is the Lucas-Lehmer test. I'll try it
% here for 2^127-1.
vpi(2)^127 - 1

%%
% Apply the Lucas-Lehmer test for this value of p
[tf,S] = mersenne(127);
tf

% 2^127-1 is prime IFF S{end} is zero
S(end)

%% Twin primes?
% {3,5}, {5,7}, {11, 13}, and {17, 19} are all twin prime pairs. Can we
% generate a large pair of twin primes? This uses a cute little trick that
% can generate large twin prime pairs with some efficiency.
%
% Start with a large even number that is a product of many distinct small primes.
% This will do nicely:
N = vpi(2)*3*5*7*11*13*17*19*23*29*31*37*41*43*47*53

%%
% Use some small twin prime pairs that were not factors of N.
tp = {[59,61],[71,73],[101,103],[107,109], ...
      [137,139],[149,151],[179,181],[191,193]};
for i = 1:length(tp)
  res = [isprime(N - tp{i}(2),1) isprime(N - tp{i}(1),1)];
  if all(res)
    disp('Twin prime pair found')
    disp(N - tp{i}(2))
    disp(N - tp{i}(1))
  end
end

%% Factoring moderately large integers
% The built-in factor is limited to no more than 2^32, so any number beyond
% that cannot be directly factored. One can modify the built-in factor
% to accept all numbers up to 2^53-1 in theory, but this is still pretty
% limited since 2^53 = 9.0072e+15. Larger numbers than that are easily
% factored using the vpi version of factor, which uses Pollard's rho
% method. For example, here are a few test cases:
%

%%
% A number with 14 digits
f = factor(vpi('11111111111111'))
%%
% Show that these were the correct factors
prod(f)

%%
% A number with 15 digits
f = factor(vpi('111111111111111'))

%%
% A number with 16 digits
f = factor(vpi('1111111111111111'))

%%
% A number with 17 digits. Note that this number is the product of
% only a pair of quite large primes, but even here factor
% will succeed. I've intentionally set the maximum number of iterations
% low to force it not to try too hard with its main
% algorithm before resorting to a secondary approach
% that will succeed here.
f = factor(vpi('11111111111111111'),20)

%%
% A number with 18 digits
f = factor(vpi('111111111111111111'))

%%
% A number with 19 digits
f = factor(vpi('1111111111111111111'))

%%
% A number with 20 digits
f = factor(vpi('11111111111111111111'))

%%
% A number with 21 digits
f = factor(vpi('111111111111111111111'))

%%
% A number with 30 digits
f = factor(vpi('111111111111111111111111111111'))

%%
% Numbers with two large prime factors are the most difficult to factor in general.
p = primes(1000);
int = prod(vpi(p(9:9:end)))

%%
% int has 46 decimal digits, but is not that terribly difficult to factor.
f = factor(int)

%% List all quadratic residues of a number
quadraticresidues(17)

%%
% See that quadraticresidues did indeed find all possible residues of 17.
unique(mod((0:16).^2,17))

%% The Legendre symbol (a/p)
% The 
% <http://en.wikipedia.org/wiki/Legendre_symbol |Legendre symbol|>
% is a useful function in number theory when working with quadratic
% residues, along with its close cousin, the 
% <http://en.wikipedia.org/wiki/Jacobi_symbol |Jacobi symbol|>
% , which applies when p is composite. These functions have uses in
% the areas of computational number theory, prime number testing and
% integer factorization.
p = 17;
%%
% When a is a multiple of p, the legendre symbol is zero
legendresymbol(51,p)

%%
% When a is not a quadratic residue, the legendre symbol will be -1
legendresymbol(3,p)

%%
% When a is a quadratic residue, the legendre symbol will be +1
legendresymbol(15,p)

%%
% Try legendresymbol on a large prime number p
p = vpi('659551234435459');
%%
% Yes, I chose p to indeed be a prime.
isprime(p)
%%
% Build a number for which we positively know the quadratic residue.
% Do this by picking some arbitrary integer x
x = vpi('365481861941');
%%
% And square x,
x^2
%%
% then compute the remainder modulo p
a = mod(x^2,p)
%%
% Clearly a must be a quadratic residue for the prime p, so (a/p) is known to be 1.
legendresymbol(a,p)

%%
% Recovering x is more difficult. In fact, x is not even uniquely
% defined. Generally, there will be a second value of x for prime p that
% when squared (mod p) yields the same value. See that we get the
% same residue for both x and p-x.
mod(x^2,p)
mod((p-x)^2,p)

%%
% When p is composite, quadratic residues get slightly more complicated.
p = 360;
quadraticresidues(p)

%%
% Which numbers x leave a residue of 100? There are 4 of them.
x = 1:359;
find(mod(x.^2,p) == 100)

%%
% But there are many more numbers that leave a residue of 121
find(mod(x.^2,p) == 121)
%%
% And more yet that leave a residue of 9
find(mod(x.^2,p) == 9)

%% Modular multiplicative inverse of an integer
% Compute the
% <http://en.wikipedia.org/wiki/Modular_multiplicative_inverse |multiplicative inverse|>
% of a, modulo N. Note that for the multplicative inverse to exist, a and N
% must be 
% <http://en.wikipedia.org/wiki/Coprime |coprime or relatively prime|>
% .
N = vpi('484816416515611681813');
a = 27;
ainv = minv(a,N)

%%
% ainv has the property that mod(a*ainv,N) == 1
mod(a*ainv,N)

%%
% Of course, if a and N are not coprime, the multiplicative inverse will
% not exist. So for example, 3 will have no inverse in the ring of integers
% modulo 15.
minv(3,15)

%% Linear Diophantine equations
% Can we find integer variables x and y such that A*x - B*y = 1,
% where A = 23 nd B = 97?
A = 23;
B = 97;
[x,y] = lineardiophantine(A,-B,1)

%%
% Check that this is a solution. We should get 1 as the result here.
A*x - B*y

%%
% Try it for much larger values, solving for A*x - B*y = C.
A = vpi('891172402');
B = vpi('1292626020223');
[x0,y0,xt,yt] = lineardiophantine(A,-B,17)

%%
% This time, our check in the linear combination should be 17
A*x0 - B*y0

%%
% We can find other solutions using xt and yt
x = x0 + 2*xt
y = y0 + 2*yt

%%
% It also works in the original equation
A*x - B*y

%% Euler's totient function
% The number of positive integers less than N, that are relatively prime
% <http://en.wikipedia.org/wiki/Coprime |(coprime)|>
% to N.
P = factorial(vpi(23)).^2;
totient(P)

%% The subfactorial 
% The 
% <http://en.wikipedia.org/wiki/Subfactorial |(Subfactorial)|>
% of a natural number N, known as the number of derangements
% of a set of size N, is given by subfactorial(N), and is often written
% as !N. A derangement is a permutation that leaves no element in the set
% fixed in the original location. The general formula for !N is 
%
% factorial(N)*sum(((-1)^k)/factorial(k))
% 
% where the sum is taken over the integers k = 0:N. The subfactorial
% function grows as fast as does the factorial. 
subfactorial(0:30)

%%
% In fact, Stirling's formula for the factorial will convince you that
% for larger values of N, the limit of factorial(N)/subfactorial(N)
% must approach exp(1).
format long g
for k = [2 3 4 5 6 7 8 9 10 12 15 20 30 50]
  disp([k,exp(log(factorial(vpi(k))) - log(subfactorial(vpi(k))))])
end

%% Random (uniform, with replacement) vpi numbers
% A random and uniformly distributed vpi number, chosen from the set [0:N]
% with replacement. Pick 10 of these numbers from that set.
N = vpi('6892956956565696956526565325447241412131313156166151')
R = randint(N,[10,1])

%% Linear algebra: rank, vpi style
% What is the rank of a matrix, mod p? The modrank function uses row
% operations to reduce the rows of a matrix, modulo p. This shows the
% rank of the matrix.
M = vpi(magic(5))
p = 26;
modrank(M,p)

%% Given a vector V, normalize it to have a unit norm, modulo some prime p
% This is possible as long as p is prime.
%
% First, I'll pick the smallest prime that exceeds 10000000000000
p0 = vpi('10000000000000');
i = 1;
while ~isprime(p0+i)
  i=i+2;
end
p = p0+i

%%
% Choose a random vector V, in this case of length 10.
V = randint(vpi('10000000000000'),[10,1])
%%
% and compute the norm(V)^2 using a dot product, all done modulo p
K = mod(V'*V,p)

%%
% Scale V by the modular inverse of the modular square root. The square
% root operation will not always have a solution. 
S = minv(modroot(K,p),p)
V = mod(V*S,p)

%%
% See that V now has the property that mod(V'*V,p) == 1
mod(V'*V,p)


