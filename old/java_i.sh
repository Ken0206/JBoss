#!/bin/bash
tar xf jdk-8u172-linux-x64.tar.gz
mv jdk1.8.0_172/ /usr/lib/jvm/
echo 'export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_172' >> .bash_profile
echo 'export JRE_HOME=${JAVA_HOME}/jre' >> .bash_profile
echo 'export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib' >> .bash_profile
echo 'export PATH=${JAVA_HOME}/bin:$PATH' >> .bash_profile
#java -version
#source .bash_profile
#java -version

