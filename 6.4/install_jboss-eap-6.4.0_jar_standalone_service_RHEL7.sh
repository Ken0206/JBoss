#!/bin/bash
#date : 2019-05-09

IP_add="0.0.0.0"
JBOSS_HOME="/opt/jboss-eap-6.4"
serviceName="jboss-as"
serviceAccount="jboss"
serviceAccountPassword="!QAZ2wsx"
adminUser="admin"
adminPassword="1qaz@WSX"
install_source_file="jboss-eap-6.4.0-installer.jar"

if [ ! -f "${install_source_file}" ] ; then
  echo ''
  echo "${install_source_file} file does not exist !"
  echo ''
  exit 1
fi

cat > auto.xml << EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<AutomatedInstallation langpack="eng">
<productName>EAP</productName>
<productVersion>6.4.0</productVersion>
<com.izforge.izpack.panels.HTMLLicencePanel id="HTMLLicencePanel"/>
<com.izforge.izpack.panels.TargetPanel id="DirectoryPanel">
<installpath>${JBOSS_HOME}</installpath>
</com.izforge.izpack.panels.TargetPanel>
<com.izforge.izpack.panels.TreePacksPanel id="TreePacksPanel">
<pack index="0" name="Red Hat JBoss Enterprise Application Platform" selected="true"/>
<pack index="1" name="AppClient" selected="true"/>
<pack index="2" name="Bin" selected="true"/>
<pack index="3" name="Bundles" selected="true"/>
<pack index="4" name="XMLs and XSDs" selected="true"/>
<pack index="5" name="Domain" selected="true"/>
<pack index="6" name="Domain Shell Scripts" selected="true"/>
<pack index="7" name="Modules" selected="true"/>
<pack index="8" name="Standalone" selected="true"/>
<pack index="9" name="Standalone Shell Scripts" selected="true"/>
<pack index="10" name="Welcome Content" selected="true"/>
<pack index="11" name="Quickstarts" selected="false"/>
<pack index="12" name="Red Hat JBoss Enterprise Application Platform Natives" selected="true"/>
<pack index="13" name="Native RHEL6-x86_64" selected="true"/>
<pack index="14" name="Native Utils RHEL6-x86_64" selected="true"/>
<pack index="15" name="Native Webserver RHEL6-x86_64" selected="true"/>
</com.izforge.izpack.panels.TreePacksPanel>
<com.izforge.izpack.panels.UserInputPanel id="CreateUserPanel">
<userInput>
<entry key="adminUser" value="${adminUser}"/>
<entry autoPrompt="true" key="adminPassword"/>
</userInput>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.UserInputPanel id="QuickStartsPanel">
<userInput>
<entry key="installQuickStarts" value="false"/>
</userInput>
</com.izforge.izpack.panels.UserInputPanel>
<com.redhat.installer.installation.maven.panel.MavenRepoCheckPanel id="MavenRepoCheckPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketBindingPanel">
<userInput>
<entry key="portDecision" value="false"/>
<entry key="pureIPv6" value="false"/>
</userInput>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.UserInputPanel id="SocketStandalonePanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketHaStandalonePanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketFullStandalonePanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketFullHaStandalonePanel"/>
<com.izforge.izpack.panels.UserInputPanel id="HostDomainPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketDomainPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketHaDomainPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketFullDomainPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="SocketFullHaDomainPanel"/>
<com.izforge.izpack.panels.UserInputPanel id="ServerLaunchPanel">
<userInput>
<entry key="serverStartup" value="none"/>
</userInput>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.UserInputPanel id="LoggingOptionsPanel">
<userInput>
<entry key="configureLog" value="false"/>
</userInput>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.UserInputPanel id="postinstall">
<userInput>
<entry key="postinstallServer" value="false"/>
</userInput>
</com.izforge.izpack.panels.UserInputPanel>
<com.izforge.izpack.panels.UserInputPanel id="vaultsecurity"/>
<com.izforge.izpack.panels.UserInputPanel id="sslsecurity"/>
<com.izforge.izpack.panels.UserInputPanel id="ldapsecurity"/>
<com.izforge.izpack.panels.UserInputPanel id="ldapsecurity2"/>
<com.izforge.izpack.panels.UserInputPanel id="infinispan"/>
<com.redhat.installer.asconfiguration.securitydomain.panel.SecurityDomainPanel id="Security Domain Panel"/>
<com.izforge.izpack.panels.UserInputPanel id="jsssecuritydomain"/>
<com.redhat.installer.asconfiguration.jdbc.panel.JBossJDBCDriverSetupPanel id="JDBC Setup Panel"/>
<com.redhat.installer.asconfiguration.datasource.panel.JBossDatasourceConfigPanel id="Datasource Configuration Panel"/>
<com.izforge.izpack.panels.SummaryPanel id="SummaryPanel"/>
<com.izforge.izpack.panels.InstallPanel id="InstallPanel"/>
<com.izforge.izpack.panels.ProcessPanel id="ProcessPanel"/>
<com.izforge.izpack.panels.ShortcutPanel id="ShortcutPanel"/>
<com.izforge.izpack.panels.FinishPanel id="FinishPanel"/>
</AutomatedInstallation>

