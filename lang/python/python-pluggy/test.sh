#!/bin/sh

[ "$1" = "python3-pluggy" ] || exit 0

python3 - << EOF
import sys
import pluggy

version = pluggy.__version__
if version != "$2":
    print("Wrong version: " + version)
    sys.exit(1)

# Define a hookspec and hookimpl
hookspec = pluggy.HookspecMarker("myproject")
hookimpl = pluggy.HookimplMarker("myproject")

class MySpec:
    @hookspec
    def my_hook(self, arg):
        """A hook that returns a value."""

class MyPlugin:
    @hookimpl
    def my_hook(self, arg):
        return arg * 2

# Register and call
pm = pluggy.PluginManager("myproject")
pm.add_hookspecs(MySpec)
pm.register(MyPlugin())

results = pm.hook.my_hook(arg=21)
assert results == [42], f"Expected [42], got {results}"

# Multiple plugins, results collected in LIFO order
class AnotherPlugin:
    @hookimpl
    def my_hook(self, arg):
        return arg + 1

pm.register(AnotherPlugin())
results = pm.hook.my_hook(arg=10)
assert results == [11, 20], f"Expected [11, 20], got {results}"

sys.exit(0)
EOF
