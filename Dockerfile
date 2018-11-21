FROM phusion/baseimage:0.9.16
# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND noninteractive
ENV SSP_VERSION 1.3

# Install Apache2, PHP and LTB ssp
RUN apt-get update && apt-get install -y apache2 php5 php5-mcrypt php5-ldap && apt-get clean
RUN curl -L https://ltb-project.org/archives/self-service-password_$SSP_VERSION_all.deb > self-service-password.deb && dpkg -i self-service-password.deb ; rm -f self-service-password.deb

# Configure self-service-password site
RUN ln -s ../../mods-available/mcrypt.ini /etc/php5/apache2/conf.d/20-mcrypt.ini
RUN a2dissite 000-default && a2ensite self-service-password

# This is where configuration goes
ADD assets/config.inc.php /usr/share/self-service-password/conf/config.inc.php

# Start Apache2 as runit service
RUN mkdir /etc/service/apache2
ADD assets/apache2.sh /etc/service/apache2/run

EXPOSE 80
