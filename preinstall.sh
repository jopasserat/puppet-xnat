#!/bin/sh

cd /etc/puppet/modules/
gem install puppet-module
mv xnat/install_dependencies.sh .
sh install_dependencies.sh
mkdir -p /usr/lib/jvm/
cp xnat/.jdk1.7.0_21.jinfo /usr/lib/jvm/
mkdir -p /usr/share/tomcat7/bin/
export JAVA_HOME=/usr/lib/jvm/jdk1.7.0_21
puppet apply xnat/tests/test.pp &> /puppet.out
