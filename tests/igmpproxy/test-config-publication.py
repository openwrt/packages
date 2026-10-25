#!/usr/bin/env python3
"""Existing init publication fixture with isolated netifd/UCI stubs; no network."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'net/igmpproxy/files/igmpproxy.init'


class Service(unittest.TestCase):
    """Run the complete init script with a reader at each interface lookup."""

    def render(self, *, up='1', down='1', quickleave='1', fail_write=False):
        stubs = r'''
config_load() { :; }
config_get_bool() { eval "$1=\$TEST_QUICKLEAVE"; }
config_get() {
    case "$3" in
        verbose) eval "$1=1";;
        network) eval "$1=\$2";;
        direction)
            case "$2" in
                uplink) eval "$1=upstream";;
                receivers) eval "$1=downstream";;
            esac;;
        altnet|whitelist|zone) eval "$1=";;
        *) return 98;;
    esac
}
config_foreach() {
    case "$2" in
        igmpproxy) "$1" main;;
        phyint) "$1" uplink; "$1" receivers;;
        *) return 99;;
    esac
}
ubus() {
    # A daemon respawn can open the public path at either of these points.
    cat "$TEST_PUBLISHED" > "$TEST_OBSERVATIONS.$network"
    command printf '{}'
}
json_load() { :; }
json_get_var() {
    case "$2" in
        l3_device) eval "$1=test-\$network";;
        up)
            case "$network" in
                uplink) eval "$1=\$TEST_UP";;
                receivers) eval "$1=\$TEST_DOWN";;
            esac;;
        *) return 99;;
    esac
}
append() { eval "$1=\${$1}\ \$2"; }
procd_open_instance() { touch "$TEST_INSTANCE"; }
procd_set_param() { :; }
procd_append_param() { :; }
procd_open_data() { :; }
procd_close_data() { :; }
procd_close_instance() { :; }
json_add_array() { :; }
json_close_array() { :; }
logger() { :; }
if [ "$TEST_FAIL_WRITE" = 1 ]; then
    printf() {
        # Fail one early write; a later successful callback must not hide it.
        if [ "$2" = test-uplink ]; then return 1; fi
        command printf "$@"
    }
fi
start_service
'''
        with tempfile.TemporaryDirectory(prefix='hg-igmp-service-') as tmp:
            path = Path(tmp)
            dest = path / 'public.conf'
            old = 'quickleave\nphyint previous-up upstream\nphyint previous-down downstream\n'
            dest.write_text(old)
            source = SOURCE.read_text().replace('/var/etc/igmpproxy.conf', str(dest))
            source = source.replace('/etc/igmpproxy.conf', str(path / 'compat.conf'))
            script = path / 'service.sh'
            script.write_text(source)
            env = dict(os.environ, TEST_PUBLISHED=str(dest), TEST_OBSERVATIONS=str(path / 'observed'),
                       TEST_INSTANCE=str(path / 'instance'), TEST_UP=up, TEST_DOWN=down,
                       TEST_QUICKLEAVE=quickleave, TEST_FAIL_WRITE=str(int(fail_write)))
            # BusyBox ash is the target shell. Fall back to sh for host-only CI.
            shell = [shutil.which('busybox'), 'sh'] if shutil.which('busybox') else ['sh']
            result = subprocess.run(shell + ['-c', '. "$1"; CONFIGFILE="$TEST_PUBLISHED"; ' + stubs,
                                              'test', str(script)], env=env, capture_output=True, text=True)
            return dict(code=result.returncode, stderr=result.stderr, old=old, public=dest.read_text(),
                        observations=[p.read_text() for p in sorted(path.glob('observed.*'))],
                        instance=(path / 'instance').exists(),
                        leftovers=list(path.glob('public.conf.*')), mode=dest.stat().st_mode & 0o777)

    def test_readers_only_see_complete_previous_generation(self):
        data = self.render()
        self.assertEqual(data['code'], 0, data['stderr'])
        self.assertEqual(data['observations'], [data['old'], data['old']])
        self.assertIn('phyint test-uplink upstream', data['public'])
        self.assertIn('phyint test-receivers downstream', data['public'])
        self.assertTrue(data['instance'])
        self.assertEqual(data['leftovers'], [])
        self.assertEqual(data['mode'], 0o600)

    def test_missing_upstream_does_not_publish_or_start(self):
        self.assert_not_started(self.render(up='0'))

    def test_missing_downstream_does_not_publish_or_start(self):
        self.assert_not_started(self.render(down='0'))

    def assert_not_started(self, data):
        self.assertEqual(data['code'], 0, data['stderr'])
        self.assertFalse(data['instance'])
        self.assertEqual(data['public'], data['old'])
        self.assertEqual(data['leftovers'], [])

    def test_write_failure_preserves_last_complete_generation(self):
        data = self.render(fail_write=True)
        self.assertEqual(data['code'], 1, data['stderr'])
        self.assertFalse(data['instance'])
        self.assertEqual(data['public'], data['old'])
        self.assertEqual(data['leftovers'], [])

    def test_quickleave_off_still_generates_both_interfaces(self):
        data = self.render(quickleave='0')
        self.assertEqual(data['code'], 0, data['stderr'])
        self.assertNotIn('quickleave', data['public'])
        self.assertIn('phyint test-uplink upstream', data['public'])
        self.assertIn('phyint test-receivers downstream', data['public'])
        self.assertTrue(data['instance'])


if __name__ == '__main__':
    unittest.main()
