# pbr tests

| Script | Purpose | Runs where |
| --- | --- | --- |
| `tests/run_tests.sh` | Functional suite: runs `files/lib/pbr` against the mocks in `tests/lib` and `tests/mocks`, then syntax-checks the shell scripts | Development machine and CI, on current ucode |
| `tests/check-ucode-syntax.sh` | Compiles every `.uc` file to catch syntax too new for the oldest supported ucode. Uses no mocks | CI through `ucode-syntax.yml`, or from `run_tests.sh` when given an interpreter |
| `test-version.sh` | Checks that the installed package reports the expected version | OpenWrt package CI, on the installed package |

## Functional tests

```sh
bash tests/run_tests.sh                        # everything
bash tests/run_tests.sh tests/02_config/01_x   # selected tests
```

The script must run from the top of the source tree. It exits with the number of failures.

## Syntax compatibility

`check-ucode-syntax.sh` must run on the ucode of the oldest supported OpenWrt release, because compiling on a newer one proves nothing about those routers. On a newer interpreter it refuses to run and exits 2. `UCODE_REF` in `.github/workflows/ucode-syntax.yml` names that version, and moves only when the oldest supported release moves.

To include it in a local run, point `PBR_UCODE_OLDEST` at an interpreter built from that commit:

```sh
PBR_UCODE_OLDEST=/path/to/ucode bash tests/run_tests.sh
```

Without it, `run_tests.sh` reports the check as skipped. The functional suite itself deliberately follows ucode master in CI, as early warning of upstream changes.
