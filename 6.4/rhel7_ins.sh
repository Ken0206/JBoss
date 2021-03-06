#!/bin/bash

java -jar jboss-eap-6.4.0-installer.jar -console auto.xml
serviceAccount=jboss
useradd -s /sbin/nologin ${serviceAccount}
JBOSS_HOME="/opt/jboss-eap-6.4"
chown -R ${serviceAccount}:${serviceAccount} ${JBOSS_HOME}
xmlFile=${JBOSS_HOME}"/standalone/configuration/standalone.xml"
sed -i 's/127.0.0.1/0.0.0.0/' ${xmlFile}
confFile=${JBOSS_HOME}/bin/init.d/jboss-as.conf
shFile=${JBOSS_HOME}/bin/init.d/jboss-as-standalone.sh
echo "JBOSS_USER=${serviceAccount}" >> ${confFile}
sed -i "s/JBOSS_HOME=\/usr\/share\/jboss-as/JBOSS_HOME=\/opt\/jboss-eap-6.4/" ${shFile}
[ -d /etc/jboss-as ] || mkdir -p /etc/jboss-as
cp ${confFile} /etc/default/
cp ${shFile} /etc/init.d/jboss-as-standalone
chmod +x /etc/init.d/jboss-as-standalone
chkconfig --add jboss-as-standalone
chkconfig jboss-as-standalone on

service jboss-as-standalone start
service jboss-as-standalone status

#chkconfig iptables off
#service iptables stop
