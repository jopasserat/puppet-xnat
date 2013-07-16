#!/bin/sh

cd /etc/puppet/modules/
git clone https://bitbucket.org/bigr_erasmusmc/puppet-xnat xnat
gem install puppet-module
mv xnat/install_dependencies.sh .
sh install_dependencies.sh
cp xnat/.jdk1.7.0_21.jinfo /usr/lib/jvm/
echo "export JAVA_HOME=/usr/lib/jvm/jdk1.7.0_21\nexport JAVA_OPTS=\"-Xms512m -Xmx1024m\"" > /usr/share/tomcat7/bin/setenv.sh
puppet apply xnat/tests/test.pp > /puppet.out
