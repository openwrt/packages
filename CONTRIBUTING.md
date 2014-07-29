# Contributing Guidelines

Please make sure that all packages you commit or request to pull:
* Package a version which is still maintained by the upstream author.
* Have yourself or another person listed in the (PKG_)MAINTAINER field.
* Will be updated regularly to maintained and supported versions.
* Have no dependencies outside the openwrt core packages or this feed.
* Are "run tested" (or at least compile tested)

Please make sure that all commits you make to this repository:
* Are signed-off (see https://dev.openwrt.org/wiki/SubmittingPatches#a10.Signyourwork)
* Have a proper description (starting with <package-name>: / including <package-name>)

If you have commit access:
* Do NOT use git push --force.
* Do NOT commit to other maintainer's packages without their consent.
* Use Pull Requests if you are unsure and to suggest changes to other maintainers.

Release Branches:
* Branches named "for-XX.YY" (e.g. for-14.07) are release branches.
* These branches are built with the respective OpenWrt release and are created
  during the release stabilisation phase.
* Please ONLY cherry-pick or commit security and bug-fixes to these branches.
* Do NOT add new packages and do NOT do major upgrades of packages here.
* If you are unsure if your change is suitable, please use a pull request.
