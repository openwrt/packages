#!/usr/bin/env ucode
// SPDX-License-Identifier: Apache-2.0
'use strict';

// The Telegram bot daemon (package trafficctl-telegram), run by
// /etc/init.d/trafficctl-telegram. A process of its own rather than a CLI
// command: the CLI imports every backend module, and the bot stays resident.
// `trafficctl telegram` runs this file.

import { run } from 'trafficctl.telegram';

exit(run());
