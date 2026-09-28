# Releasing braidlab

This is the procedure for making a braidlab release.  It is written to be
followed step by step, by a maintainer or by an agent (such as Claude Code)
acting for one.  Every step gives the exact commands and says how to check
the result.  The steps that cannot be undone wait at a **STOP gate** for
explicit approval.

This file lives in `devel/`, which the release branch deletes, so always
read it from `develop`.  It covers the normal release, branched from
`develop`.  For a maintenance release branched from `master`, see
`devel/STYLE.md` and the wiki's hotfix procedure, and ask the maintainer.

Related: `devel/release-prep.py` (the text edits),
`devel/CI-WORKFLOW.md` (what CI does), and `devel/RELEASE-CONFIG.md`
(pinned toolchain values).

## Inputs

- `X.Y.Z`: the new version, for example `3.4.2` (or `X.Y`, as in `3.4`).
- The release date, `YYYY-MM-DD`; default today.

Below, `X.Y.Z` stands for the version.  Run all commands from the
repository root.

## Rules

- Never force-push.  Never delete or move a pushed tag without explicit
  approval.
- Every commit before STOP gate 1 is local and can be undone.  Nothing is
  pushed before the gate.
- If anything unexpected happens (an unlisted conflict, a failing check,
  or a tool refusing), stop and report.  Don't improvise a fix to the
  release procedure.

## 1. Preconditions

```bash
git checkout develop
git fetch origin --tags
git status --short               # must be empty
git rev-parse develop origin/develop   # must be equal
git tag -l "release-X.Y.Z"       # must be empty
git ls-remote --tags origin "release-X.Y.Z"   # must be empty
python3 devel/release-prep.py develop X.Y.Z --check   # must not refuse
```

- **CI must be green on `develop`'s HEAD.**
  `gh run list --branch develop --limit 1 --json headSha,conclusion` must
  show `success` for `git rev-parse develop`.
- **`--check` must show only the expected edit:** the new version heading
  under Unreleased, and the two compare links.

## 2. Report (for the maintainer; don't decide)

Collect these and present them at STOP gate 1:

- **Open issues in the milestone**, if one is named `release-X.Y.Z` or
  `release-X.Y`:
  `gh api repos/jeanluct/braidlab/milestones` then
  `gh issue list --milestone <title> --state open`.
- **Copyright year.**  The license headers read `Copyright (C) 2013-YYYY`.
  This should show only the current year:

  ```bash
  grep -rhoE --include='*.m' --include='*.cpp' --include='*.hpp' \
    --include='*.h' --include='*.tex' "Copyright \(C\) 2013-[0-9]{4}" . \
    | sort | uniq -c
  ```
- **External code freshness:**
  - `git fetch trains-remote cbraid-remote`
  - `git log --oneline trains-branch..trains-remote/master`
  - `git log --oneline cbraid-branch..cbraid-remote/master`

  If either log is non-empty, upstream has changes that are not in
  `extern/`; see `extern/README.md` for how to update.
- **Testsuite without MEX:** in MATLAB, from the repository root,
  `addpath(pwd); cd testsuite; r = test_braidlab('NoMEX')`.  Record the
  passed and failed counts.  (Tests *with* MEX run on the CI-built
  package in step 6, which is what users get.)
- **The Unreleased section of `CHANGELOG.md`:** show it.  It becomes the
  release notes.

## 3. Prepare `CHANGELOG.md` on `develop`

```bash
python3 devel/release-prep.py develop X.Y.Z --date YYYY-MM-DD
git diff                         # only CHANGELOG.md: heading + 2 link lines
git commit -am "Prepare CHANGELOG.md for release-X.Y.Z"
```

The Unreleased heading stays on `develop`, now empty, above the new
`## [X.Y.Z] - YYYY-MM-DD` heading.

## 4. Release branch

```bash
git checkout -b release-X.Y.Z-branch
python3 devel/release-prep.py release X.Y.Z
git diff    # CHANGELOG.md loses the Unreleased heading and its link;
            # doc/getrelease.tex comments out the git-tag line and adds X.Y.Z
git commit -am "Prepare release-X.Y.Z metadata and guide"
git rm -r -q devel
git commit -m "Remove devel from release branch before merge to master"
```

