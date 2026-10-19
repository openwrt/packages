import { readfile } from 'fs';

const source = readfile('/usr/share/rpcd/ucode/mwan3');
const begin = index(source, 'function get_str_raw(');
const end = index(source, 'function get_uptime(');
if (begin < 0 || end <= begin)
	die('Cannot find mwan3 integer helpers\n');
const read_integer = loadstring(substr(source, begin, end - begin) +
	'\nreturn get_int("wan", "SCORE");', { raw_mode: true });

for (let sample in [['', 0], [null, 0], ['\n', 0], ['invalid', 0],
	['0', 0], ['17', 17], ['17\n', 17]]) {
	const actual = call(read_integer, null, { readfile: () => sample[0] });
	if (actual !== sample[1])
		die(sprintf('get_int(%J): expected %d, got %J\n', sample[0], sample[1], actual));
	printf('get_int(%J): %d\n', sample[0], actual);
}
