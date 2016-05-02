FROM phusion/baseimage
#FROM jdecool/php-pthreads

# Verschiedene Variablen
ENV EBOT_HOME /home/ebot
ENV EBOT_HOME_WEB /home/ebot-web
ENV CSGO_HOME /home/csgo

# Alles nötige instalieren
RUN dpkg --add-architecture i386
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install wget apache2 nodejs npm curl git unzip screen libc6:i386 libstdc++6:i386 wget software-properties-common vim php5-cli php5-mysql libapache2-mod-php5

#RUN wget http://pecl.php.net/get/pthreads-2.0.10.tgz -O /usr/src/php/ext/pthreads.tgz
#RUN cd /usr/src/php/ext/ && tar xvfz /usr/src/php/ext/pthreads.tgz
#RUN docker-php-ext-install pthreads-2.0.10 pdo_mysql mysql sockets
#RUN echo 'date.timezone = Europe/Paris' >> /usr/local/etc/php/conf.d/timezone.ini

# NodeJS konfigurieren
RUN /bin/ln -s /usr/bin/nodejs /usr/bin/node

# Dependency: Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin

# Dependency: CSGO-Server
RUN mkdir ${CSGO_HOME} && \
  curl -k -L https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz >> ${CSGO_HOME}/steamcmd_linux.tar.gz && \
  tar -xvzf ${CSGO_HOME}/steamcmd_linux.tar.gz -C ${CSGO_HOME}

# Dependency: eBot
RUN mkdir ${EBOT_HOME} && \
  curl -L https://github.com/deStrO/eBot-CSGO/archive/master.zip >> ${EBOT_HOME}/master.zip && \
  unzip -d ${EBOT_HOME} ${EBOT_HOME}/master.zip && \
  ln -s ${EBOT_HOME}/eBot-CSGO-master ${EBOT_HOME}/ebot-csgo && \
  cd ${EBOT_HOME}/ebot-csgo && \
  php /usr/bin/composer.phar install

# Dependency: eBot-web
RUN mkdir ${EBOT_HOME_WEB} && \
  curl -L https://github.com/heew/eBot-CSGO-Web/archive/master.zip >> ${EBOT_HOME_WEB}/master.zip && \
  unzip -d ${EBOT_HOME_WEB} ${EBOT_HOME_WEB}/master.zip && \
  ln -s ${EBOT_HOME_WEB}/eBot-CSGO-Web-master ${EBOT_HOME_WEB}/ebot-csgo-web && \
  cd ${EBOT_HOME_WEB}/ebot-csgo-web

RUN a2enmod rewrite
RUN sed -i 's@#RewriteBase /@RewriteBase /ebot-csgo@g' ${EBOT_HOME_WEB}/ebot-csgo-web/web/.htaccess

# Konfigurationen kopieren
COPY cfg/config.ini ${EBOT_HOME}/ebot-csgo/config/config.ini
COPY Match.php ${EBOT_HOME}/ebot-csgo/src/eBot/Match/Match.php
COPY cfg/ebotv3.conf /etc/apache2/conf-enabled/ebotv3.conf
COPY cfg/app_user.yml ${EBOT_HOME_WEB}/ebot-csgo-web/config/app_user.yml
COPY start.sh ${EBOT_HOME}/start.sh

# NodeJS-Pakete installieren
RUN npm install socket.io formidable archiver

# Script ausführbar machen
RUN chmod 755 ${EBOT_HOME}/start.sh

# Port 80 für WebAccess
EXPOSE 80
EXPOSE 27015
EXPOSE 27020
EXPOSE 12360

# Container starten
WORKDIR ${EBOT_HOME}
CMD ["sh", "-c", "./start.sh"]

