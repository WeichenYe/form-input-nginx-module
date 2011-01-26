#!/bin/bash

# this file is mostly meant to be used by the author himself.

rm ~/work/nginx-0.8.41/objs/addon/ndk/ndk.o ~/work/nginx-0.8.41/objs/addon/ndk-nginx-module/ndk.o

root=`pwd`
home=~

cd ~/work
version=$1
#opts=$2

if [ ! -s "nginx-$version.tar.gz" ]; then
    wget "http://sysoev.ru/nginx/nginx-$version.tar.gz" -O nginx-$version.tar.gz
    if [ "$?" != 0 ]; then
        echo Abort.
        exit 1;
    fi
    tar -xzvf nginx-$version.tar.gz
    if [ "$?" != 0 ]; then
        echo Abort.
        exit 1;
    fi
    if [ "$version" = "0.8.41" ]; then
        cp $root/../no-pool-nginx/nginx-0.8.41-no_pool.patch ./
        patch -p0 < nginx-0.8.41-no_pool.patch
        if [ "$?" != 0 ]; then
            echo Abort.
            exit 1
        fi
    fi
fi

#tar -xzvf nginx-$version.tar.gz || exit 1
#cp $root/../no-pool-nginx/nginx-$version-no_pool.patch ./ || exit 1
#patch -p0 < nginx-$version-no_pool.patch || exit 1
#patch -p0 < ~/work/nginx-$version-rewrite_phase_fix.patch || exit 1

cd nginx-$version/

if [[ "$BUILD_CLEAN" = 1 || ! -f Makefile || "$root/config" -nt Makefile || "$root/util/build.sh" -nt Makefile ]]; then
    ./configure --prefix=/opt/nginx \
          --with-cc-opt="-O0" \
            --without-mail_pop3_module \
            --without-mail_imap_module \
            --without-mail_smtp_module \
            --without-http_upstream_ip_hash_module \
            --without-http_empty_gif_module \
            --without-http_memcached_module \
            --without-http_referer_module \
            --without-http_autoindex_module \
            --without-http_auth_basic_module \
            --without-http_userid_module \
          --add-module=$root/../echo-nginx-module \
          --add-module=$root/../ndk-nginx-module \
          --add-module=$root/../set-misc-nginx-module \
          --add-module=$root/../array-var-nginx-module \
          --add-module=$root $opts \
          --with-debug
          #--add-module=$home/work/ndk \
  #--without-http_ssi_module  # we cannot disable ssi because echo_location_async depends on it (i dunno why?!)

fi
if [ -f /opt/nginx/sbin/nginx ]; then
    rm -f /opt/nginx/sbin/nginx
fi
if [ -f /opt/nginx/logs/nginx.pid ]; then
    kill `cat /opt/nginx/logs/nginx.pid`
fi
make -j3
make install

