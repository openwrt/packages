/*
 * Copyright (C) 2017  Jianhui Zhao <jianhuizhao329@gmail.com>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <string.h>
#include <stdarg.h>
#include <syslog.h>
#include <assert.h>

#include <uci.h>
#include "euci.h"

//#define EUCI_DEBUG

#define __FILENAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)

#define euci_err(format...) __euci_err(__FILENAME__, __LINE__, format)

#define EUCI_ALLOC_CONTEXT                              \
    do {                                                \
        ctx = uci_alloc_context();                      \
        if(!ctx) {                                      \
            euci_err("Failed to alloc uci context");    \
            return -1;                                  \
        }                                               \
    } while(0)

#define EUCI_GET_OPT_INT                                                    \
    char buf[512];                                                          \
    if (euci_get_option(package, section, option, buf, sizeof(buf)) < 0)    \
        return -1

#define EUCI_GET_FIRST_OPT_INT                                                  \
    char buf[512];                                                              \
    if (euci_get_first_option(package, section, option, buf, sizeof(buf)) < 0)  \
        return -1

#define EUCI_GET_LAST_OPT_INT                                                   \
    char buf[512];                                                              \
    if (euci_get_last_option(package, section, option, buf, sizeof(buf)) < 0)   \
        return -1

static void __euci_err(const char *filename, int line, const char *format, ...)
{
    va_list ap;
    static char buf[128];

    snprintf(buf, sizeof(buf), "(%s:%d) ", filename, line);
    
    va_start(ap, format);
    vsnprintf(buf + strlen(buf), sizeof(buf) - strlen(buf), format, ap);
    va_end(ap);
    
    syslog(LOG_ERR, "%s", buf);
	
#ifdef EUCI_DEBUG
	fprintf(stderr, "%s\n", buf);
#endif
}

int euci_get_option(const char *package, const char *section, const char *option, char *buf, int size)
{
    struct uci_context *ctx = NULL;
    struct uci_ptr ptr = {
		.package = package,
		.section = section,
		.option  = option
	};

    assert(package && section && option && buf);
	
    EUCI_ALLOC_CONTEXT;
	
	if (uci_lookup_ptr(ctx, &ptr, NULL, true) || !ptr.o) {
		euci_err("Not found: '%s.%s.%s'", package, section, option);
		goto err;
	}

	if (ptr.o->type != UCI_TYPE_STRING) {
        euci_err("Option '%s.%s.%s' is not a string", package, section, option);
        goto err;
    }

	strncpy(buf, ptr.o->v.string, size);

    uci_free_context(ctx);

    return 0;
	
err:
	uci_free_context(ctx);
    return -1;
}

int euci_get_option_int32(const char *package, const char *section, const char *option, int *value)
{  
    EUCI_GET_OPT_INT;

    *value = atoi(buf);
    return 0;
}

int euci_get_option_uint32(const char *package, const char *section, const char *option, uint32_t *value)
{
    EUCI_GET_OPT_INT;

    *value = (uint32_t)strtoul(buf, NULL, 0);
    return 0;
}

int euci_get_first_option(const char *package, const char *type, const char *option, char *buf, int size)
{
    struct uci_context *ctx = NULL;
    struct uci_package *p = NULL;
    struct uci_element *e;

    assert(package && type && option && buf);
	
    EUCI_ALLOC_CONTEXT;

    uci_load(ctx, package, &p);
    if (!p) {
        euci_err("Failed to load '%s'", package);
        goto err;
    }

    uci_foreach_element(&p->sections, e) {
        struct uci_section *s = uci_to_section(e);
        const char *val;

        if (strcmp(s->type, type))
            continue;
        
        val = uci_lookup_option_string(ctx, s, option);
        if (!val) {
            euci_err("Not found: '%s.@%s[0].%s'", package, type, option);
            goto err;
        }
        
        strncpy(buf, val, size);
        break;
    }

    uci_free_context(ctx);

    return 0;
	
err:
	uci_free_context(ctx);
    return -1;
}

int euci_get_first_option_int32(const char *package, const char *section, const char *option, int *value)
{
    EUCI_GET_FIRST_OPT_INT;

    *value = atoi(buf);
    return 0;
}

int euci_get_first_option_uint32(const char *package, const char *section, const char *option, uint32_t *value)
{
    EUCI_GET_FIRST_OPT_INT;

    *value = strtoul(buf, NULL, 0);
    return 0;
}

int euci_get_last_option(const char *package, const char *type, const char *option, char *buf, int size)
{
    struct uci_context *ctx = NULL;
    struct uci_package *p = NULL;
    struct uci_element *e;
    struct uci_section *s = NULL;
    const char *val;

    assert(package && type && option && buf);
	
    EUCI_ALLOC_CONTEXT;

    uci_load(ctx, package, &p);
    if (!p) {
        euci_err("Failed to load '%s'", package);
        goto err;
    }

    uci_foreach_element(&p->sections, e) {
        struct uci_section *tmps = uci_to_section(e);
        if (strcmp(tmps->type, type))
            continue;        
        s = tmps;
    }

    if (!s) {
        euci_err("Failed to find type: '%s'", type);
        goto err;
    }

    val = uci_lookup_option_string(ctx, s, option);
    if (!val) {
        euci_err("Not found: '%s.@%s[0].%s'", package, type, option);
        goto err;
    }
    
    strncpy(buf, val, size);
        
    uci_free_context(ctx);

    return 0;
	
err:
	uci_free_context(ctx);
    return -1;
}

int euci_get_last_option_int32(const char *package, const char *section, const char *option, int *value)
{
    EUCI_GET_LAST_OPT_INT;

    *value = atoi(buf);
    return 0;
}

int euci_get_last_option_uint32(const char *package, const char *section, const char *option, uint32_t *value)
{
    EUCI_GET_LAST_OPT_INT;

    *value = strtoul(buf, NULL, 0);
    return 0;
}

int euci_set_option(const char *package, const char *section, const char *option, const char *value)
{
	int ret;
    struct uci_context *ctx = NULL;
    struct uci_ptr ptr = {
		.package = package,
		.section = section,
		.option  = option,
		.value = value
	};

    assert(package && section && option);
	
    EUCI_ALLOC_CONTEXT;
	
	if (uci_lookup_ptr(ctx, &ptr, NULL, true) != UCI_OK) {
		euci_err("Failed to find option: '%s'", option);
		goto err;
	}

    if (value && value[0])
	    ret = uci_set(ctx, &ptr);
    else
        ret = uci_delete(ctx, &ptr);
	if(ret && ret != UCI_ERR_NOTFOUND) {
        euci_err("Failed to %s option: '%s'", value ? "set" : "delete", option);
        goto err;
    }

    uci_commit(ctx, &ptr.p, false);
    uci_free_context(ctx);
    return 0;

err:
	uci_free_context(ctx);
    return -1;
}

int euci_set_first_option(const char *package, const char *type, const char *option, const char *value)
{
    int ret;
    struct uci_context *ctx = NULL;
    struct uci_package *p = NULL;
    struct uci_element *e;
    struct uci_ptr ptr = {
		.package = package,
		.option  = option,
		.value = value
	};

    assert(package && type && option);
	
    EUCI_ALLOC_CONTEXT;

    uci_load(ctx, package, &p);
    if (!p) {
        euci_err("Failed to load '%s'", package);
        goto err;
    }

    uci_foreach_element(&p->sections, e) {
        struct uci_section *s = uci_to_section(e);

        if (strcmp(s->type, type))
            continue;

        ptr.section = e->name;
        
        if (value && value[0])
            ret = uci_set(ctx, &ptr);
        else
            ret = uci_delete(ctx, &ptr);
        if(ret && ret != UCI_ERR_NOTFOUND) {
            euci_err("Failed to %s option: '%s'", value ? "set" : "delete", option);
            goto err;
        }
        
        break;
    }

    uci_commit(ctx, &ptr.p, false);
    uci_free_context(ctx);

    return 0;
	
err:
	uci_free_context(ctx);
    return -1;
}

int euci_set_last_option(const char *package, const char *type, const char *option, const char *value)
{
    int ret;
    struct uci_context *ctx = NULL;
    struct uci_package *p = NULL;
    struct uci_element *e = NULL, *tmpe;
    struct uci_ptr ptr = {
		.package = package,
		.option  = option,
		.value = value
	};

    assert(package && type && option);
	
    EUCI_ALLOC_CONTEXT;

    uci_load(ctx, package, &p);
    if (!p) {
        euci_err("Failed to load '%s'", package);
        goto err;
    }

    uci_foreach_element(&p->sections, tmpe) {
        struct uci_section *s = uci_to_section(tmpe);
        if (strcmp(s->type, type))
            continue;
        e = tmpe;
    }

    if (!e) {
        euci_err("Failed to find type: '%s'", type);
        goto err;
    }
    
    ptr.section = e->name;
        
    if (value && value[0])
        ret = uci_set(ctx, &ptr);
    else
        ret = uci_delete(ctx, &ptr);
    if(ret && ret != UCI_ERR_NOTFOUND) {
        euci_err("Failed to %s option: '%s'", value ? "set" : "delete", option);
        goto err;
    }
        
    uci_commit(ctx, &ptr.p, false);
    uci_free_context(ctx);

    return 0;
	
err:
	uci_free_context(ctx);
    return -1;
}

int euci_add_section(const char *package, const char *type, const char *name)
{
    int ret;
    struct uci_context *ctx = NULL;
    struct uci_package *p = NULL;
    struct uci_section *s;
    struct uci_ptr ptr = {
		.package = package,
        .section = name
	};

    assert(package && type);
	
    EUCI_ALLOC_CONTEXT;

    uci_load(ctx, package, &p);
    if (!p) {
        euci_err("Failed to load '%s'", package);
        goto err;
    }

    if (name && name[0]) {  /* Add named section */
        s = uci_lookup_section(ctx, p, name);
        if (s && !strcmp(s->type, type)) {
            euci_err("Failed to add section: '%s' of type '%s', due to a different section with the same name and type already exists",
                name, type);
            goto err;
        }

        ptr.value = type;
        ptr.p = p;

        ret = uci_set(ctx, &ptr);
        if (ret ) {
            euci_err("Failed to add section: '%s' of type '%s'", name, type);
            goto err;
        }
    } else { /* Add anonymous section */
        if (uci_add_section(ctx, p, type, &s) || !s) {
            euci_err("Failed to add section: '%s' of type '%s'", name, type);
            goto err;
        }
    }

    uci_commit(ctx, &p, false);
    uci_free_context(ctx);

    return 0;
err:
    uci_free_context(ctx);
    return -1;
}

int euci_del_section(const char *package, const char *section)
{
    int ret;
    struct uci_context *ctx = NULL;
    struct uci_ptr ptr = {
		.package = package,
		.section = section
	};

    assert(package && section);
	
    EUCI_ALLOC_CONTEXT;
	
	if (uci_lookup_ptr(ctx, &ptr, NULL, true) != UCI_OK) {
		euci_err("Failed to find section: '%s'", section);
		goto err;
	}

    ret = uci_delete(ctx, &ptr);
	if(ret && ret != UCI_ERR_NOTFOUND) {
        euci_err("Failed to delete section: '%s'", section);
        goto err;
    }

    uci_commit(ctx, &ptr.p, false);
    uci_free_context(ctx);
    
    return 0;

err:
	uci_free_context(ctx);
    return -1;    
}

