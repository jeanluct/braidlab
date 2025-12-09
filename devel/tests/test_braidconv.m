b = braidconv([1 2 3])
b.lr = -1     % change convention to right-to-left
b.cw = -1     % change convention to counterclockwise
b.word = [-4 -3 -2 -1] % now define word (read right-to-left)
b.word(2) = 2 % change the second generator, read from right-to-left
