# braidlab

*braidlab* is a [Matlab][1] package for analyzing data using braids, written by [Jean-Luc Thiffeault][2] and [Marko Budisic][3].

### documentation and installation

The easiest way to use *braidlab* is to download [one of the binaries][4] for Linux, Mac OSX, or Windows.  Unzip/untar the file and make sure the folder containing `+braidlab` is on your Matlab path.  Run `import braidlab.*` to access the *braidlab* namespace.  You can then create a braid with
```
> b = braid([1 2 -3])

b =

 < 1  2 -3 >
```
The train track map associated with the braid's mapping class is
```
> ttmap(b.train)

 1 -> 4
 2 -> 1
 3 -> 2
 4 -> 3
 a -> D
 b -> d a -3 b -4 B
 c -> B 3 A
 d -> c
```
where numbers denote peripheral edges, and letters main edges.

*braidlab* can do much more; see the [*braidlab* user's guide][5] in the `doc` folder for many examples.  The guide is also posted on [arXiv][6].  For detailed installation instructions from source files, see the Appendix in the guide.

### citing *braidlab*

If you use *braidlab* in one of your papers, please cite it as:

* J.-L. Thiffeault and Marko Budišić, _Braidlab: A Software Package for Braids and Loops_, [arXiv:1410.0849](https://arXiv.org/abs/1410.0849) [math.GT] (2013-2025), Version `<<version number>>`.

You can use this BibTeX entry:
```
@Misc{braidlab,
    author = {Jean-Luc Thiffeault and Marko Budi\v{s}i\'{c}},
    title = {Braidlab: {A} Software Package for Braids and Loops},
    eprint = {arXiv:1410.0849 [math.GT]},
    url = {https://arXiv.org/abs/1410.0849},
    year = {2013--2025},
    note = {Version <<version number>>}
}
```
We can add your paper to the [publication list](https://github.com/jeanluct/braidlab/wiki/Publications).

### contributors

[Michael Allshouse][7] contributed extensive testing, comments, and some of the code.

*braidlab* uses Toby Hall's [Trains][8]; Jae Choon Cha's [CBraid][9]; Juan Gonzalez-Meneses's [Braiding][10]; John D'Errico's [Variable Precision Integer Arithmetic][11]; Markus Buehren's [assignmentoptimal][12]; and Jakob Progsch and Václav Zeman's [ThreadPool][13].

### license

*braidlab* is released under the [GNU General Public License v3][14].  See [COPYING][15] and [LICENSE][16].

### support

The development of *braidlab* was supported by the [US National Science Foundation][17], under grants [DMS-0806821][18] and [CMMI-1233935][19].

[1]: https://www.mathworks.com/products/matlab/
[2]: https://people.math.wisc.edu/~thiffeault/
[3]: https://mbudisic.wordpress.com/
[4]: https://github.com/jeanluct/braidlab/releases
[5]: https://github.com/jeanluct/braidlab/raw/master/doc/braidlab_guide.pdf
[6]: https://arxiv.org/abs/1410.0849
[7]: https://coe.northeastern.edu/people/allshouse-michael/
[8]: https://github.com/jeanluct/trains
[9]: https://github.com/jeanluct/cbraid
[10]: https://personal.us.es/meneses/software.php
[11]: https://www.mathworks.com/matlabcentral/fileexchange/22725-variable-precision-integer-arithmetic
[12]: https://www.mathworks.com/matlabcentral/fileexchange/6543-functions-for-the-rectangular-assignment-problem
[13]: https://github.com/progschj/ThreadPool
[14]: https://www.gnu.org/licenses/gpl-3.0.html
[15]: https://github.com/jeanluct/braidlab/raw/master/COPYING
[16]: https://github.com/jeanluct/braidlab/raw/master/LICENSE
[17]: https://www.nsf.gov
[18]: https://www.nsf.gov/awardsearch/showAward?AWD_ID=0806821
[19]: https://www.nsf.gov/awardsearch/showAward?AWD_ID=1233935
