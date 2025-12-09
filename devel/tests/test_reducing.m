warning('off','BRAIDLAB:braid:reducing:exp')

b = braid([-3  1 -4  2 -3 -1 -2  3 -2  4  3  4]);
reducing(b)

b = braid([1],3)
reducing(b)

b = braid([1 2],4)
reducing(b)

b = braid([1 2],5)
l = reducing(b)