EOF

cat > auto.xml.variables << EOF
adminPassword=${adminPassword}

EOF

java -jar ${install_source_file} -console auto.xml
rm -f auto.xml auto.xml.variables

#useradd -r -s /sbin/nologin -d ${JBOSS_HOME} ${serviceAccount}
useradd -r -d ${JBOSS_HOME} ${serviceAccount}
echo "${serviceAccountPassword}" | passwd ${serviceAccount} --stdin
skel_files="$(useradd -D | grep "SKEL=" | awk -F'=' '{print $2}')/.bash*"
\cp ${skel_files} ${JBOSS_HOME}
chown -R ${serviceAccount}:${serviceAccount} ${JBOSS_HOME}

xmlFile=${JBOSS_HOME}"/standalone/configuration/standalone.xml"
\cp ${xmlFile} ${xmlFile}.backup
sed -i '312,317s/127.0.0.1/'"${IP_add}"'/' ${xmlFile}

confFile=${JBOSS_HOME}/bin/init.d/jboss-as.conf
\cp ${confFile} ${confFile}.backup
sed -i '/# JBOSS_USER=jboss-as/aJBOSS_USER='"${serviceAccount}"'' ${confFile}

shFile=${JBOSS_HOME}/bin/init.d/jboss-as-standalone.sh
\cp ${shFile} ${shFile}.backup
#sed -i "s/JBOSS_HOME=\/usr\/share\/jboss-as/JBOSS_HOME=\/opt\/jboss-eap-6.4/" ${shFile}
sed -i "28d" ${shFile}
JBOSS_HOME_config="JBOSS_HOME=${JBOSS_HOME}"
sed -i "27a${JBOSS_HOME_config}" ${shFile}

tmpShFile=${RANDOM}.temp
head_line=$(grep -n 'start() {' ${shFile} | awk -F':' '{print $1}')
head -${head_line} ${shFile} > ${tmpShFile}
cat >> ${tmpShFile} <<EOF
  up_time=\$(uptime | awk '{print \$3\$4}')
  while [ "\${up_time}" == "0min," ] || [ "\${up_time}" == "1min," ] ; do
    sleep 1
    up_time=\$(uptime | awk '{print \$3\$4}')
  done
EOF
all_line=$(cat ${shFile} | wc -l)
tail_line=$(echo ${all_line}-${head_line} | bc)
tail -${tail_line} ${shFile} >> ${tmpShFile}
cat ${tmpShFile} > ${shFile}
rm -f ${tmpShFile}

[ -d /etc/jboss-as ] || mkdir -p /etc/jboss-as
\cp ${confFile} /etc/jboss-as

[ -d /var/log/jboss-as ] || mkdir -p /var/log/jboss-as
[ -d /var/run/jboss-as ] || mkdir -p /var/run/jboss-as
chown -R jboss:jboss /var/log/jboss-as
chown -R jboss:jboss /var/run/jboss-as

\cp ${shFile} /etc/init.d/${serviceName}
chmod +x /etc/init.d/${serviceName}

chkconfig --add ${serviceName}
chkconfig ${serviceName} on

service ${serviceName} start
service ${serviceName} status

firewall-cmd --add-port=8080/tcp --add-port=9990/tcp --add-port=8443/tcp
firewall-cmd --add-port=8080/tcp --add-port=9990/tcp --add-port=8443/tcp --permanent
firewall-cmd --list-all

cat << EOF

more information:
systemctl status jboss-as
cat /var/log/jboss-as/console.log
cat /var/log/jboss-as/console.log

The installation is complete.

EOF
