# Seafile Server on OpenWrt

## Installation Notes

### First-time Installation

1.  Consider where you would like the Seafile data directory
    (`seafile-data`), Seahub data directory (`seahub-data`), and the
    Seahub database (`seahub.db`, if you will be using SQLite) to be
    stored.

    This location can be configured in `/etc/config/seafile-server`
    (using the _data_dir_ option); the default is `/usr/share/seafile`.

    If you are certain you will use a custom location, set this location
    in `/etc/config/seafile-server` before continuing with the other
    installation steps.

2.  Run one of the two setup scripts:

    *   To use SQLite:

            # setup-seafile

    *   To use MySQL:

            # setup-seafile-mysql

3.  Create a Seafile admin account:

        # create-seafile-admin

4.  Start Seafile server:

        # service seafile-server start


### Upgrading

Please run the appropriate upgrade scripts in
`/usr/share/seafile/seafile-server/upgrade` before using the new
version.

For more information, see
https://download.seafile.com/published/seafile-manual/upgrade/upgrade.md.

Note that since version 7.1, configuration files are stored in
`/etc/seafile` instead of `/usr/share/seafile`.

If you are upgrading from a version before 7.1:

1.  Run the upgrade scripts in
    `/usr/share/seafile/seafile-server/upgrade` up to 7.1.

2.  Move the `conf` and `ccnet` directories from `/usr/share/seafile` to
    `/etc/seafile`.

3.  If you are using a custom Seafile data directory location and have
    set this in `ccnet/seafile.ini`:

    Starting with 7.1, the Seafile data directory location will be taken
    from `/etc/config/seafile-server`, and any setting in
    `ccnet/seafile.ini` will be ignored.

    It is strongly recommended to migrate the custom location setting to
    `/etc/config/seafile-server` and rename/remove the `seafile.ini`
    file.

    Note that the _data_dir_ option in /etc/config/seafile-server
    determines the *parent* path to the Seafile data directory (along
    with the Seahub data directory and the Seahub database, if you are
    using SQLite). The actual Seafile data directory must be named
    `seafile-data`.

    For example, if your Seafile data directory is
    `/srv/seafile/my-seafile-data`:

    1.  Rename the directory to `seafile-data`, so now the Seafile data
        directory is `/srv/seafile/seafile-data`.

    2.  Move the Seahub data directory (`seahub-data`) from
        `/usr/share/seafile` into `/srv/seafile`.

    3.  If you are using SQLite, move the Seahub database (`seahub.db`)
        from `/usr/share/seafile` into `/srv/seafile`.

    4.  Set the _data_dir_ option in `/etc/config/seafile-server` to the
        parent path, `/srv/seafile`.

    5.  Rename or delete `ccnet/seafile.ini`.

4.  Review/update your Seahub settings. In previous versions of the
    Seahub OpenWrt package, some of Seahub's default settings (in
    `/usr/share/seafile/seafile-server/seahub/seahub/settings.py`) were
    modified from the defaults shipped by upstream.

    Starting with 7.1, Seahub's default settings are the same as
    [upstream][seahub_settings], with custom settings added to
    `/etc/seafile/conf/seahub_settings.py` during setup for new
    installations.

    To use the same custom settings in your upgraded installation, add
    these lines to `/etc/seafile/conf/seahub_settings.py`:

        # Custom settings for OpenWrt
        USE_I18N = False
        USER_PASSWORD_MIN_LENGTH = 8
        USER_STRONG_PASSWORD_REQUIRED = True

    [seahub_settings]: https://github.com/haiwen/seahub/blob/v7.1.2-server/seahub/settings.py

5.  Continue running the upgrade scripts up to the new version.


