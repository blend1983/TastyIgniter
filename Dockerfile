FROM dunglas/frankenphp:latest-php8.3

# Install system dependencies required for PHP extensions
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install required PHP extensions
RUN docker-php-ext-configure intl \
    && docker-php-ext-install \
        intl \
        pdo \
        pdo_mysql \
        curl \
        mbstring \
        xml \
        dom \
        fileinfo \
        tokenizer \
        ctype \
        zip \
        bcmath \
        opcache

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

# Set correct permissions for Laravel storage and cache
RUN mkdir -p storage/framework/{sessions,views,cache} \
    && mkdir -p storage/logs \
    && mkdir -p bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Expose port 80 (FrankenPHP default)
EXPOSE 80

# Set the document root to the Laravel public directory
ENV SERVER_NAME=":80"
ENV FRANKENPHP_CONFIG="worker ./public/index.php"

CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
