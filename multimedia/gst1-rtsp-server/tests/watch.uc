import { pipe } from 'fs';
import * as uloop from 'uloop';
import { watcher_create, QUIET_MS } from '../files/watch.uc';

function monotonic_ms() {
	let value = clock(true);
	return value[0] * 1000 + int(value[1] / 1000000);
}

uloop.init();
let started = pipe(), release = pipe();
let scans = 0, applies = 0, last_event = monotonic_ms();
let watcher = watcher_create(function() {
	started[1].write('s');
	started[1].flush();
	assert(release[0].read(1) == 'r');
	return { camera: 'stable-camera' };
}, function(result) {
	assert(scans == 2);
	assert(monotonic_ms() - last_event >= QUIET_MS);
	assert(result.camera == 'stable-camera');
	applies++;
	uloop.end();
}, () => 'unchanged-topology');
let handle = uloop.handle(started[0], function() {
	assert(started[0].read(1) == 's');
	scans++;
	if (scans == 1) {
		last_event = monotonic_ms();
		watcher.event();
	}
	release[1].write('r');
	release[1].flush();
}, uloop.ULOOP_READ);
watcher.event();
uloop.run();
assert(scans == 2 && applies == 1);
watcher.stop();
handle.delete();
for (let file in [...started, ...release])
	file.close();
print('15-second quiet period and in-flight scan invalidation passed\n');
