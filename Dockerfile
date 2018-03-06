FROM jubicoy/nginx-php:php7.1

ENV AKENEO_VERSION v2.1

RUN apt-get update && apt-get -y install \
    mysql-client wget golang-go git vim \
    php7.1-apcu php7.1-bcmath php7.1-cli \
    php7.1-curl php7.1-gd php7.1-intl \
    php7.1-mcrypt php7.1-mysql php7.1-soap \
    php7.1-xml php7.1-zip php7.1-imagick && \
  wget https://nodejs.org/dist/v8.9.4/node-v8.9.4-linux-x64.tar.xz -P /workdir/ && \
  tar -xf /workdir/node-v8.9.4-linux-x64.tar.xz && \
  cp -R /workdir/node-v8.9.4-linux-x64/* /usr && \
  npm i -g yarn && \
  wget http://download.akeneo.com/pim-community-standard-${AKENEO_VERSION}-latest.tar.gz -P /workdir/ && \
  tar -zxvf /workdir/pim-community-standard-${AKENEO_VERSION}-latest.tar.gz -C /var/www/ && \
  apt-get clean && \
  rm -rf /workdir/*.zip /workdir/node-v* /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD . /tmp/

RUN (cd /var/www/pim-community-standard; patch -p1 < /tmp/mysql.patch) && \
  rm -fv /etc/nginx/conf.d/default.conf && \
  mv /tmp/conf/default.conf /etc/nginx/conf.d/default.conf && \
  mv /tmp/conf/parameters.yml /workdir/parameters.yml && \
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
  cp /tmp/conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf && \
  cp /tmp/entrypoint.sh /workdir && \
  chmod -R a+rw /var/www && \
  chmod a+x /workdir/entrypoint.sh && \
  chmod g+rw /workdir && \
  chmod 777 -R /workdir/conf/* && \
  cp /tmp/repair.sh /workdir && \
  chmod a+x /workdir/repair.sh && \
  rm -r /tmp/*

