#!/bin/bash
#date : 2019-04-25

IP_add="192.168.188.76"
JBOSS_HOME="/opt/jboss-eap-7.2"
serviceName="jboss-eap"
serviceAccount="jboss"
adminUser="jbossadmin"
adminPassword="1qaz@WSX"

if [ ! -f jboss-eap-7.2.0-installer.jar ] ; then
  echo ''
  echo '"jboss-eap-7.2.0-installer.jar" file does not exist !'
  echo ''
  exit 1
fi

cat > auto.xml << EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<AutomatedInstallation langpack="eng">
<productName>EAP</productName>
<productVersion>7.2.0</productVersion>
<com.izforge.izpack.panels.HTMLLicencePanel id="HTMLLicencePanel"/>
<com.izforge.izpack.panels.TargetPanel id="DirectoryPanel">
<installpath>${JBOSS_HOME}</installpath>
</com.izforge.izpack.panels.TargetPanel>
<com.izforge.izpack.panels.TreePacksPanel id="TreePacksPanel">
<pack index="0" name="Red Hat JBoss Enterprise Application Platform" selected="true"/>
<pack index="1" name="AppClient" selected="true"/>
<pack index="2" name="XMLs and XSDs" selected="true"/>
<pack index="3" name="Modules" selected="true"/>
<pack index="4" name="Welcome Content" selected="true"/>
</com.izforge.izpack.panels.TreePacksPanel>
<com.izforge.izpack.panels.UserInputPanel id="CreateUserPanel">
<userInput>
<entry key="adminUser" value="${adminUser}"/>
<entry autoPrompt="true" key="adminPassword"/>
</userInput>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.SummaryPanel id="SummaryPanel"/>
<com.izforge.izpack.panels.InstallPanel id="InstallPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="postinstall">
<userInput>
<entry key="postinstallServer" value="false"/>
</userInput>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.UserInputPanel id="vaultsecurity"/>
<com.izforge.izpack.panels.UserInputPanel id="sslsecurity"/>
<com.izforge.izpack.panels.UserInputPanel id="ldapsecurity"/>
<com.izforge.izpack.panels.UserInputPanel id="ldapsecurity2"/>
<com.izforge.izpack.panels.UserInputPanel id="Security Domain Panel"/>
<com.izforge.izpack.panels.UserInputPanel id="jsssecuritydomain"/>
<com.izforge.izpack.panels.UserInputPanel id="QuickStartsPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="MavenRepoCheckPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketBindingPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketStandalonePanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketHaStandalonePanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketFullStandalonePanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketFullHaStandalonePanel"/>
<com.izforge.izpack.panels.UserInputPanel id="HostDomainPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketDomainPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketHaDomainPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketFullDomainPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketFullHaDomainPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="ServerLaunchPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="LoggingOptionsPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="JSF jar Setup Panel"/>
<com.izforge.izpack.panels.UserInputPanel id="JDBC Setup Panel"/>
<com.izforge.izpack.panels.UserInputPanel id="Datasource Configuration Panel"/>
<com.izforge.izpack.panels.ProcessPanel id="ProcessPanel"/>
<com.izforge.izpack.panels.ShortcutPanel id="ShortcutPanel"/>
<com.izforge.izpack.panels.FinishPanel id="FinishPanel"/>
</AutomatedInstallation>

EOF

cat > auto.xml.variables << EOF
adminPassword=${adminPassword}

EOF

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
rm -f auto.xml auto.xml.variables

# cat /var/log/jboss-eap/console.log
# cat /opt/jboss-eap-7.2/standalone/log/server.log
