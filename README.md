# akeneo-docker

Akeneo PIM in Docker to be run with Openshift

Environment variables available:
<h1>MYSQL_HOST
MYSQL_PORT
MYSQL_DATABASE
MYSQL_USER
MYSQL_PASSWORD
TIMEZONE (example "Europe/Helsinki")
TASK_xxxx (Job for cron. Start name with TASK_ Example: TASK_print = "* * * * * *|echo 'test print'")
Recommended to use following TASKS at least:
TASK_recalculate_products="0 15 * * * *|php /var/www/pim-community-standard/app/console pim:completeness:calculate --env=prod"
TASK_process_versions="0 15 * * * *|php /var/www/pim-community-standard/app/console pim:versioning:refresh --env=prod"

