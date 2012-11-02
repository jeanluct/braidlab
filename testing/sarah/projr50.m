

orbit1_1 = load('tempdata/upo7_7_0.path');
orbit1_2 = load('tempdata/upo7_7_1.path');
orbit1_3 = load('tempdata/upo7_7_2.path');
orbit1_4 = load('tempdata/upo7_7_3.path');
orbit1_5 = load('tempdata/upo7_7_4.path');
orbit1_6 = load('tempdata/upo7_7_5.path');
orbit1_7 = load('tempdata/upo7_7_6.path');


orbit2_1 = load('tempdata/upo7_8_0.path');
orbit2_2 = load('tempdata/upo7_8_1.path');
orbit2_3 = load('tempdata/upo7_8_2.path');
orbit2_4 = load('tempdata/upo7_8_3.path');
orbit2_5 = load('tempdata/upo7_8_4.path');
orbit2_6 = load('tempdata/upo7_8_5.path');
orbit2_7 = load('tempdata/upo7_8_6.path');


orbit5_1 = load('tempdata/rods50_1.path');
orbit5_2 = load('tempdata/rods50_2.path');
orbit5_3 = load('tempdata/rods50_3.path');
orbit5_4 = load('tempdata/rods50_4.path');

A = orbit1_1;
A(:,:,2) = orbit1_2;
A(:,:,3) = orbit1_3;
A(:,:,4) = orbit1_4;
A(:,:,5) = orbit1_5;
A(:,:,6) = orbit1_6;
A(:,:,7) = orbit1_7;

A(:,:,8) = orbit2_1;
A(:,:,9) = orbit2_2;
A(:,:,10) = orbit2_3;
A(:,:,11) = orbit2_4;
A(:,:,12) = orbit2_5;
A(:,:,13) = orbit2_6;
A(:,:,14) = orbit2_7;

A(:,:,15) = orbit5_1;
A(:,:,16) = orbit5_2;
A(:,:,17) = orbit5_3;
A(:,:,18) = orbit5_4;
