FROM php:7.2-fpm

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN curl -OL https://github.com/phpmetrics/PhpMetrics/releases/download/v2.3.2/phpmetrics.phar && \
    chmod +x phpmetrics.phar && \
    mv phpmetrics.phar /usr/local/bin/phpmetrics

RUN curl -OL http://www.phpdoc.org/phpDocumentor.phar && \
    chmod +x phpDocumentor.phar && \
    mv phpDocumentor.phar /usr/local/bin/phpdoc

RUN apt-get update \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_enable_trigger=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_output_dir=/app/profiling" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN echo "date.timezone=Europe/London" > /usr/local/etc/php/conf.d/zz-custom.ini \
    && echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/zz-custom.ini \
    && echo "display_errors = on" >> /usr/local/etc/php/conf.d/zz-custom.ini \
    && echo "session.autostart=0" >> /usr/local/etc/php/conf.d/zz-custom.ini

ENV PATH "$PATH:/var/www/html/vendor/bin"
RUN apt-get update \
    && apt-get install git zip libpq-dev zlib1g-dev libicu-dev g++ -y \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl mysqli pdo pdo_mysql pdo_pgsql pgsql sockets

RUN apt-get update \
        && apt-get install -y --no-install-recommends \
                ed \
                less \
                locales \
                vim-tiny \
                wget \
                ca-certificates \
                fonts-texgyre \
        && rm -rf /var/lib/apt/lists/*

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
        && locale-gen en_US.utf8 \
        && /usr/sbin/update-locale LANG=en_US.UTF-8

RUN apt-get update && apt-get install zip

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
