#!/bin/bash
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < /workdir/passwd.template > /tmp/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

envsubst < /workdir/parameters.yml > /var/www/pim-community-standard/app/config/parameters.yml

cp /var/www/pim-community-standard/app/config/parameters.yml /var/www/pim-community-standard/app/config/parameters.yml.dist

sed -i 's#memory_limit = 128M#memory_limit = 1024M#g' /workdir/conf/fpm/php.ini
sed -i 's#;date.timezone =#date.timezone = "'"${TIMEZONE}"'"#g' /workdir/conf/fpm/php.ini



# Check if Akeneo already installed to DB
if [ $(mysql -N -s -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h${MYSQL_HOST} -e \
  "select count(*) from information_schema.tables where \
  table_schema='${MYSQL_DATABASE}' and table_name='pim_versioning_version';") -eq 1 ]; then
  echo "Database already exists"
  (cd /var/www/pim-community-standard; rm -rf ./web/bundles/* ./web/css/* ./web/js/*)
  (cd /var/www/pim-community-standard; php app/console pim:install:assets --env=prod)
  (cd /var/www/pim-community-standard; php app/console assets:install --symlink web)
  (cd /var/www/pim-community-standard; php app/console cache:warmup --env=prod)
else
  echo "Installing Akeneo"
  (cd /var/www/pim-community-standard; php app/console cache:clear --env=prod)
  (cd /var/www/pim-community-standard; php app/console pim:install --env=prod)
fi

php /var/www/pim-community-standard/app/console pim:completeness:calculate --env=prod
php /var/www/pim-community-standard/app/console pim:versioning:refresh --env=prod

exec "/usr/bin/supervisord"
