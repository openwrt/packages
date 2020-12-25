#include <errno.h>
#include <stdio.h>

#include "utils/common/common.h"

#include "configfile.h"
#include "plugin.h"

static char *dhcp_lease_file;

static const char *config_keys[] = {
    "Path",
};
static int config_keys_num = STATIC_ARRAY_SIZE(config_keys);

/* copied from ping.c plugin */
static int config_set_string(const char *name, /* {{{ */
                             char **var, const char *value) {
  char *tmp;

  tmp = strdup(value);
  if (tmp == NULL) {
    ERROR("dhcpleases plugin: Setting `%s' to `%s' failed: strdup failed: %s", name,
          value, STRERRNO);
    return 1;
  }

  if (*var != NULL)
    free(*var);
  *var = tmp;
  return 0;
} /* }}} int config_set_string */

static int dhcpleases_config(const char *key, const char *value) {
  if (strcasecmp(key, "Path") == 0) {
    int status = config_set_string(key, &dhcp_lease_file, value);
    if (status != 0)
      return status;
  }
  return 0;
}

static void dhcpleases_submit(gauge_t counter) {
  value_list_t vl = VALUE_LIST_INIT;
  value_t values[] = {
      {.gauge = counter},
  };

  vl.values = values;
  vl.values_len = STATIC_ARRAY_SIZE(values);

  sstrncpy(vl.plugin, "dhcpleases", sizeof(vl.plugin));
  sstrncpy(vl.type, "count", sizeof(vl.type));

  plugin_dispatch_values(&vl);
}

static int dhcp_leases_read(void) {

  FILE *fh;
  char buffer[1024];
  gauge_t count = 0;

  if ((fh = fopen(dhcp_lease_file, "r")) == NULL) {
    WARNING("interface plugin: fopen: %s", STRERRNO);
    return -1;
  }

  while (fgets(buffer, 1024, fh) != NULL) {
    count++;
  }
  fclose(fh);

  dhcpleases_submit(count);

  return 0;
}

void module_register(void) {
  plugin_register_config("dhcpleases", dhcpleases_config, config_keys,
                         config_keys_num);
  plugin_register_read("dhcpleases", dhcp_leases_read);
}
