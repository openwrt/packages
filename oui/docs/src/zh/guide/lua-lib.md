# Lua 辅助库

Oui 框架提供了一些常用的 Lua 辅助函数，方便用户编写接口。

## oui.fs

### writefile

`writefile(path, data, mode)`

这个函数用字符串 `mode` 指定的模式向一个文件写入数据 `data`

mode 字符串可以是下列任意值：

* "w": 写模式（默认）
* "a": 追加模式
* "r+": 更新模式，所有之前的数据都保留
* "w+": 更新模式，所有之前的数据都删除
* "a+": 追加更新模式，所有之前的数据都保留，只允许在文件尾部做写入

```lua
local fs = require 'oui.fs'

fs.writefile('test.txt', 'hello, oui\n')
```

### readfile

`readfile(path, format)`

以指定的格式读取文件

提供的格式有:

* "*a": 读取整个文件(默认)
* "*n": 读取一个数字，根据 Lua 的转换文法，可能返回浮点数或整数。 （数字可以有前置或后置的空格，以及符号。） 只要能构成合法的数字，这个格式总是去读尽量长的串； 如果读出来的前缀无法构成合法的数字 （比如空串，"0x" 或 "3.4e-"）， 就中止函数运行，返回 nil
* "*l": 读取一行并忽略行结束标记
* number: 读取一个不超过这个数量字节数的字符串。如果 number 为零， 它什么也不读，返回一个空串

```lua
local fs = require 'oui.fs'

local data = fs.readfile('test.txt')
```
### dirname

`dirname(path)`

参考 Linux 系统参考手册: dirname(1)

### basename

`basename(path)`

参考 Linux 系统参考手册: basename(1)

### statvfs

`statvfs(path)`

获取文件系统信息。该函数返回三个 `number`，分别表示：总数，可用，已用。单位为 1024 Byte。

```lua
local fs = require 'oui.fs'

local total, avail, used = fs.statvfs('/')
```

### access

`access(path, [mode])`

文件权限检测，返回一个 `boolean` 值。

其中 `mode` 可以是以下任意组合:

* f - 检测文件是否存在（默认）
* x - 检测文件是否可执行
* w - 检测文件是否可写
* r - 检测文件是否可读

```lua
local fs = require 'oui.fs'

if fs.access('test.txt') then
    ...
end
```

### stat

`stat(path)`

获取文件信息，返回一个 `Table`。具有如下属性：

* type - 文件类型
* nlink - 硬件链接数
* uid - 拥有者用户 ID
* gid - 拥有者组 ID
* size - 大小（单位 1024 Byte）

### readlink

`readlink(path)`

获取符号链接所指向的文件路径

### dir

`dir(path)`

遍历目录

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

启动指定的网络接口

### ifdown

`ifdown(ifname)`

关闭指定的网络接口

## oui.md5

### sum

`sum(path)`

计算一个文件的 MD5 值

```lua
local MD5 = require 'oui.md5'

local md5 = MD5.sum('test.bin')
```

### new

返回一个 MD5 上下文

```lua
local MD5 = require 'oui.md5'

local ctx = MD5.new()
ctx.hash('abc')
ctx.hash('123')
local md5 = ctx.done()
```

:::tip
对于只是简单的计算一个字符串的 MD5 值，可以使用 `lua-nginx` 模块提供的 `md5` 函数。

```lua
local md5 = ngx.md5('abc123')
```
:::
