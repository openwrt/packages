# fcgiwrap for OpenWrt


This package is for setting up a git/gitweb server for OpenWrt,
it use nginx as web server to provide git service and web browser
for your git projects.

## Install GIT and gitweb in OpenWrt



### Change the default web service ports

To support SSL and git service, we have to use nginx instead of the
OpenWrt's default web server uhttpd due to its limitations. The git
service will use 80 and 443 port, so we need to move the OpenWrt
config interface to another port.

In the file /etc/config/uhttpd, we change the port numbers:

    list listen_http '0.0.0.0:1080'
    list listen_http '[::]:1080'
    list listen_https '0.0.0.0:1443'
    list listen_https '[::]:1443'

and then restart the service:

    /etc/init.d/uhttpd restart

### Compile the fcgiwrap package

To compile the binary package, you may use the SDK package for your router platform,
or compile it from the source code of ![Original OpenWrt](https://openwrt.org/)
or ![Lede-Project](https://lede-project.org/).


Suppose you use SDK, so you need to uncompress the package first, and then enter the
directory:

    ./scripts/feeds update -a
    ./scripts/feeds install -a

and then you need to make sure there exist fcgiwrap feed:

    ls package/feeds/packages/fcgiwrap

If NOT, you need to download the fcgiwrap for OpenWrt by manual:

    git clone https://github.com/yhfudev/openwrt-fcgiwrap.git package/feeds/packages/fcgiwrap

Next step is to compile the binary package:

    make package/feeds/packages/fcgiwrap/compile

The binary is locate in sub directory `bin`,

    find bin

### Compile nginx with ssl support

If your git service need supports SSL, you need also re-compile the SSL version of nginx for OpenWrt.

    ./scripts/feeds update -a
    ./scripts/feeds install -a
    make ./package/feeds/packages/nginx/compile

### Configure

#### setup SSL for nginx server

The suggest config for SSL is following

    server {
        listen 443 ssl;
        server_name your_domain.com;
        ssl_certificate /etc/nginx/ssl/nginx.crt;
        ssl_certificate_key /etc/nginx/ssl/nginx.key;
        ssl_session_timeout 5m;
        ssl_protocols        TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers          HIGH:!ADH:!MD5;
        ssl_prefer_server_ciphers on;
        ...
    }

Build CA

    opkg install openssl-util

    mkdir -p /etc/nginx/ssl
    cd /etc/nginx/ssl

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt

    /etc/init.d/nginx restart

#### config git server

Install packages

    #opkg update
    opkg install git-http #git-gitweb

setup the nginx in the config file /etc/nginx/nginx.conf:

    server {
            ...

            auth_basic           "RESTRICTED ACCESS";
            auth_basic_user_file /etc/nginx/access_list;

            # static repo files for cloning over https
            location ~ ^.*\.git/objects/([0-9a-f]+/[0-9a-f]+|pack/pack-[0-9a-f]+.(pack|idx))$ {
                root /home/git;
            }

            # requests that need to go to git-http-backend
            location ~ .*\.git/(HEAD|info/refs|objects/info/.*|git-(upload|receive)-pack)$ {
                root /home/git;

                #fastcgi_pass  unix:/tmp/fcgiwrap.socket;
                fastcgi_pass 127.0.0.1:12345;
                fastcgi_param QUERY_STRING $query_string;
                fastcgi_param SCRIPT_FILENAME   /usr/lib/git-core/git-http-backend;
                fastcgi_param PATH_INFO         $uri;
                fastcgi_param GIT_PROJECT_ROOT  /home/git/repositories;
                fastcgi_param GIT_HTTP_EXPORT_ALL true;
                fastcgi_param REMOTE_USER $remote_user;
                include fastcgi_params;
            }

            # Remove all conf beyond if you don't want Gitweb
            try_files $uri @gitweb;
            location @gitweb {
                #fastcgi_pass  unix:/tmp/fcgiwrap.socket;
                fastcgi_pass 127.0.0.1:12345;
                fastcgi_param SCRIPT_FILENAME   /www/cgi-bin/gitweb.cgi;
                fastcgi_param PATH_INFO         $uri;
                fastcgi_param GITWEB_CONFIG     /etc/gitweb.conf;
                include fastcgi_params;
        }

        ...
    }

For a large GIT repo, you need setup the memory for the nginx:

    http {
        client_body_in_file_only clean;
        client_body_buffer_size 128k;
        #client_max_body_size 300M;
        client_max_body_size 0;
        ...
    }

#### setup gitweb

In the file /etc/gitweb.conf:

    our $projectroot = "/home/git/repositories";
    our @git_base_url_list = qw(https://git.example.com);

create user list:

    # add a username to the file
    GITUSER=sammy
    sudo sh -c "echo -n '${GITUSER}:' >> /etc/nginx/access_list"

    # add an encrypted password entry for the username
    sudo sh -c "openssl passwd -apr1 >> /etc/nginx/access_list"


#### Prepare a git repo

create user git, create a example repo

    opkg install bash screen
    useradd -m git
    su - git
    mkdir -p /home/git/repositories

    # create repo from an existing directory
    git clone --bare git-example-repo /home/git/repositories/git-example-repo.git
    # OR create a new one:
    git init --bare git-example-repo.git

    cd /home/git/repositories/git-example-repo.git
    sudo chmod -R g+ws .    # Setting necessary rights for pushing to the repository.
    sudo chgrp -R git .

    git --bare update-server-info

    cp hooks/post-update.sample hooks/post-update
    # or
    echo "exec git update-server-info" > hooks/post-update

    chmod a+x hooks/post-update

    # create description file
    cat << EOF > description
    project description
    EOF
