# Contributing Guidelines

Ref: <https://openwrt.org/docs/guide-developer/packages> for overall format and construction

## Basic guidelines

All packages you commit or submit by pull-request should follow these simple
guidelines:

- Package a version which is still maintained by the upstream author and will
  be updated regularly with supported versions.
- Have no dependencies outside the OpenWrt core packages or this repository
  feed.
- Have been tested to compile with the correct includes and dependencies.
  Please also test with "Compile with full language support" found under
  "General Build Settings" set if language support is relevant to your package.
- Best of all -- it works as expected!

## Package Sources (archives and repositories)

- PKG_SOURCE should reference the smallest available archive. In order of
  preference: xz (most compressed), bzip2, gz and zip. As a last resort,
  downloads from source repositories can be used.
- PKG_SOURCE_URL should link to an official release archive. Use of HTTPS&#x3A;
  is preferred. If a source archive is not available, a locally generated
  archive fetched using git, svn, cvs or in rare circumstances, hg or bzr.
- Convenience macros for popular mirrors are defined. Using these macros will
  make your package downloads more robust by mapping to a list of possible
  source mirrors for archive availability.
  - @SF - Sourceforge (downloads.sourceforge.net) with 5 retries due to
    re-directs
  - @GITHUB - Github (raw.githubusercontent.com) with 5 retries due to
    re-directs
  - @GNU - 8 regional servers
  - @GNOME - 8 regional servers
  - @SAVANNAH - 8 regional servers
  - @APACHE - 8 regional servers
  - @KERNEL - Linux kernel archives & mirrors
- Please _DO NOT_ use an archive which changes over time. A version labeled
  "latest" is not constant each download. Also, using the head of a branch will
  create unpredictable results which can be different each build.

### Makefile contents should contain

- Provide an up-to-date Copyright notice or **none**. Copyright should not be
  assigned to OpenWrt unless you are explicitly requested by or working under
  contract to OpenWrt. Assigning a Copyright to yourself or organization you
  represent is acceptable.
- A (PKG\_)MAINTAINER definition listing either yourself and/or another person
  responsible for this package (E.g.: PKG_MAINTAINER:= Joe D. Hacker
  `<jdh@jdhs-email-provider.org`>). Listing multiple maintainers is encouraged in
  order to keep the package active and up-to-date. Leaving this blank will also
  be accepted, however the review process may not be as quick as one with a
  maintainer.
- A PKG_LICENSE tag declaring the main license of the package.  (E.g.:
  PKG_LICENSE:=GPL-2.0-or-later) Please use SPDX identifiers if possible (see
  list at the bottom).
- An optional PKG_LICENSE_FILES tag including the filenames of the
  license-files in the source-package.  (E.g.: PKG_LICENSE_FILES:=COPYING)
- PKG_RELEASE should be initially set to 1 or reset to 1 if the software
  version is changed. You should increment it if the package itself has
  changed. For example, modifying a support script, changing configure options
  like --disable_ or --enable\_ switches, or if you changed something in the
  package which causes the resulting binaries to be different. Changes like
  correcting md5sums, changing mirror URLs, adding a maintainer field or updating
  a comment or copyright year in a Makefile do not require a change to
  PKG_RELEASE.
- Avoid reuse of PKG_NAME in call, define and eval lines to improve
  readability.

### Commits in your pull-requests should

