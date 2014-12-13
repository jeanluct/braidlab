a = A(3);
b = B(2);

A(b)          % here the conversion method is called
dostuff(b)    % but not here

%return

a = ns.A(3);
b = ns.B(2);

A(b)
dostuff(b)
