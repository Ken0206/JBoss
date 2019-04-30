#!/bin/bash
#date : 2019-04-25

IP_add="0.0.0.0"
JBOSS_HOME="/opt/jboss-eap-7.2"
serviceName="jboss-eap"
serviceAccount="jboss"

java -jar jboss-eap-7.2.0-installer.jar -console auto.xml
useradd -r -s /sbin/nologin ${serviceAccount}
chown -R ${serviceAccount}:${serviceAccount} ${JBOSS_HOME}

xmlFile=${JBOSS_HOME}"/standalone/configuration/standalone.xml"
cp ${xmlFile} ${xmlFile}".backup"
sed -i '492,499s/127.0.0.1/'"${IP_add}"'/' ${xmlFile}

confFile=${JBOSS_HOME}/bin/init.d/jboss-eap.conf
cp ${confFile} ${confFile}".backup"
shFile=${JBOSS_HOME}/bin/init.d/jboss-eap-rhel.sh
JBOSS_HOME_config='JBOSS_HOME="'${JBOSS_HOME}'"'
sed -i '/# JBOSS_HOME="\/opt\/jboss-eap"/a'"${JBOSS_HOME_config}"'' ${confFile}
sed -i '/# JBOSS_USER=jboss-eap/aJBOSS_USER='"${serviceAccount}"'' ${confFile}
cp ${confFile} /etc/default
cp ${shFile} /etc/init.d/${serviceName}
chmod +x /etc/init.d/${serviceName}

systemctl daemon-reload
systemctl enable ${serviceName}
systemctl start ${serviceName}
systemctl status ${serviceName}

firewall-cmd --add-port=8080/tcp --add-port=9990/tcp --add-port=8443/tcp
firewall-cmd --add-port=8080/tcp --add-port=9990/tcp --add-port=8443/tcp --permanent

# cat /var/log/jboss-eap/console.log
