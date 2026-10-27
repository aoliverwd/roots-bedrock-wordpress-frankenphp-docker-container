# Run composer to install dependencies
FROM composer:2 AS composer
WORKDIR /app/bedrock
COPY ./bedrock /app/bedrock
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Use dunglas/frankenphp as the base image
FROM dunglas/frankenphp:1.13.4-php8-trixie

# add additional extensions here:
RUN install-php-extensions \
    mysqli
    # gd \
    # imagick \
    # exif \
    # zip \
    # intl

# Copy dependencies
COPY --from=composer /app/bedrock /app/bedrock

# Copy Caddyfile and php.ini
COPY ./config/Caddyfile /etc/frankenphp/Caddyfile
COPY ./config/php.ini /usr/local/etc/php/php.ini

# Suppress deprecations for WP-CLI only
ENV WP_CLI_PHP_ARGS="-d error_reporting=24575"

# Ignore CLI pager
ENV PAGER=cat

# Or install less, terminal pager
# RUN apt-get update && apt-get install -y --no-install-recommends less \
#    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# Install Composer
# RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Tidy up
RUN mv /app/bedrock/wp-cli.yml /app/wp-cli.yml

ARG USER=appuser

# Create non root user, remove default capability and Give write access to /config/caddy and /data/caddy
RUN useradd ${USER} \
    && setcap -r /usr/local/bin/frankenphp \
    && chown -R ${USER}:${USER} /config/caddy /data/caddy

# Set current (non root) user
USER ${USER}
