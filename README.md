# akeneo-docker

Akeneo PIM in Docker to be run with Openshift

Environment variables available:
<h5>MYSQL_HOST
<h5>MYSQL_PORT
<h5>MYSQL_DATABASE
<h5>MYSQL_USER
<h5>MYSQL_PASSWORD
<h5>TIMEZONE (example "Europe/Helsinki")
<h5>TASK_xxxx
(Job for cron. Start name with TASK_ Example: TASK_print = "* * * * * *|echo 'test print'")
<h6>Recommended to use following TASKS at least:
<h6>TASK_recalculate_products="0 15 * * * *|php /var/www/pim-community-standard/app/console pim:completeness:calculate --env=prod"
<h6>TASK_process_versions="0 15 * * * *|php /var/www/pim-community-standard/app/console pim:versioning:refresh --env=prod"
