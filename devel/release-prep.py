#!/usr/bin/env python3
"""Make the release-time text edits for braidlab, deterministically.

See devel/RELEASING.md for where each mode fits in the release procedure.

  devel/release-prep.py develop X.Y.Z [--date YYYY-MM-DD] [--check]
      On develop.  In CHANGELOG.md, insert the version header "## [X.Y.Z] -
      DATE" under the (kept) Unreleased heading, point the [unreleased]
      link at release-X.Y.Z...develop, and add the [X.Y.Z] compare link.

  devel/release-prep.py release X.Y.Z [--check]
      On the release branch.  Remove the Unreleased heading and its link
      from CHANGELOG.md, and hardwire X.Y.Z in doc/getrelease.tex (CI
      checks out without tags, so the git-tag pipeline there would find
      nothing).

--check prints the changes as a diff and writes nothing.  The script
refuses (exit status 1) whenever a file does not look as expected, rather
than guessing.  Run it from the repository root.
"""

import argparse
import datetime
import difflib
import re
import sys

CHANGELOG = "CHANGELOG.md"
GETRELEASE = "doc/getrelease.tex"
UNRELEASED_HEADING = "## [Unreleased][unreleased]"
COMPARE = "https://github.com/jeanluct/braidlab/compare/"
GIT_TAG_LINE = "\\input{\"| git tag | grep release | cut -b 9-13 | tail -1 | sed 's/ *$//g'\"}"


class Refuse(Exception):
    pass


def read(path):
    with open(path, encoding="utf-8") as f:
        return f.read().split("\n")


def unreleased_link_index(lines):
    idx = [i for i, l in enumerate(lines) if l.startswith("[unreleased]: ")]
    if len(idx) != 1:
        raise Refuse(f"expected exactly one [unreleased] link, found {len(idx)}")
    return idx[0]


def heading_index(lines, text):
    idx = [i for i, l in enumerate(lines) if l == text]
    if len(idx) != 1:
        raise Refuse(f"expected exactly one line {text!r}, found {len(idx)}")
    return idx[0]


def next_version_heading(lines, start):
    for i in range(start + 1, len(lines)):
        if lines[i].startswith("## ["):
            return i
    raise Refuse("no version heading after the Unreleased heading")


def prep_develop(version, date):
    lines = read(CHANGELOG)
    if any(l.startswith(f"## [{version}]") for l in lines):
        raise Refuse(f"CHANGELOG.md already has a [{version}] heading")
    u = heading_index(lines, UNRELEASED_HEADING)
    nxt = next_version_heading(lines, u)
    if not any(l.strip() for l in lines[u + 1:nxt]):
        raise Refuse("the Unreleased section is empty: nothing to release")

    link = unreleased_link_index(lines)
    m = re.fullmatch(r"\[unreleased\]: " + re.escape(COMPARE)
                     + r"release-([0-9][0-9.]*)\.\.\.develop", lines[link])
    if not m:
        raise Refuse(f"unexpected [unreleased] link: {lines[link]!r}")
    prev = m.group(1)

    # Link lines first (they are below the headings, so indices above
    # stay valid).
    lines[link:link + 1] = [
        f"[unreleased]: {COMPARE}release-{version}...develop",
        f"[{version}]: {COMPARE}release-{prev}...release-{version}",
    ]
    # Keep the Unreleased heading, then two blank lines and the new
    # version heading, then a blank line before the entries.  This is the
    # layout of every earlier release (for example 3.4, commit 943b4e9).
    body_start = u + 1
    while body_start < nxt and not lines[body_start].strip():
        body_start += 1
    lines[u + 1:body_start] = ["", "", f"## [{version}] - {date}", ""]
    return {CHANGELOG: lines}, f"previous release: {prev}"


def prep_release(version):
    lines = read(CHANGELOG)
    u = heading_index(lines, UNRELEASED_HEADING)
    nxt = next_version_heading(lines, u)
    if not lines[nxt].startswith(f"## [{version}] - "):
        raise Refuse(f"the heading after Unreleased is {lines[nxt]!r}, not "
                     f"[{version}]; run the 'develop' mode first")
    if any(l.strip() for l in lines[u + 1:nxt]):
        raise Refuse("the Unreleased section is not empty; those entries "
                     "would be lost (move them under the version heading)")
    link = unreleased_link_index(lines)
    if not any(l.startswith(f"[{version}]: ") for l in lines):
        raise Refuse(f"no [{version}] compare link; run the 'develop' mode first")
    del lines[link]
    del lines[u:nxt]  # heading and the blank lines after it

    tex = read(GETRELEASE)
    if tex.count(GIT_TAG_LINE) != 1:
        raise Refuse(f"{GETRELEASE}: expected the uncommented git-tag \\input "
                     "line exactly once (already hardwired?)")
    i = tex.index(GIT_TAG_LINE)
    tex[i:i + 1] = ["%" + GIT_TAG_LINE, version]
    return {CHANGELOG: lines, GETRELEASE: tex}, "hardwired " + GETRELEASE


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("mode", choices=["develop", "release"])
    ap.add_argument("version")
    ap.add_argument("--date", default=datetime.date.today().isoformat())
    ap.add_argument("--check", action="store_true",
                    help="show the changes as a diff; write nothing")
    args = ap.parse_args()

    if not re.fullmatch(r"[0-9]+(\.[0-9]+){1,2}", args.version):
        print(f"refused: version {args.version!r} is not X.Y or X.Y.Z",
              file=sys.stderr)
        return 1
    if not re.fullmatch(r"[0-9]{4}-[0-9]{2}-[0-9]{2}", args.date):
        print(f"refused: date {args.date!r} is not YYYY-MM-DD", file=sys.stderr)
        return 1

    try:
        if args.mode == "develop":
            changes, note = prep_develop(args.version, args.date)
        else:
            changes, note = prep_release(args.version)
    except (Refuse, OSError) as e:
        print(f"refused: {e}", file=sys.stderr)
        return 1

    for path, new in changes.items():
        old = read(path)
        if args.check:
            sys.stdout.writelines(difflib.unified_diff(
                [l + "\n" for l in old], [l + "\n" for l in new],
                fromfile=f"a/{path}", tofile=f"b/{path}"))
        else:
            with open(path, "w", encoding="utf-8") as f:
                f.write("\n".join(new))
    print(("checked" if args.check else "updated") + f" ({note})", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
