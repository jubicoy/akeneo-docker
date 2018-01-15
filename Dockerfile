FROM jubicoy/nginx-php:php7
ENV AKENEO_VERSION 1.7

RUN apt-get update && apt-get -y install \
  mysql-client php7.0-xml php7.0-zip php7.0-curl php7.0-intl wget \
  php7.0-mbstring php7.0-mysql php7.0-gd php7.0-mcrypt golang-go \
  php7.0-cli php-apcu git vim && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget http://download.akeneo.com/pim-community-standard-v$AKENEO_VERSION-latest.tar.gz -P /workdir/ && \
  tar -zxvf /workdir/pim-community-standard-v$AKENEO_VERSION-latest.tar.gz -C /var/www/ && rm /workdir/*.tar.gz

ADD conf/default.conf /workdir/default.conf
RUN rm -fv /etc/nginx/conf.d/default.conf && mv /workdir/default.conf /etc/nginx/conf.d/default.conf
ADD conf/parameters.yml /workdir/parameters.yml

RUN rm -fv /var/www/pim-community-standard/app/config/parameters.yml && rm -fv /var/www/pim-community-standard/app/config/parameters.yml.dist
RUN mkdir -p /workdir/conf/fpm && mv /etc/php/7.0/fpm/php.ini /workdir/conf/fpm/php.ini && \
  ln -s /workdir/conf/fpm/php.ini /etc/php/7.0/fpm/php.ini
RUN mkdir -p /workdir/conf/cli && mv /etc/php/7.0/cli/php.ini /workdir/conf/cli/php.ini && \
  ln -s /workdir/conf/cli/php.ini /etc/php/7.0/cli/php.ini

# Install cron
COPY app /usr/src/cron
COPY build.sh /opt/build.sh
RUN /opt/build.sh

COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD entrypoint.sh /workdir/entrypoint.sh
RUN chmod -R a+rw /var/www && \
  chmod a+x /workdir/entrypoint.sh && chmod g+rw /workdir && chmod 777 -R /workdir/conf/*

ADD repair.sh /workdir/repair.sh
RUN chmod a+x /workdir/repair.sh

VOLUME ["/volume"]
EXPOSE 5000

USER 100104
