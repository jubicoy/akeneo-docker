#!/bin/sh
(cd /var/www/pim-community-standard; rm -rf ./web/bundles/* ./web/css/* ./web/js/*)
(cd /var/www/pim-community-standard; php app/console pim:install:assets --env=prod)
(cd /var/www/pim-community-standard; php app/console assets:install --symlink web)
(cd /var/www/pim-community-standard; php app/console cache:warmup --env=prod)
