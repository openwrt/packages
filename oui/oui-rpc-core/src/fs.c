/*
 * MIT License
 *
 * Copyright (c) 2020 Jianhui Zhao <zhaojh329@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include <sys/statvfs.h>
#include <sys/stat.h>
#include <lauxlib.h>
#include <unistd.h>
#include <string.h>
#include <dirent.h>
#include <stdlib.h>
#include <libgen.h>
#include <errno.h>

#include "helper.h"

static int lua_dirname(lua_State *L)
{
    const char *path = luaL_checkstring(L, 1);
    char *buf = strdup(path);

    lua_pushstring(L, dirname(buf));
    free(buf);

    return 1;
}

static int lua_basename(lua_State *L)
{
    const char *path = luaL_checkstring(L, 1);
    char *buf = strdup(path);

    lua_pushstring(L, basename(buf));
    free(buf);

    return 1;
}

/* get filesystem statistics in kibibytes */
static int lua_statvfs(lua_State *L)
{
    const char *path = luaL_checkstring(L, 1);
    struct statvfs s;

    if (statvfs(path, &s)) {
        lua_pushnil(L);
        lua_pushstring(L, strerror(errno));
        return 2;
    }

    /* total bytes */
    lua_pushnumber(L, s.f_blocks * s.f_frsize / 1024.0);

    /* available bytes */
    lua_pushnumber(L, s.f_bavail * s.f_frsize / 1024.0);

    /* used bytes */
    lua_pushnumber(L, (s.f_blocks - s.f_bfree) * s.f_frsize / 1024.0);

    return 3;
}

static int lua_access(lua_State *L)
{
    const char *file = luaL_checkstring(L, 1);
    const char *mode = lua_tostring(L, 2);
    int md = F_OK;

    if (mode) {
        if (strchr(mode, 'x'))
            md |= X_OK;
        else if (strchr(mode, 'w'))
            md |= W_OK;
        else if (strchr(mode, 'r'))
            md |= R_OK;
    }

    lua_pushboolean(L, !access(file, md));

    return 1;
}

/* The size is in kibibytes */
static int lua_stat(lua_State *L)
{
    const char *pathname = luaL_checkstring(L, 1);
    struct stat st;

    if (stat(pathname, &st)) {
        lua_pushnil(L);
        lua_pushstring(L, strerror(errno));
        return 2;
    }

    lua_newtable(L);

    switch (st.st_mode & S_IFMT) {
        case S_IFBLK:
            lua_pushliteral(L, "BLK");
            break;
        case S_IFCHR:
            lua_pushliteral(L, "CHR");
            break;
        case S_IFDIR:
            lua_pushliteral(L, "DIR");
            break;
        case S_IFIFO:
            lua_pushliteral(L, "FIFO");
            break;
        case S_IFLNK:
            lua_pushliteral(L, "LNK");
            break;
        case S_IFREG:
            lua_pushliteral(L, "REG");
            break;
        case S_IFSOCK:
            lua_pushliteral(L, "SOCK");
            break;
        default:
            lua_pushliteral(L, "");
            break;
    }
    lua_setfield(L, -2, "type");

    lua_pushinteger(L, st.st_nlink);
    lua_setfield(L, -2, "nlink");

    lua_pushinteger(L, st.st_uid);
    lua_setfield(L, -2, "uid");

    lua_pushinteger(L, st.st_gid);
    lua_setfield(L, -2, "gid");

    lua_pushnumber(L, st.st_size / 1024.0);
    lua_setfield(L, -2, "size");

    return 1;
}

static int lua_readlink(lua_State *L)
{
    const char *path = luaL_checkstring(L, 1);
    char buf[PATH_MAX] = "";
    ssize_t nbytes;

    nbytes = readlink(path, buf, PATH_MAX);
    if (nbytes < 0) {
        lua_pushnil(L);
        lua_pushstring(L, strerror(errno));
        return 2;
    }

    lua_pushlstring(L, buf, nbytes);

    return 1;
}

static int dir_gc(lua_State *L)
{
    DIR *d = *(DIR **)lua_touserdata(L, 1);

    if (d)
        closedir(d);

    return 0;
}

static const struct luaL_Reg dir_metatable[] =  {
    {"__gc", dir_gc},
    {NULL, NULL}
};

static int dir_iter(lua_State *L)
{
    DIR **d = (DIR **)lua_touserdata(L, lua_upvalueindex(1));
    struct dirent *e;

    if (!*d)
        return 0;

    while ((e = readdir(*d))) {
        if (!strcmp(e->d_name, ".") || !strcmp(e->d_name, ".."))
            continue;
        lua_pushstring(L, e->d_name);
        return 1;
    }

    closedir(*d);

    *d = NULL;

    return 0;
}

static int lua_dir(lua_State *L)
{
    const char *path = luaL_checkstring(L, 1);
    DIR **d = (DIR **)lua_newuserdata(L, sizeof(DIR *));

    lua_pushvalue(L, lua_upvalueindex(1));
    lua_setmetatable(L, -2);

    *d = opendir(path);

    lua_pushcclosure(L, dir_iter, 1);

    return 1;
}

int luaopen_oui_internal_fs(lua_State *L)
{
    lua_newtable(L);

    lua_pushcfunction(L, lua_dirname);
    lua_setfield(L, -2, "dirname");

    lua_pushcfunction(L, lua_basename);
    lua_setfield(L, -2, "basename");

    lua_pushcfunction(L, lua_statvfs);
    lua_setfield(L, -2, "statvfs");

    lua_pushcfunction(L, lua_access);
    lua_setfield(L, -2, "access");

    lua_pushcfunction(L, lua_stat);
    lua_setfield(L, -2, "stat");

    lua_pushcfunction(L, lua_readlink);
    lua_setfield(L, -2, "readlink");

    oui_new_metatable(L, dir_metatable);
    lua_pushcclosure(L, lua_dir, 1);
    lua_setfield(L, -2, "dir");

    return 1;
}
