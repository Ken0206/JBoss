#!/bin/bash

cat >> /home/student/.bashrc << EOF

# JBoss
JBOSS_HOME=/opt/jboss-eap-7.1
PATH=$PATH:$JBOSS_HOME/bin
export JBOSS_HOME PATH

EOF