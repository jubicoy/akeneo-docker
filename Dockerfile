FROM jubicoy/nginx-php:latest
ENV AKENEO_VERSION 1.7

RUN apt-get update && apt-get -y install \
  mysql-client php-xml php-zip php5-curl php5-intl wget \
  php-mbstring php5-mysql php5-gd php5-mcrypt golang-go \
  php5-cli php5-apcu libapache2-mod-php5 git && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget http://download.akeneo.com/pim-community-standard-v$AKENEO_VERSION-latest.tar.gz -P /workdir/ && \
  tar -zxvf /workdir/pim-community-standard-v$AKENEO_VERSION-latest.tar.gz -C /var/www/ && rm /workdir/*.tar.gz

ADD entrypoint.sh /workdir/entrypoint.sh
ADD conf/default.conf /workdir/default.conf
RUN rm -fv /etc/nginx/conf.d/default.conf && mv /workdir/default.conf /etc/nginx/conf.d/default.conf
ADD conf/parameters.yml /workdir/parameters.yml

RUN rm -fv /var/www/pim-community-standard/app/config/parameters.yml && rm -fv /var/www/pim-community-standard/app/config/parameters.yml.dist
RUN mkdir -p /workdir/conf/fpm && mkdir /workdir/conf/cli && mv /etc/php5/fpm/php.ini /workdir/conf/fpm/php.ini && \
  mv /etc/php5/cli/php.ini /workdir/conf/cli/php.ini && ln -s /workdir/conf/fpm/php.in /etc/php5/fpm/php.ini && \
  ln -s /workdir/conf/cli/php.ini /etc/php5/cli/php.ini

# Install cron
COPY app /usr/src/cron
COPY build.sh /opt/build.sh
RUN /opt/build.sh

COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chown -R 104:0 /var/www && chmod -R g+rw /var/www && \
  chmod a+x /workdir/entrypoint.sh && chmod g+rw /workdir && chmod 777 -R /workdir/conf/*

VOLUME ["/volume"]
EXPOSE 5000

USER 104
