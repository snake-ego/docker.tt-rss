FROM php:fpm-alpine

ENV TTRSS_VERSION=18.12

RUN set -x \
    && apk add --update --no-cache \
    libwebp \
    zlib \
    libjpeg-turbo \
    libpng-dev \
    curl \
    libpq \
    && apk add --update --no-cache --virtual .build-only \
    libwebp-dev \
    zlib-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    curl-dev \
    wget \
    postgresql-dev \
    && docker-php-ext-install \
    pdo \
    json \
    mbstring \
    curl \
    gd \
    pdo_pgsql \
    pgsql \
    posix \
    pcntl\ 
    && apk del .build-only

ADD http://af.it-test.pw/su-exec/alpine/suexec /usr/local/bin/suexec
ADD http://af.it-test.pw/dockerstart/x64/dockerstart /usr/local/bin/dockerstart

RUN set -x \
    && wget -O /tmp/ttrss.tar.gz "https://git.tt-rss.org/fox/tt-rss/archive/${TTRSS_VERSION}.tar.gz" \
    && tar -xzf /tmp/ttrss.tar.gz -C /tmp \
    && mv /tmp/tt-rss/* . \    
    && chmod -R 777 \
    cache/images \
    cache/upload \
    cache/export \
    cache/js \
    feed-icons \
    lock \
    && chmod +x \
    /usr/local/bin/suexec \
    /usr/local/bin/dockerstart \
    && ln -s /usr/local/bin/php /usr/bin/php \
    && mkdir -p /etc/dockerstart/ \
    && echo '{"tasks": [{"name": "web", "command": "php-fpm"}, {"name": "workers", "command": "suexec www-data php update_daemon2.php"}]}'>/etc/dockerstart/config.json

CMD ["dockerstart", "-config", "/etc/dockerstart/config.json"]
