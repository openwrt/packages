# Lua auxiliary library

The Oui framework provides some commonly used Lua helper functions to make it easy for users to write API.

## oui.fs

### writefile

`writefile(path, data, mode)`

This function writes data to a file in the `mode` specified by the string mode.

The mode string can be any of the following values:

* "w": Write mode (the default)
* "a": Append mode
* "r+": update mode, all previous data is preserved
* "w+": update mode, all previous data is erased
* "a+": append update mode, previous data is preserved, writing is only allowed at the end of file

```lua
local fs = require 'oui.fs'

fs.writefile('test.txt', 'hello, oui\n')
```

### readfile

`readfile(path, format)`

Reads the file in the specified format

The formats provided are:

* "*a": Read the entire file (the default)
* "*n": reads a numeral and returns it as a float or an integer , following the lexical conventions of Lua. (The numeral may have leading spaces and a sign.) This format always reads the longest input sequence that is a valid prefix for a numeral; if that prefix does not form a valid numeral (e.g., an empty string, "0x", or "3.4e-"), it is discarded and the function returns nil
* "*l": reads the next line skipping the end of line
* number: reads a string with up to this number of bytes. If number is zero, it reads nothing and returns an empty string

```lua
local fs = require 'oui.fs'

local data = fs.readfile('test.txt')
```
### dirname

`dirname(path)`

See Linux manuals: dirname(1)

### basename

`basename(path)`

See Linux manuals: basename(1)

### statvfs

`statvfs(path)`

Obtain the file system information. This function returns three `numbers`, respectively: total, available, used.
The unit is 1024 Byte.

```lua
local fs = require 'oui.fs'

local total, avail, used = fs.statvfs('/')
```

### access

`access(path, [mode])`

File permission check, returns a `Boolean` value.

The `mode` can be any combination of:

* f - Check if the file exists (default)
* x - Check whether the file is executable
* w - Checks whether the file is writable
* r - Check whether the file is readable

```lua
local fs = require 'oui.fs'

if fs.access('test.txt') then
    ...
end
```

### stat

`stat(path)`

Get the file information and return a `Table` with the following attributes:

* type - File type
* nlink - Number of hard links
* uid - User ID of owner
* gid - Group ID of owner
* size - Size(unit: 1024 Byte)

### readlink

`readlink(path)`

Gets the file path to which the symbolic link points

### dir

`dir(path)`

Traversal directory

```lua
local fs = require 'oui.fs'

for name in fs.dir('/') do
    local info = fs.stat('/' .. name)
    print(name, 'size: ' .. info.size ..' KiB')
end
```

## oui.network

### ifup

`ifup(ifname)`

Start the specified network interface

### ifdown

`ifdown(ifname)`

Stop the specified network interface

## oui.md5

### sum

`sum(path)`

Calculate the MD5 value of a file

```lua
local MD5 = require 'oui.md5'

local md5 = MD5.sum('test.bin')
```

### new

Returns an MD5 context

```lua
local MD5 = require 'oui.md5'

local ctx = MD5.new()
ctx.hash('abc')
ctx.hash('123')
local md5 = ctx.done()
```

:::tip
For simply calculating the MD5 value of a string, you can use the `md5` function provided by the `Lua-nginx` module.

```lua
local md5 = ngx.md5('abc123')
```
:::
