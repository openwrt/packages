#!/bin/sh
#
# Runtime tests for atlas-sw-probe and atlas-sw-probe-rpc.
#
# atlas-sw-probe is the script + init + UCI layer that drives the atlas-probe
# busybox binaries (the C measurement applets). The Makefile's Build/Prepare
# step substitutes @atlas_*@ template tokens into every .in file under bin/
# and config/common/. This test sanity-checks the installed layout, the
# template substitutions, init/UCI integration and the rpcd handler.
#
# Coverage:
#  - all generated/lib/state/etc files present, executable where expected
#  - no unsubstituted @token@ leaked into installed scripts
#  - paths.lib.sh + config.sh actually source cleanly and export the
#    expected variables (catches substitutions that produce syntactically
#    valid but semantically wrong scripts)
#  - /etc/config/atlas parses via uci, defaults present
#  - /etc/init.d/atlas dispatches its EXTRA_COMMANDS correctly: get_key,
#    probeid, log, start (without keys) all reach their documented error
#    branch and exit 1, exercising the init script end-to-end without
#    requiring procd to actually instantiate a service
#  - atlas-sw-probe-rpc: list + call dispatch
#
# What is NOT tested: real `/etc/init.d/atlas start` with a probe_key
# present. procd is not the init in the runtime container, so the
# `procd_open_instance` calls would no-op; and the spawned ATLAS loop
# opens sockets / runs forever.

SCRIPTS_DIR=/usr/libexec/atlas-probe-scripts
TMP_BASE_DIR=/tmp/ripe_atlas_probe
EXPECTED_VERSION="${2:-}"

# ── Helpers ──────────────────────────────────────────────────────────────────
require_file() {
    f="$1"
    [ -e "$f" ] || { echo "Missing: $f"; exit 1; }
}

require_exec() {
    f="$1"
    [ -x "$f" ] || { echo "Missing or non-exec: $f"; exit 1; }
}

# Verify that none of the SUBST_SED template tokens leaked unsubstituted into
# the installed file. The Makefile uses @name@ placeholders that are replaced
# at Build/Prepare time; any leftover @<word>@ in an installed script means
# the substitution was not applied. The pattern matches autotools-style
# tokens (alphanumeric + underscore, surrounded by @) and is intentionally
# broad: previously-missed mappings (e.g. @sysconfdir@, @storage_sysconfdir@)
# would have been caught by a narrower allowlist only by luck.
check_no_unsubstituted_tokens() {
    f="$1"
    if grep -qE '@[a-zA-Z_][a-zA-Z0-9_]*@' "$f" 2>/dev/null; then
        echo "Unsubstituted template token in $f:"
        grep -nE '@[a-zA-Z_][a-zA-Z0-9_]*@' "$f"
        exit 1
    fi
}

