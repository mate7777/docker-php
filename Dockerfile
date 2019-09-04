FROM php:7.3-fpm-alpine

ENV PS1 '\u@\h:\w\$ '
RUN rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*
RUN apk update
RUN apk --no-cache add icu-dev curl-dev gmp-dev libuv-dev libuv  \
    && docker-php-ext-install pdo intl curl \
    && apk --no-cache add --upgrade icu-libs \
    && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
    && apk del .phpize-deps \
#
COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
#
WORKDIR /var/www/html
#
EXPOSE 9000

ENTRYPOINT ["entrypoint"]

CMD ["php-fpm"]
