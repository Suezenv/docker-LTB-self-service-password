FROM suezenv/baseimage
# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND noninteractive

# Install Apache2, PHP and LTB ssp
RUN add-apt-repository -y ppa:ondrej/php \
 && apt-get update \
 && apt-get install -y apache2 php5.6 php5.6-mcrypt php5.6-ldap php5.6-xml php5.6-mbstring \
 && apt-get clean
RUN curl -L https://ltb-project.org/archives/self-service-password_1.0-2_all.deb > self-service-password.deb && dpkg -i self-service-password.deb ; rm -f self-service-password.deb

# Configure self-service-password site
RUN sed -i 's#/var/log/apache2/ssp_error.log#/dev/stdout#g' `dpkg -L self-service-password | grep -w 'self-service-password\.conf'` \
 && sed -i 's#/var/log/apache2/ssp_access.log#/dev/stdout#g' `dpkg -L self-service-password | grep -w 'self-service-password\.conf'` \
 && a2dissite 000-default \
 && a2ensite self-service-password

# This is where configuration goes
ADD assets/config.inc.php /usr/share/self-service-password/conf/config.inc.php

# Start Apache2 as runit service
RUN mkdir /etc/service/apache2
ADD assets/apache2.sh /etc/service/apache2/run

EXPOSE 80