- Have a useful description prefixed with the package name (E.g.: "foopkg: Add
  libzot dependency")
- Include Signed-off-by tag in the commit comments.  See: [Sign your
  work](https://openwrt.org/submitting-patches#sign_your_work)

## Advice on pull requests

Pull requests are the easiest way to contribute changes to git repos at Github.
They are the preferred contribution method, as they offer a nice way for
commenting and amending the proposed changes.

- You need a local "fork" of the Github repo.

- Use a "feature branch" for your changes. That separates the changes in the
  pull request from your other changes and makes it easy to edit/amend commits
  in the pull request. Workflow using "feature_x" as the example:
  - Update your local git fork to the tip (of the master, usually)
  - Create the feature branch with `git checkout -b feature_x`
  - Edit changes and commit them locally
  - Push them to your Github fork by `git push -u origin feature_x`. That
    creates the "feature_x" branch at your Github fork and sets it as the
    remote of this branch
  - When you now visit Github, you should see a proposal to create a pull
    request

- If you later need to add new commits to the pull request, you can simply
  commit the changes to the local branch and then use `git push` to
  automatically update the pull request.

- If you need to change something in the existing pull request (e.g. to add a
  missing signed-off-by line to the commit message), you can use `git push -f`
  to overwrite the original commits. That is easy and safe when using a feature
  branch. Example workflow:
  - Checkout the feature branch by `git checkout feature_x`
  - Edit changes and commit them locally. If you are just updating the commit
    message in the last commit, you can use `git commit --amend` to do that
  - If you added several new commits or made other changes that require
    cleaning up, you can use `git rebase -i HEAD~X` (X = number of commits to
    edit) to possibly squash some commits
  - Push the changed commits to Github with `git push -f` to overwrite the
    original commits in the "feature_x" branch with the new ones. The pull
    request gets automatically updated

## If you have commit access

- Do NOT use git push --force.
- Do NOT commit to other maintainer's packages without their consent.
- Use Pull Requests if you are unsure and to suggest changes to other
  maintainers.

### Gaining commit access

- We will gladly grant commit access to responsible contributors who have made
  useful pull requests and / or feedback or patches to this repository or
  OpenWrt in general. Please include your request for commit access in your next
  pull request or ticket.

## Release Branches

- Old stable branches were named after the following pattern "for-XX.YY" (e.g.
  for-14.07) before the LEDE split.  During the LEDE split there was only one
  release branch with the name "lede-17.01".  After merging the LEDE fork with
  OpenWrt the release branches are named according to the following pattern
  "openwrt-XX.YY" (e.g. openwrt-18.06).
- These branches are built with the respective OpenWrt release and are created
  during the release stabilisation phase.
- Please ONLY cherry-pick or commit security and bug-fixes to these branches.
- Do NOT add new packages and do NOT do major upgrades of packages here.
- If you are unsure if your change is suitable, please use a pull request.

## Common LICENSE tags (short list)

(Complete list can be found at: <https://spdx.org/licenses>)

| Full Name                                        | Identifier               |
| ------------------------------------------------ | :----------------------- |
| Apache License 1.0                               | Apache-1.0               |
| Apache License 1.1                               | Apache-1.1               |
| Apache License 2.0                               | Apache-2.0               |
| Artistic License 1.0                             | Artistic-1.0             |
| Artistic License 1.0 w/clause 8                  | Artistic-1.0-cl8         |
| Artistic License 1.0 (Perl)                      | Artistic-1.0-Perl        |
| Artistic License 2.0                             | Artistic-2.0             |
| BSD 2-Clause "Simplified" License                | BSD-2-Clause             |
| BSD 2-Clause FreeBSD License                     | BSD-2-Clause-FreeBSD     |
| BSD 2-Clause NetBSD License                      | BSD-2-Clause-NetBSD      |
| BSD 3-Clause "New" or "Revised" License          | BSD-3-Clause             |
| BSD with attribution                             | BSD-3-Clause-Attribution |
| BSD 3-Clause Clear License                       | BSD-3-Clause-Clear       |
| BSD 4-Clause "Original" or "Old" License         | BSD-4-Clause             |
| BSD-4-Clause (University of California-Specific) | BSD-4-Clause-UC          |
| BSD Protection License                           | BSD-Protection           |
| GNU General Public License v1.0 only             | GPL-1.0-only             |
| GNU General Public License v1.0 or later         | GPL-1.0-or-later         |
| GNU General Public License v2.0 only             | GPL-2.0-only             |
| GNU General Public License v2.0 or later         | GPL-2.0-or-later         |
| GNU General Public License v3.0 only             | GPL-3.0-only             |
| GNU General Public License v3.0 or later         | GPL-3.0-or-later         |
| GNU Lesser General Public License v2.1 only      | LGPL-2.1-only            |
| GNU Lesser General Public License v2.1 or later  | LGPL-2.1-or-later        |
| GNU Lesser General Public License v3.0 only      | LGPL-3.0-only            |
| GNU Lesser General Public License v3.0 or later  | LGPL-3.0-or-later        |
| GNU Library General Public License v2 only       | LGPL-2.0-only            |
| GNU Library General Public License v2 or later   | LGPL-2.0-or-later        |
| Fair License                                     | Fair                     |
| ISC License                                      | ISC                      |
| MIT License                                      | MIT                      |
| No Limit Public License                          | NLPL                     |
| OpenSSL License                                  | OpenSSL                  |
| X11 License                                      | X11                      |
| zlib License                                     | Zlib                     |

## Continuous Integration

To simplify review and require less human resources, a CI tests all packages.
Passing CI tests are not a hard requirement but a good indicator what the
Buildbots will think about the proposed patch.

The CI builds modified packages for multiple architectures using the latest
snapshot SDK. For supported architectures (`aarch64_generic`,
`arm_cortex-a15_neon-vfpv4`, `i386_pentium4` and `x86_64`) an additional
runtime test is executed. A running OpenWrt is simulated which tries to install
created packages and runs a script called `test.sh` located next to the package
Makefile. The script is executed with the two arguments `PKG_NAME` and
`PKG_VERSION`. The `PKG_NAME` can be used to distinguish package variants, e.g.
`foobar` vs. `foobar-full`. The `PKG_VERSION` can be used for a trivial test
checking if `foobar --version` prints the correct version. `PKG_VERSION` is the
OpenWrt version and therefore includes the `PKG_RELEASE`, which isn't usually
part of the running programs version.

The following snippet shows a script that tests different binaries depending on
what IPK package was installed. The `gpsd` Makefile produces both a `gpsd` and
a `gpsd-clients` IPK packages.

```shell
 #!/bin/sh

case "$1" in
    "gpsd")
        gpsd -V 2>&1 | grep "$2"
        ;;
    "gpsd-clients")
        cgps -V 2>&1 | grep "$2"
        ;;
esac
```
