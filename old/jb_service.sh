#!/bin/bash
sed -i '/# JBOSS_HOME="\/opt\/jboss-eap"/aJBOSS_HOME="/root/jboss-eap-7.1"' /root/jboss-eap-7.1/bin/init.d/jboss-eap.conf
sed -i '/# JBOSS_USER=jboss-eap/aJBOSS_USER=root' /root/jboss-eap-7.1/bin/init.d/jboss-eap.conf
cp /root/jboss-eap-7.1/bin/init.d/jboss-eap.conf /etc/default
cp /root/jboss-eap-7.1/bin/init.d/jboss-eap-rhel.sh /etc/init.d
chmod +x /etc/init.d/jboss-eap-rhel.sh
chkconfig --add jboss-eap-rhel.sh
chkconfig jboss-eap-rhel.sh on
service jboss-eap-rhel start
service jboss-eap-rhel status
