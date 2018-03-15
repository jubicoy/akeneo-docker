#!/bin/bash

php /var/www/pim-community-standard/bin/console pim:completeness:calculate --env=prod
php /var/www/pim-community-standard/bin/console pim:versioning:refresh --env=prod
