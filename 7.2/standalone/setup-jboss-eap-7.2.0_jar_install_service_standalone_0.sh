#!/bin/bash
#date: 2019-04-25

java -jar jboss-eap-7.2.0-installer.jar -console auto.xml
serviceAccount=jboss
useradd -r -s /sbin/nologin ${serviceAccount}
JBOSS_HOME="/opt/jboss-eap-7.2"
chown -R ${serviceAccount}:${serviceAccount} ${JBOSS_HOME}

xmlFile=${JBOSS_HOME}"/standalone/configuration/standalone.xml"
cp ${xmlFile} ${xmlFile}".backup"
sed -i '492,499s/127.0.0.1/0.0.0.0/' ${xmlFile}

confFile=${JBOSS_HOME}/bin/init.d/jboss-eap.conf
cp ${confFile} ${confFile}".backup"
shFile=${JBOSS_HOME}/bin/init.d/jboss-eap-rhel.sh
addLine1='JBOSS_HOME="'${JBOSS_HOME}'"'
sed -i '/# JBOSS_HOME="\/opt\/jboss-eap"/a'"${addLine1}"'' ${confFile}
sed -i '/# JBOSS_USER=jboss-eap/aJBOSS_USER='"${serviceAccount}"'' ${confFile}
cp ${confFile} /etc/default
cp ${shFile} /etc/init.d/jboss-eap
chmod +x /etc/init.d/jboss-eap

systemctl daemon-reload
systemctl enable jboss-eap
systemctl start jboss-eap
systemctl status jboss-eap

firewall-cmd --add-port=8080/tcp --add-port=9990/tcp --add-port=8443/tcp
firewall-cmd --add-port=8080/tcp --add-port=9990/tcp --add-port=8443/tcp --permanent

# cat /var/log/jboss-eap/console.log




