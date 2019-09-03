#!/bin/sh
set -e

# Installations
if [ ! -f /lock-install ]; then

    if [ ${CONTAINER_ENV} = "prod" ]; then
        # active
        echo "Production"
    fi

    # Installation de composer
    if [ ${CONTAINER_ENV} = "dev" -o ${CONTAINER_ENV} = "build" ]; then
        if [ -f /usr/local/bin/composer ]; then
            composer --self-update
        else
            EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
            php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
            ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

            if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
            then
                >&2 echo 'ERROR: Invalid installer signature'
                rm composer-setup.php
                exit 1
            fi

            php composer-setup.php --install-dir=/usr/local/bin --filename=composer
            rm composer-setup.php
        fi
    fi

    # Installation xdebug
    if [ ${CONTAINER_ENV} = dev ]; then
        echo Installation Xdebug
        echo "zend_extension="`find /usr/local/lib/php/extensions -name 'xdebug.so' 2> /dev/null`"" | tee /usr/local/etc/php/conf.d/xdebug.ini
        # active xdebug
        echo "zend_extension="`find /usr/lib/php -name 'xdebug.so' 2> /dev/null`"" | tee /etc/php/7.1/mods-available/xdebug.ini
        rm -f /etc/php/7.1/fpm/conf.d/20-xdebug.ini
        ln -s /etc/php/7.1/mods-available/xdebug.ini /etc/php/7.1/fpm/conf.d/20-xdebug.ini
        sed -r -i "s/xdebug\.remote_host ?\=.*$/xdebug.remote_host=$(ip route|awk '/default/ { print $3 }')/" /etc/php/7.1/fpm/php.ini.new
    fi;

    # Installation outils console
    if [ ${CONTAINER_ENV} = "dev" ]; then
        echo Installation Outils
        apk add --no-cache vim curl wget bash bash-completion
        wget http://cs.sensiolabs.org/download/php-cs-fixer-v2.phar -O /usr/local/bin/php-cs-fixer
        chmod +x /usr/local/bin/php-cs-fixer
    fi
    echo Fin des installations
    touch /lock-install

fi

echo exec "$@"
exec "$@"
