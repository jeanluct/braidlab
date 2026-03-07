Thorny issue where calling train twice hangs:
```
tic; trn1 = train(b); toc;
tic; trn2 = train(b); toc;   % hangs
```
