#!/bin/bash
sed -i 's#memory_limit = 128M#memory_limit = 1024M#g' /workdir/conf/fpm/php.ini
sed -i 's#;date.timezone =#date.timezone = '${TIMEZONE}'#g' /workdir/conf/fpm/php.ini
sed -i 's#memory_limit = 128M#memory_limit = 1024M#g' /workdir/conf/cli/php.ini
sed -i 's#;date.timezone =#date.timezone = '${TIMEZONE}'#g' /workdir/conf/cli/php.ini

envsubst < /workdir/parameters.yml > /var/www/pim-community-standard/app/config/parameters.yml
cp /var/www/pim-community-standard/app/config/parameters.yml /var/www/pim-community-standard/app/config/parameters.yml.dist

if [ -d /var/www/pim-community-standard/app/file_storage/catalog ]; then
  echo "Catalog already exists"
  (cd /var/www/pim-community-standard; php bin/console pim:installer:assets --symlink --clean --env=prod) && \
  (cd /var/www/pim-community-standard; yarn run webpack)
else
  echo "Installing Akeneo"
  (cd /var/www/pim-community-standard; php bin/console cache:clear --no-warmup --env=prod) && \
  (cd /var/www/pim-community-standard; php bin/console pim:installer:assets --symlink --clean --env=prod) && \
  (cd /var/www/pim-community-standard; php bin/console pim:install --force --symlink --clean --env=prod) && \
  (cd /var/www/pim-community-standard; yarn run webpack)
fi

(cd /var/www/pim-community-standard; php bin/console pim:completeness:calculate --env=prod)
(cd /var/www/pim-community-standard; php bin/console pim:versioning:refresh --env=prod)
exec "/usr/bin/supervisord"
