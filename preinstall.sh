#!/bin/bash

cd /etc/puppet/modules/

bash xnat/generate_keypair.sh /etc/puppet/modules/xnat
bash xnat/install_dependencies.sh

puppet apply xnat/tests/test.pp &> /puppet.out

