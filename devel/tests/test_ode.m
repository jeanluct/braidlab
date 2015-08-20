function test_ode

rigid = @(t,XY) [XY(2);-XY(1)];
