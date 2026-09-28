# Changelog

- 2026-03-24 `3a1ea3c`: Migrate `INSTALL`/`CHANGELOG` to Markdown and switch remaining repository links to HTTPS.

- 2026-03-24 `7cd265b`: Fix residual CLI memory leaks (`ReadFileName` ownership and `PrintUSS` buffer cleanup).

- 2026-03-24 `f70a5f3`: Fix Delta-power factor handling in USS/centralizer paths (issue #3, Ultra Summit Set segfaults).

- 2026-03-24 `e8e4c9c`: Improve Makefile portability and recursive make usage.

- 2024-07-19 `50b2891`: Fix indexing error in `BallotSequence` (issue #7).

- 2024-07-19 `615837a`: First fix attempt for issue #3 (Ultra Summit Set segfaults).

- 2019-11-13 `e55b6f9`: Replace deprecated `ptr_fun`/`mem_fun_ref` usages.

- 2019-11-13 `a47cbca`: Specify `-std=c++0x` to avoid deprecation warnings.

- 2019-11-13 `9a57a69`: Remove `register` keyword for C++17 compatibility.

- 2019-11-13 `74f5413`: Avoid compiler warning when CLN is not used.

- 2018-04-25 `bc7e82b`: Enable debugging builds with `make DEBUG=1`.

- 2018-03-21 `479482e`: Enable CLN with `make USE_CLN=1`.

- 2014-12-10 `933144a`: Fix bug where computing a set of sliding circuits could throw an error.

- 2014-07-04 `b7f8c94`: Add sliding circuits code contributed by Maria Cumplido.

- 2013-09-24 `29a845e`: Mac OS X clang/Xcode 5 compile compatibility update.

- 2013-08-03 `d12382c`: Remove unused variables `cur` and `current`.

- 2011-10-07 `ea4a006`: Remove `-fPIC` compile flag.

- 2011-09-19 `085c267`: Update GPL naming, improve Makefile for programs, move headers to `include`, update changelog, and add small install file.

- 2011-09-19 `9a03539`: Import sources from earlier private braid project.

This is a curated list of notable changes, not a complete commit log.
