#!/bin/bash

unzip jboss-eap-7.1.0.zip
JBOSS_HOME=$(pwd)"/jboss-eap-7.1"
${JBOSS_HOME}/bin/add-user.sh
xmlFile=${JBOSS_HOME}"/standalone/configuration/standalone.xml"
sed -i 's/127.0.0.1/0.0.0.0/' ${xmlFile}

confFile=${JBOSS_HOME}/bin/init.d/jboss-eap.conf
shFile=${JBOSS_HOME}/bin/init.d/jboss-eap-rhel.sh
addLine1=JBOSS_HOME='"'${JBOSS_HOME}'"'
sed -i '/# JBOSS_HOME="\/opt\/jboss-eap"/a'"${addLine1}"'' ${confFile}
sed -i '/# JBOSS_USER=jboss-eap/aJBOSS_USER=root' ${confFile}
cp ${confFile} /etc/default
cp ${shFile} /etc/init.d
chmod +x /etc/init.d/jboss-eap-rhel.sh
chkconfig --add jboss-eap-rhel.sh
chkconfig jboss-eap-rhel.sh on
service jboss-eap-rhel start
service jboss-eap-rhel status

firewall-cmd --add-port=8080/tcp --add-port=9990/tcp --add-port=8443/tcp
firewall-cmd --add-port=8080/tcp --add-port=9990/tcp --add-port=8443/tcp --permanent

