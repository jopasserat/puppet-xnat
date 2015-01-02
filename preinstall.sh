#!/bin/sh

cd /etc/puppet/modules/
#gem install puppet-module
#mv xnat/install_dependencies.sh .
sh xnat/install_dependencies.sh
#mkdir -p /usr/lib/jvm/
#cp xnat/.jdk1.7.0_60.jinfo /usr/lib/jvm/
#export JAVA_HOME=/usr/lib/jvm/jdk1.7.0_60
puppet apply xnat/tests/test.pp &> /puppet.out
