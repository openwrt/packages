import * as uloop from 'uloop';

export const QUIET_MS = 15000;

export function watcher_create(scan, apply, stamp) {
	let generation = 0, pending, worker, timer;
	function schedule() {
		generation++;
		pending = true;
		timer.set(QUIET_MS);
	}
	function start() {
		if (worker)
			return;
		let scan_generation = generation, topology = stamp();
		pending = false;
		worker = uloop.task(function() {
			try {
				return { inventory: scan() };
			} catch (e) {
				return { error: '' + e };
			}
		}, function(result) {
			worker = null;
			if (scan_generation != generation) {
				if (pending && timer.remaining() < 0)
					timer.set(0);
				return;
			}
			if (topology != stamp()) {
				schedule();
				return;
			}
			if (result.error) {
				warn('gst-rtsp discovery: ', result.error, '\n');
				return;
			}
			try {
				apply(result.inventory);
			} catch (e) {
				warn('gst-rtsp configuration: ', e, '\n');
			}
		});
		if (!worker)
			die('Cannot start video discovery task\n');
	}
	timer = uloop.timer(-1, start);
	return {
		event: schedule,
		stop: function() {
			timer.cancel();
			if (worker)
				worker.kill();
		}
	};
};
