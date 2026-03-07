## External libraries used in braidlab

All the external scripts and libraries are contained in the `extern`
subfolder.  Credits and licenses are in each library's subfolder.

### assignmentoptimal

`assignmentoptimal` is obtained from http://www.mathworks.com/matlabcentral/fileexchange/6543.  The compiled mex file is copied to the folder `+braidlab/private`. (Version 2011-07-05)

### VPI

`VariablePrecisionIntegers` is obtained from http://www.mathworks.com/matlabcentral/fileexchange/22725-variable-precision-integer-arithmetic. The functions not used by braidlab are not included. (Version 31 Jul 2013)

### CBraid

`CBraid` is checked out from https://github.com/jeanluct/cbraid in a separate branch [`cbraid-branch`](https://github.com/jeanluct/braidlab/tree/cbraid-branch/).  To update CBraid to the latest:
```sh
  git checkout cbraid-branch; git pull # pull changes from remote cbraid-remote
  git checkout develop
  git merge --squash -s recursive -Xsubtree=extern/cbraid --no-commit --allow-unrelated-histories cbraid-branch
```
See [Subtree Merging](http://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging).

This seems a bit broken now: I had to add --allow-unrelated-histories,
but Git seems to create a squash commit of everything each time.

### Trains

`trains` is checked out from https://github.com/jeanluct/trains
in a separate branch [`trains-branch`](https://github.com/jeanluct/braidlab/tree/trains-branch/).  To update trains to the latest:
```sh
  git checkout trains-branch; git pull # pull changes from remote trains-remote
  git checkout develop
  git merge --squash -s recursive -Xsubtree=extern/trains --no-commit --allow-unrelated-histories trains-branch
```
See [Subtree Merging](http://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging).

This seems a bit broken now: I had to add --allow-unrelated-histories,
but Git seems to create a squash commit of everything each time.
