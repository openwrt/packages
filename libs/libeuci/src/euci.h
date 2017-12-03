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

#ifndef _EUCI_H
#define _EUCI_H

#include <stdlib.h>


/*
 * get the value of an option
 * @package: the name of the package
 * @section: the name of the section
 * @option: the name of the option
 * @buf: the value of the option will be stored in it
 * @size: the maximum size of the buf
 * return 0 for success, or -1 for failure
 */
int euci_get_option(const char *package, const char *section, const char *option, char *buf, int size);

/*
 * get the value of an option from the first section
 * @package: the name of the package
 * @type: the type of the section
 * @option: the name of the option
 * @buf: the value of the option will be stored in it
 * @size: the maximum size of the buf
 * return 0 for success, or -1 for failure
 */
int euci_get_first_option(const char *package, const char *type, const char *option, char *buf, int size);

/*
 * get the value of an option from the last section
 * @package: the name of the package
 * @type: the type of the section
 * @option: the name of the option
 * @buf: the value of the option will be stored in it
 * @size: the maximum size of the buf
 * return 0 for success, or -1 for failure
 */
int euci_get_last_option(const char *package, const char *type, const char *option, char *buf, int size);

/*
 * set the value of an option
 * @package: the name of the package
 * @section: the name of the section
 * @option: the name of the option
 * @value: the value for the option to set, NULL or "" for delete
 * return 0 for success, or -1 for failure
 */
int euci_set_option(const char *package, const char *section, const char *option, const char *value);

/*
 * set the value of an option from the first section
 * @package: the name of the package
 * @type: the type of the section
 * @option: the name of the option
 * @value: the value for the option to set, NULL or "" for delete
 * return 0 for success, or -1 for failure
 */
int euci_set_first_option(const char *package, const char *type, const char *option, const char *value);

/*
 * set the value of an option from the last section
 * @package: the name of the package
 * @type: the type of the section
 * @option: the name of the option
 * @value: the value for the option to set, NULL or "" for delete
 * return 0 for success, or -1 for failure
 */
int euci_set_last_option(const char *package, const char *type, const char *option, const char *value);

static inline int euci_del_option(const char *package, const char *section, const char *option, const char *value)
{
    return euci_set_option(package, section, option, NULL);
}

static inline int euci_del_first_option(const char *package, const char *type, const char *option, const char *value)
{
    return euci_set_first_option(package, type, option, NULL);
}

static inline int euci_del_last_option(const char *package, const char *type, const char *option, const char *value)
{
    return euci_set_last_option(package, type, option, NULL);
}

/*
 * add a new section to package
 * @package: package to add the section to
 * @type: the type of the new section
 * @name: the name of the new section, NULL or "" for anonymous section
 */
int euci_add_section(const char *package, const char *type, const char *name);

/*
 * delete a section from package
 * @package: package to delete the section from
 * @section: the name of the section
 */
int euci_del_section(const char *package, const char *section);

#endif