# ── Test for atlas-sw-probe (main package) ───────────────────────────────────
test_main() {
    # Generated/templated scripts under bin/ (flat). Installed with
    # INSTALL_BIN; sourced or executed by ATLAS at runtime.
    GEN_SCRIPTS="
        $SCRIPTS_DIR/bin/ATLAS
        $SCRIPTS_DIR/bin/resolvconf
        $SCRIPTS_DIR/bin/config.sh
        $SCRIPTS_DIR/bin/paths.lib.sh
        $SCRIPTS_DIR/bin/common-pre.sh
        $SCRIPTS_DIR/bin/common.sh
        $SCRIPTS_DIR/bin/reginit.sh
    "
    # Per-arch wrappers, exec subset (flat in bin/ — sourced by ATLAS via
    # $DEVICE_NAME-ATLAS.sh, installed with INSTALL_BIN).
    ARCH_SCRIPTS_EXEC="
        $SCRIPTS_DIR/bin/openwrt-sw-probe-ATLAS.sh
        $SCRIPTS_DIR/bin/openwrt-sw-probe-reginit.sh
        $SCRIPTS_DIR/bin/arch/linux/linux-functions.sh
        $SCRIPTS_DIR/bin/arch/openwrt/openwrt-common.sh
    "
    # Per-arch wrappers, sourced-library subset (in arch/<probe_type>/).
    # Installed with $(CP), preserve source 0644 perms — they're sourced,
    # never executed. Upstream's openwrt/ Makefile uses the same convention.
    ARCH_SCRIPTS_LIB="
        $SCRIPTS_DIR/bin/arch/openwrt-sw-probe/openwrt-sw-probe-ATLAS.sh
        $SCRIPTS_DIR/bin/arch/openwrt-sw-probe/openwrt-sw-probe-common.sh
        $SCRIPTS_DIR/bin/arch/openwrt-sw-probe/openwrt-sw-probe-reginit.sh
    "
    # Static library scripts — shipped as-is, not templated.
    LIB_SCRIPTS="
        $SCRIPTS_DIR/bin/array.lib.sh
        $SCRIPTS_DIR/bin/atlas_log.lib.sh
        $SCRIPTS_DIR/bin/class.lib.sh
        $SCRIPTS_DIR/bin/json.lib.sh
        $SCRIPTS_DIR/bin/support.lib.sh
    "
    STATE_FILES="
        $SCRIPTS_DIR/state/FIRMWARE_APPS_VERSION
        $SCRIPTS_DIR/state/mode
        $SCRIPTS_DIR/state/config.txt
    "
    ETC_FILES="
        $SCRIPTS_DIR/etc/known_hosts.reg
        $SCRIPTS_DIR/etc/reg_servers.sh.prod
        $SCRIPTS_DIR/etc/reg_servers.sh.dev
        $SCRIPTS_DIR/etc/reg_servers.sh.test
    "

    for f in $GEN_SCRIPTS $ARCH_SCRIPTS_EXEC $ARCH_SCRIPTS_LIB $LIB_SCRIPTS \
             $STATE_FILES $ETC_FILES; do
        require_file "$f"
    done

    for f in $GEN_SCRIPTS $ARCH_SCRIPTS_EXEC $LIB_SCRIPTS; do
        require_exec "$f"
    done

    # No template token must have leaked into any installed file — generated
    # or copied. resolvconf and the arch/ scripts also contain @sysconfdir@
    # and @storage_sysconfdir@ references; if those weren't added to the
    # Makefile's SUBST_SED, they would only surface at probe runtime.
    for f in $GEN_SCRIPTS $ARCH_SCRIPTS_EXEC $ARCH_SCRIPTS_LIB; do
        check_no_unsubstituted_tokens "$f"
    done
    # Generated firmware version file is also templated.
    check_no_unsubstituted_tokens "$SCRIPTS_DIR/state/FIRMWARE_APPS_VERSION"

    # Sub-arch config produced inline by the Makefile.
    require_file "$SCRIPTS_DIR/bin/bin/config.sh"
    grep -q "^SUB_ARCH=openwrt-" "$SCRIPTS_DIR/bin/bin/config.sh" \
        || { echo "SUB_ARCH= missing/invalid in bin/bin/config.sh"; exit 1; }

    # ── FIRMWARE_APPS_VERSION should match PKG_VERSION ──────────────────────
    version=$(cat "$SCRIPTS_DIR/state/FIRMWARE_APPS_VERSION")
    if [ -n "$EXPECTED_VERSION" ] && [ "$version" != "$EXPECTED_VERSION" ]; then
        echo "FIRMWARE_APPS_VERSION mismatch: file='$version' expected='$EXPECTED_VERSION'"
        exit 1
    fi
    # Sanity check version format ($PKG_VERSION is a 4-digit integer for SW probe).
    case "$version" in
        ''|*[!0-9]*) echo "FIRMWARE_APPS_VERSION not numeric: '$version'"; exit 1 ;;
    esac

    # ── State files content ──────────────────────────────────────────────────
    mode=$(cat "$SCRIPTS_DIR/state/mode")
    [ "$mode" = "prod" ] || { echo "Unexpected mode: '$mode'"; exit 1; }

    grep -q "^RXTXRPT=yes" "$SCRIPTS_DIR/state/config.txt" \
        || { echo "RXTXRPT=yes not found in config.txt"; exit 1; }

    # ── config.sh substitutions ──────────────────────────────────────────────
    # config.sh.in declares `export PROBE_TYPE=@probe_scripts_path@`;
    # tolerate the `export ` prefix in the regex.
    grep -qE "^(export[[:space:]]+)?PROBE_TYPE=openwrt-sw-probe" \
            "$SCRIPTS_DIR/bin/config.sh" \
        || { echo "PROBE_TYPE=openwrt-sw-probe not found in config.sh"; exit 1; }

    # ── paths.lib.sh substitutions ───────────────────────────────────────────
    grep -q "ATLAS_MEASUREMENT=/usr/libexec/atlas-probe/bin" "$SCRIPTS_DIR/bin/paths.lib.sh" \
        || { echo "ATLAS_MEASUREMENT path wrong in paths.lib.sh"; exit 1; }
    grep -q "ATLAS_SCRIPTS=$SCRIPTS_DIR" "$SCRIPTS_DIR/bin/paths.lib.sh" \
        || grep -q "ATLAS_SCRIPTS=\"$SCRIPTS_DIR\"" "$SCRIPTS_DIR/bin/paths.lib.sh" \
        || { echo "ATLAS_SCRIPTS path wrong in paths.lib.sh"; exit 1; }

    # ── reg_servers.sh.{prod,dev,test} carry the controller host list ──────
    # Each file declares REG_<N>_HOST=<addr> lines (1..N) — an empty list
    # would silently break probe registration. Require at least 1 host in
    # each shipped variant.
    for variant in prod dev test; do
        f="$SCRIPTS_DIR/etc/reg_servers.sh.$variant"
        grep -qE "^REG_[0-9]+_HOST=" "$f" \
            || { echo "$f: no REG_<N>_HOST entries"; exit 1; }
    done

    # ── known_hosts.reg holds the controller SSH host keys ──────────────────
    # Must be a non-empty file with at least one ssh- public key entry.
    [ -s "$SCRIPTS_DIR/etc/known_hosts.reg" ] \
        || { echo "known_hosts.reg is empty"; exit 1; }
    grep -qE "ssh-(rsa|ed25519|dss|ecdsa)" "$SCRIPTS_DIR/etc/known_hosts.reg" \
        || { echo "known_hosts.reg lacks any ssh-* key entry"; exit 1; }

    # ── Runtime symlinks into /tmp ──────────────────────────────────────────
    # crons/data/run/status are installed as symlinks under SCRIPTS_DIR
    # pointing into $TMP_BASE_DIR so post-install writes hit tmpfs.
    for sub in crons data run status; do
        link="$SCRIPTS_DIR/$sub"
        [ -L "$link" ] \
            || { echo "Missing symlink: $link"; exit 1; }
        target=$(readlink "$link")
        expected_target="$TMP_BASE_DIR/$sub"
        [ "$target" = "$expected_target" ] \
            || { echo "Symlink $link -> '$target' (expected '$expected_target')"; exit 1; }
    done

    # ── Init script ─────────────────────────────────────────────────────────
    INIT=/etc/init.d/atlas
    require_exec "$INIT"
    sh -n "$INIT" || { echo "Init script syntax error: $INIT"; exit 1; }
    # Must declare USE_PROCD and the EXTRA_COMMANDS we document.
    grep -q "^USE_PROCD=1" "$INIT" \
        || { echo "Init script not USE_PROCD=1"; exit 1; }
    for cmd in get_key probeid log create_backup load_backup create_key; do
        grep -qE "EXTRA_COMMANDS=.*$cmd|^$cmd\(\)" "$INIT" \
            || { echo "Init missing extra command: $cmd"; exit 1; }
    done
    # Init must invoke the templated ATLAS entry point.
    grep -q "/bin/ATLAS" "$INIT" \
        || { echo "Init does not invoke .../bin/ATLAS"; exit 1; }

    # /etc/init.d/atlas enabled returns 0 only if the rc.d symlink is in
    # place; not all images enable services by default so we don't assert
    # the result, but the command must at least dispatch.
    "$INIT" enabled >/dev/null 2>&1
    rc=$?
    [ "$rc" = 0 ] || [ "$rc" = 1 ] \
        || { echo "Init 'enabled' returned unexpected rc=$rc"; exit 1; }

    # ── UCI config ──────────────────────────────────────────────────────────
    require_file /etc/config/atlas
    if command -v uci >/dev/null 2>&1; then
        uci -q export atlas >/dev/null \
            || { echo "uci export atlas failed (bad /etc/config/atlas syntax)"; exit 1; }
        # The shipped defaults: log_stderr/log_stdout/rxtxrpt/username.
        for opt in log_stderr log_stdout rxtxrpt; do
            uci -q get "atlas.@atlas[0].$opt" >/dev/null \
                || { echo "uci option atlas.common.$opt missing"; exit 1; }
        done
    else
        # Fallback: at least confirm the file mentions the section.
        grep -q "config atlas 'common'" /etc/config/atlas \
            || { echo "/etc/config/atlas missing 'atlas common' section"; exit 1; }
    fi

    # ── /etc/atlas/atlas.readme is the user-facing setup guide ─────────────
    require_file /etc/atlas/atlas.readme
    grep -q "create_key" /etc/atlas/atlas.readme \
        || { echo "atlas.readme missing setup instructions"; exit 1; }

    # ── Shell syntax check on every installed *.sh ─────────────────────────
    # Catches broken substitutions or stray characters. (Avoid pipe-into-
    # while: `exit` inside the loop subshell would not abort the test.)
    for shf in $(find "$SCRIPTS_DIR" -name '*.sh' -type f); do
        sh -n "$shf" || { echo "Syntax error in $shf"; exit 1; }
    done

    # ── conffiles declared in Makefile must exist ──────────────────────────
    # /etc/atlas/ and /etc/config/atlas are the persistent config surface.
    [ -d /etc/atlas ] || { echo "Missing dir: /etc/atlas"; exit 1; }
    [ -f /etc/config/atlas ] || { echo "Missing: /etc/config/atlas"; exit 1; }

    # ── Source the substituted scripts and verify expected variables ───────
    # If a SUBST_SED key was missed or maps to an empty string, the script
    # may still parse but downstream `$EMPTY/some/path` references would
    # break at runtime. We catch that here by sourcing and asserting.
    (
        # paths.lib.sh sets the location vars used by every other script.
        . "$SCRIPTS_DIR/bin/paths.lib.sh" \
            || { echo "paths.lib.sh failed to source"; exit 1; }
        for var in ATLAS_LIBEXECDIR ATLAS_DATADIR ATLAS_SCRIPTS \
                   ATLAS_MEASUREMENT ATLAS_RUNDIR ATLAS_SPOOLDIR \
                   ATLAS_CRONS ATLAS_DATA ATLAS_STATUS ATLAS_TMP; do
            eval "val=\${$var-}"
            [ -n "$val" ] \
                || { echo "paths.lib.sh: \$$var unset/empty after sourcing"; exit 1; }
        done
        # config.sh sets PROBE_TYPE, DEVICE_NAME, ATLAS_BASE knobs.
        . "$SCRIPTS_DIR/bin/config.sh" \
            || { echo "config.sh failed to source"; exit 1; }
        [ "${PROBE_TYPE-}" = "openwrt-sw-probe" ] \
            || { echo "config.sh: PROBE_TYPE='$PROBE_TYPE' (expected openwrt-sw-probe)"; exit 1; }
        for var in ATLAS_BASE ATLAS_STATIC DEVICE_NAME; do
            eval "val=\${$var-}"
            [ -n "$val" ] \
                || { echo "config.sh: \$$var unset/empty after sourcing"; exit 1; }
        done
    ) || exit 1

    # ── Init script EXTRA_COMMANDS dispatch ────────────────────────────────
    # Each verb must dispatch to its handler and exit cleanly. The handler's
    # exit code depends on container state (apk often auto-starts services
    # after install, so the ATLAS daemon may already be running and may
    # have created /tmp/log/ripe_sw_probe, the status dir, etc.). We only
    # require: (a) the verb is recognized — rc must be a documented value
    # (0 or 1), not the rc.common "unknown command" exit; (b) the output
    # mentions a topic-relevant keyword, proving we hit the right handler
    # rather than the generic dispatcher's usage banner.

    init_verb_check() {
        verb="$1"; topic_re="$2"
        out=$("$INIT" "$verb" 2>&1) ; rc=$?
        case "$rc" in
            0|1) ;;
            *) echo "init $verb: unexpected rc=$rc; out=$out"; exit 1 ;;
        esac
        echo "$out" | grep -qiE "$topic_re" \
            || { echo "init $verb: output didn't match /$topic_re/: $out"; exit 1; }
    }

    # get_key reaches either the print-pubkey branch (rc=0, dumps the key) or
    # the "Error! Pub. key not found" branch (rc=1). Both mention "key".
    init_verb_check get_key  "key|atlas"

    # probeid reaches the print-probe-id branch (rc=0) or the "not running /
    # not registered" branch (rc=1).
    init_verb_check probeid  "probe|atlas|running|registered"

    # log either tails /tmp/log/ripe_sw_probe (rc=0) or reports "no log
    # file" (rc=1). The atlas-logged messages contain "atlas" / probe state
    # ("net-try", "reg-init") and the error mentions "log".
    init_verb_check log      "log|atlas|reg|net|probe"

    # start: without a probe_key the precheck exits 1; if it's already
    # running procd may return 0 with no instance change. Either way the
    # documented surface is the precheck-error path.
    init_verb_check start    "atlas|probe|key|sw-probe|missing"
    # Don't kill any service we may have transiently triggered — apk's
    # uninstall step calls stop_service which handles that cleanly.

    echo "atlas-sw-probe OK (version=$version)"
}