Why `getrelease.tex` is hardwired: on `develop` the guide takes its
version from `git tag`, but CI checks out without tags.  The hardwired
form exists only on the release branch and `master`, so there is nothing
to restore on `develop` afterwards.  `release-prep.py` lives in `devel/`,
so run it before `git rm -r devel`.

## 5. Merge into `master` and tag (local)

```bash
git checkout master
git pull --ff-only origin master
git merge --no-ff release-X.Y.Z-branch -m "Merge branch 'release-X.Y.Z-branch'"
```

- **Conflicts.**  Only `CHANGELOG.md` and `doc/getrelease.tex` may
  conflict.  Take the release branch's version of both:

  ```bash
  git checkout --theirs CHANGELOG.md doc/getrelease.tex
  git add CHANGELOG.md doc/getrelease.tex
  git commit --no-edit
  ```

  Any other conflicting file: stop and report.
- **Check** that `git diff --stat release-X.Y.Z-branch master` prints
  nothing: `master` must now equal the release branch.  Also check that
  `grep -c "Unreleased" CHANGELOG.md` prints `0`, and that
  `grep -c "^X.Y.Z$" doc/getrelease.tex` prints `1`.

```bash
git tag -a release-X.Y.Z -m "Release X.Y.Z"
```

## STOP gate 1: approval to push

Present:
- the report from step 2;
- `git log --oneline origin/develop..develop` (1 commit);
- `git log --oneline origin/master..master`;
- the tag.

The pushes below publish the release; the tag push starts the packaging
build.  Wait for explicit approval, then push, or give the maintainer these
commands:

```bash
git push origin develop
git push origin master
git push origin release-X.Y.Z
```

## 6. Verify the draft release

The tag push runs `.github/workflows/build-braidlab-packages.yml`.  After
every package job succeeds, its `publish_release` job creates a **draft**
release with the archives, `SHA256SUMS`, and notes taken from the
`## [X.Y.Z]` section of `CHANGELOG.md`.

```bash
gh run list --branch release-X.Y.Z --limit 1    # wait for completion
gh run view <run-id> --json conclusion,jobs     # all jobs: success
gh release view release-X.Y.Z --json isDraft,name,body,assets
```

Check:
- **The draft:** `isDraft` is true; there are 8 `braidlab-X.Y.Z_*`
  archives (Linux, macOS arm64, macOS x86_64, Windows, each default and
  `_no-gmp`) plus `SHA256SUMS`; the notes match the CHANGELOG section.
- **The downloaded files,** in a scratch directory:
  - `gh release download release-X.Y.Z` then `sha256sum -c SHA256SUMS`,
    which must be all `OK`;
  - each `.zip` opens directly to `+braidlab/`, `doc/`, `extern/` and so
    on (not to another zip);
  - `BUILD-MANIFEST.txt` in each archive has
    `commit=$(git rev-parse release-X.Y.Z^{commit})`.
- **The package in MATLAB.**  Extract the Linux default package, then in
  the newest local MATLAB, *without* `LD_PRELOAD`, run
  `addpath(<extracted>,'-begin'); cd(fullfile(<extracted>,'testsuite'))`,
  then `test_braidlab` and `test_braidlab('NoMEX')`.  All tests must
  pass.  Confirm with `inmem('-completenames')` that the loaded MEX files
  come from the package.

## STOP gate 2: approval to publish

Present the results of step 6.  Publishing makes the release public and
marks it latest.  Only on explicit approval:

```bash
gh release edit release-X.Y.Z --draft=false --latest
```

## 7. Clean up

```bash
git checkout develop
git branch -d release-X.Y.Z-branch
```

`develop` needs no further change.  `master` is not merged back into
`develop`.

## If something fails after the tag push

- **A CI job fails:** no release is created, since the publish job needs
  every package job.  Report the failing job and its log.  Don't re-tag
  without approval: moving a pushed tag rewrites history that others may
  have fetched.
- **An asset is wrong:** report it.  Fixing needs a new commit; then
  either a new version, or (with approval) deleting the draft and the
  tag and re-tagging.
