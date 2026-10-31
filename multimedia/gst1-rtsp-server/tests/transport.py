#!/usr/bin/env python3
import json
import os
from pathlib import Path
import subprocess

import gi

gi.require_version('Gst', '1.0')
gi.require_version('GstApp', '1.0')
gi.require_version('GstRtspServer', '1.0')
from gi.repository import GLib, Gst, GstRtspServer

Gst.init(None)
TEST_TIMEOUT_SECONDS = 15
module_path = Path(__file__).resolve().parents[1] / 'files' / 'model.uc'


def model_call(function, options):
    script = (
        f'import {{ {function} }} from {json.dumps(str(module_path))}; '
        f'print({function}(json(ARGV[0]), {{}}, {{}}));'
    )
    return subprocess.check_output(
        [os.environ.get('UCODE', 'ucode'), '-e', script, json.dumps(options)],
        text=True,
    )


def codec_check(codec, encoder, depayloader):
    loop = GLib.MainLoop()
    pipelines = []
    errors = []
    frames = []

    def message_receive(bus, message):
        if message.type == Gst.MessageType.ERROR:
            errors.append(str(message.parse_error()))
            loop.quit()

    def sample_receive(sink):
        sample = sink.emit('pull-sample')
        frames.append(sample.get_caps().to_string())
        if len(frames) >= 3:
            GLib.idle_add(loop.quit)
        return Gst.FlowReturn.OK

    def pipeline_start(launch, observer=False):
        pipeline = Gst.parse_launch(launch)
        if observer:
            pipeline.get_by_name('observer').connect('new-sample', sample_receive)
        bus = pipeline.get_bus()
        bus.add_signal_watch()
        bus.connect('message', message_receive)
        pipelines.append(pipeline)
        assert pipeline.set_state(Gst.State.PLAYING) != Gst.StateChangeReturn.FAILURE

    def timeout_fail():
        errors.append(f'{codec}: RTSP test exceeded {TEST_TIMEOUT_SECONDS} seconds')
        loop.quit()
        return GLib.SOURCE_REMOVE

    server = GstRtspServer.RTSPServer()
    server.set_address('127.0.0.1')
    server.set_service('0')
    factory = GstRtspServer.RTSPMediaFactory()
    stream_name = f'test_{os.getpid()}_{codec}'
    factory.set_launch(model_call('receiver_build', {'.name': stream_name, 'codec': codec}))
    factory.set_shared(True)
    server.get_mount_points().add_factory('/test', factory)
    source = server.attach(None)
    assert source, 'Cannot bind RTSP listener'
    options = {
        'source': 'videotestsrc',
        'source_properties': 'is-live=true name="camera with  two spaces"',
        'codec': codec,
        'encoder': encoder,
        'width': 320,
        'height': 240,
        'framerate': '30/1',
        'pixel_format': 'I420',
    }
    if codec != 'mjpeg':
        options['keyframe_interval'] = 30
    producer = model_call('source_build', options)
    producer += ' ! ' + model_call('encoding_build', options)
    producer += ' ! ' + model_call('sender_build', {'.name': stream_name})
    command = json.loads(model_call('launch_argv', producer))
    command[command.index('-q')] = '-m'
    capture = subprocess.Popen(command, stdout=subprocess.PIPE, text=True)
    for message in capture.stdout:
        if ('from element "pipeline0" (state-changed)' in message and
                'new-state=(GstState)playing' in message):
            break
    else:
        raise AssertionError(f'{codec}: capture did not enter PLAYING')
    pipeline_start(
        f'rtspsrc location=rtsp://127.0.0.1:{server.get_bound_port()}/test '
        f'protocols=tcp latency=0 ! {depayloader} ! decodebin ! '
        'appsink name=observer emit-signals=true sync=false',
        observer=True,
    )
    timeout = GLib.timeout_add_seconds(TEST_TIMEOUT_SECONDS, timeout_fail)
    loop.run()
    if not errors:
        GLib.source_remove(timeout)
    for pipeline in reversed(pipelines):
        pipeline.set_state(Gst.State.NULL)
        pipeline.get_bus().remove_signal_watch()
    capture.terminate()
    capture_status = capture.wait()
    capture.stdout.close()
    GLib.source_remove(source)
    assert not errors, errors
    assert capture_status in (0, -15), capture_status
    assert len(frames) >= 3, frames
    assert all('width=(int)320' in caps and 'height=(int)240' in caps for caps in frames)
    print(f'{codec}: generated Unix FD handoff and RTSP client decoding passed')


for codec, encoder, depayloader in [
    ('mjpeg', 'jpegenc', 'rtpjpegdepay'),
    ('h264', 'openh264enc', 'rtph264depay'),
    ('h265', 'x265enc', 'rtph265depay'),
]:
    codec_check(codec, encoder, depayloader)
