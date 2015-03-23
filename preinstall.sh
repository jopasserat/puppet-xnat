#!/bin/sh

cd /etc/puppet/modules/

sh generate_keypair.sh
sh xnat/install_dependencies.sh

puppet apply xnat/tests/test.pp &> /puppet.out

