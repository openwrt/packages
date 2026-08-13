# LLM review rules — openwrt/packages

The review routine reads this at session start.
General contribution rules (commit subject prefix,
Signed-off-by, real-name author, line length) live in
[`CONTRIBUTING.md`](../CONTRIBUTING.md).

## Review posture

Separate formatting that changes what gets built from formatting that
is only a matter of taste.

The first kind is a real defect and belongs in a review: a space where
make expects a tab in a recipe, indentation in `conffiles` or in an
install scriptlet that ends up inside the generated file, CRLF line
endings, a `define` block that is never closed. These break the build
or ship a broken package, and severity does not depend on how small
the diff looks.

The second kind — alignment, blank lines, the order of `KEY:=value`
entries, a house style a package has not followed for years — is
secondary. Maintainers here would rather merge a correct change with a
small style wart than hold it up over one, so:

- Lead with correctness, security and packaging bugs. Keep cosmetic
  remarks few, mark them as optional, and say plainly which findings
  (if any) actually block a merge.
- Do not restate what the formality bot already posted. Sign-off,
  no-reply e-mail, subject/body length, CRLF, `PKG_VERSION` /
  `PKG_RELEASE`, `conffiles` layout, patch headers and OpenWrt
  metadata are checked by [`formalities.json`](formalities.json).
  The rules below explain the reasoning behind those checks and cover
  what the bot cannot see — they are not a second checklist to run.
- CI is a reference, not a gate. A red job can just as easily be a gap
  in the test harness as a defect in the PR. Describe what failed and
  leave the call to the maintainer instead of demanding a green run.

## Package Version and Release (`PKG_VERSION`, `PKG_RELEASE`)

- **Reset release on upgrade.** When a package's `PKG_VERSION` is updated/upgraded, the `PKG_RELEASE` must be reset to `1`.
- **Increment release on modification.** When modifying build logic, adding patches, changing dependencies (`DEPENDS`), or modifying configuration/scripts (e.g. init scripts, hotplug handlers) without updating `PKG_VERSION`, the `PKG_RELEASE` must be incremented.
- **Do not increment release for minor changes.** Cosmetic edits (e.g., typos in comments, copyright updates, formatting/whitespace), changing the package maintainer (`PKG_MAINTAINER`), or updating source download info (`PKG_SOURCE_URL` / `PKG_HASH`) do not require incrementing `PKG_RELEASE`.

## Patches

### Patch regeneration

OpenWrt patches are quilt-managed and **not** refreshed with `git format-patch`. When a patch's hunk headers, fuzz, or context need to be regenerated, the project-specific command is:

- `make package/<pkg>/refresh` (e.g. `make package/lsof/refresh`)

If a patch's metadata or format is incorrect, recommend using the matching `make package/<pkg>/refresh` command, not `git format-patch`.

### Patch metadata / format

A patch that is a candidate for upstream submission should be
upstream-ready, which means it carries:
- A descriptive subject and body explaining why the patch is needed.
- A valid `Signed-off-by` header matching the patch author.
- An upstream reference, pull request link, or `Upstream-Status` indicating if/where the patch has been submitted upstream.

This bar is not meant for every patch in the feed. Many are
OpenWrt-specific hacks — cross-compile fixes, toolchain and path
adjustments, musl workarounds — that will never be sent anywhere, and
plenty are one or two lines whose intent is obvious from the diff
itself. There a short subject is enough: do not ask for a written
justification of a self-evident change, and do not ask for an upstream
reference on a patch that has no upstream to go to. Reserve the full
requirement for patches that are non-trivial or that change behaviour
in a way a reader cannot infer.

## Package Sources and Mirrors

- **Prefer archive tarballs over git clones.** `PKG_SOURCE_PROTO:=git` should only be used as a last resort if no release tarballs (xz, gz, bzip2, zip) are available.
- **Use mirror macros.** Prefer predefined mirror macros (e.g., `@GITHUB`, `@SF`, `@GNU`, `@GNOME`, `@SAVANNAH`, `@APACHE`, `@KERNEL`) in `PKG_SOURCE_URL` rather than hardcoding the full domain.

## Avoid reuse of `PKG_NAME`

