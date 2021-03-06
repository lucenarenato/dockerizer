FROM alpine:3.7

# Repository/Image Maintainer
LABEL maintainer="geekcom <danielrodrigues-ti@hotmail.com>"

# Env Variables 
ENV OPCACHE_MODE="normal" \
    XDEBUG_ENABLED=false \
    TERM=xterm-256color \
    COLORTERM=truecolor \
    COMPOSER_PROCESS_TIMEOUT=1200 \
    JAVA_HOME=/usr/lib/jvm/default-jvm

# Add the ENTRYPOINT script
ADD start.sh /scripts/start.sh
ADD bashrc /home/phpjasper/.bashrc

# Add openjdk
RUN echo "---> instaling open jdk" && \
    apk add --no-cache openjdk8 && \
    ln -sf "${JAVA_HOME}/bin/"* "/usr/bin/"
    
# Install PHP From DotDeb, Common Extensions, Composer and then cleanup
RUN echo "---> Enabling PHP-Alpine" && \
    apk add --update wget && \
    wget -O /etc/apk/keys/php-alpine.rsa.pub http://php.codecasts.rocks/php-alpine.rsa.pub && \
    echo "@php http://php.codecasts.rocks/v3.7/php-7.2" >> /etc/apk/repositories && \
    apk add --update \
    curl \
    bash \
    fontconfig \
    libxrender \
    libxext \
    imagemagick \
    nano \
    vim \
    git \
    unzip \
    wget \
    make \
    sudo && \
    echo "---> Preparing and Installing PHP" && \
    apk add --update \
    php7@php \
    php7-apcu@php \
    php7-bcmath@php \
    php7-bz2@php \
    php7-calendar@php \
    php7-curl@php \
    php7-ctype@php \
    php7-exif@php \
    php7-fpm@php \
    php7-gd@php \
    php7-gmp@php \
    php7-iconv@php \
    php7-imagick@php \
    php7-imap@php \
    php7-intl@php \
    php7-json@php \
    php7-mbstring@php \
    php7-mysqlnd@php \
    php7-pdo_mysql@php \
    php7-mailparse@php \
    php7-mongodb@php \
    php7-opcache@php \
    php7-pdo_pgsql@php \
    php7-pgsql@php \
    php7-posix@php \
    php7-redis@php \
    php7-soap@php \
    php7-sodium@php \
    php7-sqlite3@php \
    php7-pdo_sqlite@php \
    php7-xdebug@php \
    php7-xml@php \
    php7-xmlreader@php \
    php7-openssl@php \
    php7-phar@php \
    php7-zip@php \
    php7-zlib@php \
    php7-pcntl@php \
    php7-phpdbg@php && \
    sudo ln -s /usr/bin/php7 /usr/bin/php && \
    echo "---> Installing Composer" && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    echo "---> Cleaning up" && \
    rm -rf /tmp/* && \
    echo "---> Adding user" && \
    adduser -D -u 1000 phpjasper && \
    mkdir -p /var/www/app && \
    chown -R phpjasper:phpjasper /var/www && \
    wget -O /tini https://github.com/krallin/tini/releases/download/v0.16.1/tini-static && \
    chmod +x /tini && \
    echo "---> Configuring PHP" && \
    echo "phpjasper  ALL = ( ALL ) NOPASSWD: ALL" >> /etc/sudoers && \
    sed -i "/user = .*/c\user = phpjasper" /etc/php7/php-fpm.d/www.conf && \
    sed -i "/^group = .*/c\group = phpjasper" /etc/php7/php-fpm.d/www.conf && \
    sed -i "/listen.owner = .*/c\listen.owner = phpjasper" /etc/php7/php-fpm.d/www.conf && \
    sed -i "/listen.group = .*/c\listen.group = phpjasper" /etc/php7/php-fpm.d/www.conf && \
    sed -i "/listen = .*/c\listen = [::]:9000" /etc/php7/php-fpm.d/www.conf && \
    sed -i "/;access.log = .*/c\access.log = /proc/self/fd/2" /etc/php7/php-fpm.d/www.conf && \
    sed -i "/;clear_env = .*/c\clear_env = no" /etc/php7/php-fpm.d/www.conf && \
    sed -i "/;catch_workers_output = .*/c\catch_workers_output = yes" /etc/php7/php-fpm.d/www.conf && \
    sed -i "/pid = .*/c\;pid = /run/php/php7.1-fpm.pid" /etc/php7/php-fpm.conf && \
    sed -i "/;daemonize = .*/c\daemonize = yes" /etc/php7/php-fpm.conf && \
    sed -i "/error_log = .*/c\error_log = /proc/self/fd/2" /etc/php7/php-fpm.conf && \
    sed -i "/post_max_size = .*/c\post_max_size = 1000M" /etc/php7/php.ini && \
    sed -i "/upload_max_filesize = .*/c\upload_max_filesize = 1000M" /etc/php7/php.ini && \
    chown -R phpjasper:phpjasper /home/phpjasper && \
    chmod +x /scripts/start.sh && \
    rm -rf /tmp/*

RUN apk --no-cache add msttcorefonts-installer fontconfig --force-broken-world
RUN update-ms-fonts

# Define the running user
USER phpjasper

# Application directory
WORKDIR "/var/www/app"

# Environment variables
ENV PATH=/home/phpjasper/.composer/vendor/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# As non daemon and single base image, it may be used as cli container
CMD ["/bin/bash"]
