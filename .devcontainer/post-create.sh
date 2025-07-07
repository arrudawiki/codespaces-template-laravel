#!/bin/bash

echo '=== Starting Laravel Setup ===' > /workspaces/codespaces-template-laravel-priv/setup-status.log
composer install && echo '✓ PHP Dependencies installed' >> /workspaces/codespaces-template-laravel-priv/setup-status.log
npm install && echo '✓ Frontend Dependencies installed' >> /workspaces/codespaces-template-laravel-priv/setup-status.log

if [ ! -f .env ]; then
    cp .env.example .env
    sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=mysql/' .env
    sed -i 's/^# DB_HOST=.*/DB_HOST=mysql/' .env
    sed -i 's/^# DB_PORT=.*/DB_PORT=3306/' .env
    sed -i 's/^# DB_DATABASE=.*/DB_DATABASE=laravel/' .env
    sed -i 's/^# DB_USERNAME=.*/DB_USERNAME=laravel/' .env
    sed -i 's/^# DB_PASSWORD=.*/DB_PASSWORD=secret/' .env
    php artisan key:generate > /dev/null && echo '✓ Environment configured' >> /workspaces/codespaces-template-laravel-priv/setup-status.log
else
    echo '✓ Using existing environment' >> /workspaces/codespaces-template-laravel-priv/setup-status.log
fi

echo '⏳ Waiting for database...' >> /workspaces/codespaces-template-laravel-priv/setup-status.log
for i in {1..45}; do 
    mysql -h mysql -u laravel -psecret -e 'SELECT 1' &> /dev/null && { 
        echo '✓ Database connection established' >> /workspaces/codespaces-template-laravel-priv/setup-status.log
        break
    }
    sleep 2
done

echo '⏳ Checking database readiness...' >> /workspaces/codespaces-template-laravel-priv/setup-status.log
mysql -h mysql -u laravel -psecret -e 'CREATE DATABASE IF NOT EXISTS laravel' &> /dev/null
sleep 3
php artisan config:clear > /dev/null
php artisan cache:clear > /dev/null
echo '⏳ Verifying database...' >> /workspaces/codespaces-template-laravel-priv/setup-status.log
if php artisan migrate:status 2> /dev/null | grep -q 'Migration table not found' || php artisan migrate:status 2> /dev/null | grep -q 'No migrations found'; then 
    echo '⏳ Running initial migrations...' >> /workspaces/codespaces-template-laravel-priv/setup-status.log
    php artisan migrate --no-interaction --force >> /workspaces/codespaces-template-laravel-priv/setup-status.log 2>&1 && echo '✓ Initial migrations completed' >> /workspaces/codespaces-template-laravel-priv/setup-status.log || echo '✗ Migration failed - see details above' >> /workspaces/codespaces-template-laravel-priv/setup-status.log
else 
    echo '⏳ Running migrations (if needed)...' >> /workspaces/codespaces-template-laravel-priv/setup-status.log
    php artisan migrate --no-interaction --force >> /workspaces/codespaces-template-laravel-priv/setup-status.log 2>&1 && echo '✓ Migrations up to date' >> /workspaces/codespaces-template-laravel-priv/setup-status.log || echo '✗ Migration failed - see details above' >> /workspaces/codespaces-template-laravel-priv/setup-status.log
fi
echo '=== Setup Complete! ===' >> /workspaces/codespaces-template-laravel-priv/setup-status.log
