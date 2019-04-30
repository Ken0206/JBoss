#!/bin/bash
unzip jboss-eap-7.1.0.zip
sed -i 's/127.0.0.1/0.0.0.0/' /root/jboss-eap-7.1/standalone/configuration/standalone.xml
firewall-cmd --add-port=8080/tcp --add-port=9990/tcp --add-port=8443/tcp
firewall-cmd --add-port=8080/tcp --add-port=9990/tcp --add-port=8443/tcp --permanent
/root/jboss-eap-7.1/bin/add-user.sh

# /root/jboss-eap-7.1/bin/standalone.sh &
# browser:   http://ipaddress:8080

