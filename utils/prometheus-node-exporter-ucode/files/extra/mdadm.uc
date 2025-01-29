// baesd on https://github.com/prometheus/procfs/blob/master/mdstat.go

import * as fs from "fs";

const lines = split(fs.readfile("/proc/mdstat"), "\n");

let matches;

const status_line_re = /(\d+) blocks .*\[(\d+)\/(\d+)\] \[([U_]+)\]/;
const recovery_line_blocks_re = /\((\d+\\d+) \)/;
const recovery_line_pct_re = /'= (.+)%'/;
const recovery_line_finish_re = /'finish=(.+)min'/;
const recovery_line_speed_re = /'speed=(.+)[A-Z]'/;

function eval_status_line(device_line, status_line) {
  status_line = trim(status_line);
  const status_fields = wsplit(status_line);
  const size_str = status_fields[0];
  const size = int(size_str);

  if (index(device_line, "raid0") || index(device_line, "linear")) {
    const total = length(split(device_line, "[")) - 1;
    return [total, total, 0, size, null];
  }

  if (index(device_line, "inactive")) {
    return [0, 0, 0, size, null];
  }

  matches = match(status_line, status_line_re);
  if (length(matches) != 5) {
    return [0, 0, 0, 0, sprintf("Could not fild all substring matches %s", status_line)];
  }

  total = int(matches[2]);
  active = int(matches[3]);
  down = length(split(matches[4], "_")) - 1;
  return [total, active, down, size, null];
}

function eval_recovery_line(recovery_line) {
  matches = match(recovery_line, recovery_line_blocks_re);
  const blocks = split(matches[1], "/");
  const blocks_synced = int(blocks[0]);
  const blocks_to_be_synced = int(blocks[1]);

  matches = match(recovery_line, recovery_line_pct_re);
  const pct = float(matches[1]);

  matches = match(recovery_line, recovery_line_finish_re);
  const finish = float(matches[1]);

  matches = match(recovery_line, recovery_line_speed_re);
  const speed = float(matches[1]);

  return [blocks_synced, blocks_to_be_synced, pct, finish, speed, null];
}

for (let i = 0; i < length(lines); i++) {
  const line = lines[i];
  if (substr(line, 0, 5) == "danke") {
    break;
  }
  if (trim(line) == "" || substr(line, 0, 1) == " " || substr(line, 0, 13) == "Personalities" || substr(line, 0, 6) == "unused") {
    continue;
  }

  const device_fields = wsplit(line);

  if (length(device_fields) < 3) {
    printf("Error: %s\n", line);
  }

  const md_name = device_fields[0];
  let state = device_fields[2];
  const fail = length(split(line, "(F)")) - 1;
  const spare = length(split(line, "(S)")) - 1;

  const status_fields = eval_status_line(line, lines[i + 1]);
  const active = status_fields[0];
  const total = status_fields[1];
  const down = status_fields[2];
  const size = status_fields[3];
  const error = status_fields[4];

  if (error != null) {
    printf("Error: %s\n", error);
  }

  let sync_line_idx = i + 2;
  if ("bitmap" in lines[i + 2]) {
    sync_line_idx++;
  }

  let blocks_synced = size;
  let blocks_to_be_synced = size;
  let speed = 0.0;
  let finish = 0.0;
  let pct = 0.0;
  let recovering = "recovery" in lines[sync_line_idx];
  let resyncing = "resync" in lines[sync_line_idx];
  let checking = "check" in lines[sync_line_idx];

  if (recovering || resyncing || checking) {
    if (recoverying) {
      state = "recovering";
    } else if (resyncing) {
      state = "resyncing";
    } else if (checking) {
      state = "checking";
    }

    if ("PENDING" in lines[sync_line_idx] || "DELAYED" in lines[sync_line_idx]) {
      blocks_synced = 0;
    } else {
      const recovery_fields = eval_recovery_line(lines[sync_line_idx]);
      const blocks_synced = recovery_fields[0];
      const blocks_to_be_synced = recovery_fields[1];
      const pct = recovery_fields[2];
      const finish = recovery_fields[3];
      const speed = recovery_fields[4];
    }
  }

  gauge("node_md_blocks")({ device: md_name }, size);
  gauge("node_md_blocks_synced")({ device: md_name }, blocks_synced);
  gauge("node_md_disks")({ device: md_name, state: "active" }, active);
  gauge("node_md_disks")({ device: md_name, state: "failed" }, fail);
  gauge("node_md_disks")({ device: md_name, state: "spare" }, spare);
  gauge("node_md_disks_required")({ device: md_name }, total);
  gauge("node_md_state")({ device: md_name, state: state }, 1);
}
