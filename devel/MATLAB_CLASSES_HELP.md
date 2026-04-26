# MATLAB Classes and Namespaces Notes

`+braidlab` is the namespace folder for the braidlab library.

- Adding `+` to a folder name means that if the parent folder is on the
  MATLAB path, functions inside can be called as `braidlab.<function>`.
- To avoid repeatedly writing `braidlab.`, code can use imports such as:
  - `import braidlab.<function>`
  - `import braidlab.*`
- A `private` subfolder is only accessible to functions in its containing
  folder, without adding the private folder to the path.
- Functions in `+braidlab` do not automatically see each other; use the
  `braidlab.` prefix or `import`.
- Nested namespace folders are allowed (for example `+util`), giving calls
  like `braidlab.util.<function>`.
- A subfolder beginning with `@` contains a class, for example `@braid`.
- Classes cannot be private, since the `@` folder must be on the path.

Historical links from the original note (some may now be outdated):

- <http://www.mathworks.com/help/techdoc/matlab_oop/brfynt_-1.html>
- <http://www.mathworks.com/help/techdoc/matlab_prog/f4-70335.html>
- <https://stackoverflow.com/questions/2748302/what-is-the-closest-thing-matlab-has-to-namespaces>
