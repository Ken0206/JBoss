#!/bin/bash

java -jar jboss-eap-7.1.0-installer.jar -console auto.xml
serviceAccount=jboss
useradd -r -s /sbin/nologin ${serviceAccount}
JBOSS_HOME="/opt/jboss-eap-7.1"
chown -R ${serviceAccount}:${serviceAccount} ${JBOSS_HOME}

firewall-cmd --add-port=8080/tcp --add-port=9990/tcp --add-port=8443/tcp
firewall-cmd --add-port=8080/tcp --add-port=9990/tcp --add-port=8443/tcp --permanent