- Do not reuse the `PKG_NAME` variable in `call`, `define`, and `eval` lines. Use the literal name of the package instead to improve readability.
  - *Correct:* `$(eval $(call BuildPackage,lsof))`
  - *Incorrect:* `$(eval $(call BuildPackage,$(PKG_NAME)))`

## Makefile indentation

Which character to indent a `define` block with depends on what the
block is — make only requires tabs where the block is a recipe:

- **Two spaces** for metadata blocks, whose body is a list of
  `KEY:=value` lines: `define Package/<name>` and
  `define KernelPackage/<name>`.
- **Tabs** for blocks whose body is shell run by make as a recipe:
  `define Build/*` (`Build/Configure`, `Build/Compile`,
  `Build/InstallDev`, …) and `define Package/<name>/install`.
- **No indentation** for blocks that are written out verbatim as a
  file: `define Package/<name>/conffiles` (see below) and the
  `preinst` / `postinst` / `prerm` / `postrm` scriptlets. Both go
  through `BuildPackVariable` in `include/package-pack.mk`, which
  echoes the block into a generated file — leading whitespace ends up
  inside the resulting shell script rather than in a make recipe.
- `define Package/<name>/description` (free-form prose) and
  `define Package/<name>/config` (Kconfig syntax, not `KEY:=value`)
  have no enforced convention. Two spaces dominate for the former and
  tabs for the latter, but neither is worth a comment on its own.

Only raise indentation on lines the PR actually touches. A package
that has used a different style throughout for years is not something
a version bump has to fix.

## Package testing (CI / Runtime tests)

- **Generic version check.** The CI automatically runs generic runtime checks on all package executables, executing them with version/help flags (e.g. `--version`, `--help`) and expecting the output to contain `PKG_VERSION`.
- **Add `test-version.sh` for overrides.** If the package executables do not support these flags or do not output the version string, the generic test will fail. To override/bypass this check, a `test-version.sh` script must be added to the package's directory (e.g. checking the package name and returning 0).
- **Add `test.sh` for custom tests.** A `test.sh` script can be added for custom runtime tests. Note that because generic tests are forced by default in CI, `test-version.sh` is still required if the executables fail the generic version check.
- **Avoid quiet mode in grep.** Do not use `grep -q` (or `--quiet`) in `test.sh` or `test-version.sh` scripts when checking output or version strings. Leaving the matched lines in the output ensures that the printed version or status is logged and visible in CI/CD build logs.

## Init Scripts

- **Use procd.** Service/init scripts (installed to `/etc/init.d/`) must use the procd process management system. They must include `USE_PROCD=1` and define `start_service()`.
- **Avoid legacy backgrounding.** Do not use manually written daemon management (e.g. backgrounding with `&`, custom `stop()` loops, manual PID files) unless there is a strong, explicitly stated reason.
- **Shebang.** All init scripts must use the shebang `#!/bin/sh /etc/rc.common`.

## Configuration Files (`conffiles`)

- **Register config files.** If a package installs user-modifiable configuration files (typically under `/etc/config/` or `/etc/`), they must be registered in the `define Package/<name>/conffiles` section.
- **Correct path formatting.**
  - Absolute paths must be used (starting with `/`).
  - Directories must end with a trailing slash `/`.
  - Individual files must NOT end with a trailing slash.
  - No indentation is allowed (do not start lines with spaces or tabs).

## Maintainer Info

- **New packages require a maintainer.** When a new package is introduced, a `PKG_MAINTAINER` field must be defined in the Makefile, formatted as `Name <email>`.

## Backports / cherry-picks

PRs targeting `openwrt-NN.NN` branches or titled `[X.Y] ...` are
backports. Their diffs should match the upstream commit on `master`
verbatim. Code-style or packaging issues that already exist on the
upstream commit belong on a fix-to-master PR, not on the backport —
flag only deviations introduced by the cherry-pick itself, plus
the missing `(cherry picked from commit <sha>)` trailer.
`git cherry-pick -x` adds the trailer automatically.

Not every stable-branch PR is a cherry-pick, though. A stable branch
can legitimately carry a version that no longer exists on `master`:
typically a minor update inside an LTS series that the branch stays
pinned to, while `master` has already moved on to a newer major. Such
a PR has no upstream commit to compare against and no
`cherry picked from` trailer to ask for. Review it on its own merits
and check only that the update stays inside the series the branch
already ships.
