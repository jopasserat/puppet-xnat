#!/bin/sh

cd /etc/puppet/modules/
gem install puppet-module
mv xnat/install_dependencies.sh .
sh install_dependencies.sh
mkdir /usr/lib/jvm/
cp xnat/.jdk1.7.0_21.jinfo /usr/lib/jvm/
mkdir /usr/share/tomcat7
printf "export JAVA_HOME=/usr/lib/jvm/jdk1.7.0_21\nexport JAVA_OPTS=\"-Xms512m -Xmx1024m\"" > /usr/share/tomcat7/bin/setenv.sh
export JAVA_HOME=/usr/lib/jvm/jdk1.7.0_21
puppet apply xnat/tests/test.pp > /puppet.out