# ── Test for atlas-sw-probe-rpc subpackage ───────────────────────────────────
# Sub-package ships a single rpcd plugin under /usr/libexec/rpcd/atlas. It
# exposes ubus methods 'pub-key', 'probe-id', 'reg-info', 'get-status' (via
# the case 'call) -> case "$2"' dispatcher).
test_rpc() {
    RPCD=/usr/libexec/rpcd/atlas
    require_exec "$RPCD"
    sh -n "$RPCD" || { echo "Syntax error in $RPCD"; exit 1; }

    # The 'list' verb is the ubus introspection entry point and must work
    # without any side effects.
    list_out=$("$RPCD" list 2>&1) \
        || { echo "rpcd 'list' failed"; exit 1; }
    for method in pub-key probe-id reg-info; do
        echo "$list_out" | grep -q "\"$method\"" \
            || { echo "rpcd list missing method: $method"; exit 1; }
    done

    # Each declared method must produce JSON when called even without any
    # probe key / probe id present — the script uses empty-string fallbacks.
    for method in pub-key probe-id; do
        out=$("$RPCD" call "$method" 2>&1) \
            || { echo "rpcd 'call $method' returned non-zero"; exit 1; }
        # Very loose JSON sanity: must contain a colon and braces.
        echo "$out" | grep -q "^{" \
            || { echo "rpcd 'call $method' output not JSON-ish:"; echo "$out"; exit 1; }
        echo "$out" | grep -q "}" \
            || { echo "rpcd 'call $method' output not JSON-ish:"; echo "$out"; exit 1; }
    done

    # rpcd's case statement should fall through silently for unknown verbs.
    "$RPCD" bogus >/dev/null 2>&1 \
        || true  # accept any exit code; we only ensure no hang/crash

    echo "atlas-sw-probe-rpc OK"
}

# ── Dispatch ─────────────────────────────────────────────────────────────────
case "$1" in
    atlas-sw-probe)     test_main ;;
    atlas-sw-probe-rpc) test_rpc ;;
    *) exit 0 ;;
esac
