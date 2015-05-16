#!/bin/bash

MODULES_TO_INSTALL="puppetlabs-ruby jgoettsch-mercurial puppetlabs-postgresql puppetlabs-rsync maestrodev-wget puppetlabs-java stahnma-epel jfryman-nginx puppetlabs-tomcat"
MODULES_INSTALLED=`puppet module list`

for i in ${MODULES_TO_INSTALL}; do
  # only install module if needed
  echo ${MODULES_INSTALLED} | grep -q $i || puppet module install $i
done

# temporarily forced to lower version => v >= 0.6.x does not work with remote URLs
echo ${MODULES_INSTALLED} | grep -q camptocamp-archive || puppet module install --version 0.5.3 camptocamp-archive

