#!/bin/bash

MODULES_TO_INSTALL="puppetlabs-ruby jgoettsch-mercurial puppetlabs-postgresql puppetlabs-rsync maestrodev-wget camptocamp-archive puppetlabs-java stahnma-epel jfryman-nginx"
MODULES_INSTALLED=`puppet module list`

for i in ${MODULES_TO_INSTALL}; do
  # only install module if needed
  echo ${MODULES_INSTALLED} | grep -q $i || puppet module install $i
done

