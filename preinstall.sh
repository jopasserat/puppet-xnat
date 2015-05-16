#!/bin/sh

cd /etc/puppet/modules/

sh xnat/generate_keypair.sh /etc/puppet/modules/xnat
sh xnat/install_dependencies.sh

puppet apply xnat/tests/test.pp &> /puppet.out

