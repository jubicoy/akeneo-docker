FROM jubicoy/nginx-php:php7.1

ENV AKENEO_VERSION v2.1

RUN apt-get update && apt-get -y install \
    mysql-client wget golang-go git vim \
    php7.1-bcmath php7.1-dev php7.1-cli \
    php7.1-curl php7.1-gd php7.1-intl \
    php7.1-mcrypt php7.1-mysql php7.1-soap \
    php7.1-xml php7.1-zip php7.1-imagick && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pecl install apcu && pecl install apcu_bc

RUN wget https://nodejs.org/dist/v8.9.4/node-v8.9.4-linux-x64.tar.xz -P /workdir/ && \
  tar -xf /workdir/node-v8.9.4-linux-x64.tar.xz && \
  cp -R /workdir/node-v8.9.4-linux-x64/* /usr && \
  npm i -g yarn && rm -rf /workdir/node-v*

RUN wget http://download.akeneo.com/pim-community-standard-${AKENEO_VERSION}-latest.tar.gz -P /workdir/ && \
  tar -zxvf /workdir/pim-community-standard-${AKENEO_VERSION}-latest.tar.gz -C /var/www/ && \
  rm -rf /workdir/*.tar.gz  /tmp/* /var/tmp/*

ADD . /tmp/

RUN echo "extension=apcu.so" > /etc/php/7.1/cli/conf.d/20-apcu.ini && \
  echo "extension=apcu.so" > /etc/php/7.1/fpm/conf.d/20-apcu.ini && \
  (cd /var/www/pim-community-standard; patch -p1 < /tmp/mysql.patch) && \
  rm -fv /etc/nginx/conf.d/default.conf && \
  mv /tmp/conf/default.conf /etc/nginx/conf.d/default.conf && \
  mv /tmp/conf/parameters.yml /workdir/parameters.yml && \
  mv /tmp/conf/z_akeneo-job-queue.conf /etc/supervisor/conf.d/ && \
  mv /tmp/conf/z_go_cron.conf /etc/supervisor/conf.d/ && \
  (cd /var/www/pim-community-standard; php -d memory_limit=3G ../composer.phar install --optimize-autoloader --prefer-dist) && \
  (cd /var/www/pim-community-standard; yarn install) && \
  rm -fv /var/www/pim-community-standard/app/config/parameters.yml && \
  rm -fv /var/www/pim-community-standard/app/config/parameters.yml.dist && \
  mkdir -p /workdir/conf/fpm && mv /etc/php/7.1/fpm/php.ini /workdir/conf/fpm/php.ini && \
  ln -s /workdir/conf/fpm/php.ini /etc/php/7.1/fpm/php.ini && \
  mkdir -p /workdir/conf/cli && mv /etc/php/7.1/cli/php.ini /workdir/conf/cli/php.ini && \
  ln -s /workdir/conf/cli/php.ini /etc/php/7.1/cli/php.ini && \
  cp -R /tmp/app /usr/src/cron && \
  mv /tmp/build.sh /opt/build.sh && \
  /opt/build.sh && \
  cp /tmp/start-cmd /opt/bin/start-cmd && \
  chmod -R a+rw /var/www && \
  chmod g+rw /workdir && \
  chmod 777 -R /workdir/conf/* && \
  cp /tmp/repair.sh /workdir && \
  cp /tmp/akeneo_scheduled_tasks.sh /workdir/ && \
  chmod a+x /workdir/repair.sh && \
  chmod a+x /workdir/akeneo_scheduled_tasks.sh && \
  /usr/libexec/fix-permissions /var/www && \
  echo "clear_env = no" >> /etc/php/7.1/fpm/pool.d/www.conf && \
  rm -r /tmp/* && \
  chmod 777 -R /tmp

EXPOSE 5000

CMD ["/opt/bin/start-cmd"]
