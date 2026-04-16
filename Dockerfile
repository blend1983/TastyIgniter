FROM dunglas/frankenphp:latest-php8.3

# Install system dependencies required for PHP extensions
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    unzip \
    git \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Install required PHP extensions
RUN docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        intl \
        pdo \
        pdo_mysql \
        curl \
        mbstring \
        xml \
        dom \
        fileinfo \
        ctype \
        zip \
        bcmath \
        opcache \
        gd \
        exif

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy application files
COPY . .

# Install PHP dependencies (production, no dev)
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --prefer-dist

# Run database migrations at build time
RUN php artisan migrate --force

# Set correct permissions for Laravel storage and cache
RUN mkdir -p storage/framework/{sessions,views,cache} \
    && mkdir -p storage/logs \
    && mkdir -p bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Set up the Laravel scheduler cron job (runs every minute as www-data)
RUN echo "* * * * * www-data php /app/artisan schedule:run >> /var/log/scheduler.log 2>&1" \
    > /etc/cron.d/tastyigniter-scheduler \
    && chmod 0644 /etc/cron.d/tastyigniter-scheduler \
    && crontab /etc/cron.d/tastyigniter-scheduler

# Copy and set up the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose port 80 (FrankenPHP default)
EXPOSE 80

# Set the document root to the Laravel public directory
ENV SERVER_NAME=":80"
ENV FRANKENPHP_CONFIG="worker ./public/index.php"

# Start FrankenPHP
CMD ["/usr/local/bin/docker-entrypoint.sh"]
