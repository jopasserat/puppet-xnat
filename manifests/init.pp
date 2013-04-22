# Licensed to Biomedical Imaging Group Rotterdam under one or more contributor 
# license agreements. Biomedical Imaging Group Rotterdam licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# XNAT install manifest
#
# automated version of the install script <<here>>
#
# Required modules:
# puppet module install jgoettsch/mercurial
# https://github.com/jurgenlust/puppet-tomcat
# #puppet module install camptocamp/tomcat
# #of puppet module install llehmijo/tomcat7_rhel
# puppet module install puppetlabs/postgresql
# puppet module install maestrodev/wget
#
#TODO: mount data partitions
#


class xnat ($servertype = 'development') {

  # Tomcat
  class {'tomcat': }
  
  # If the servertype is development use mercurial to clone the XNAT repositories (builder and pipeline)
  if $servertype == 'development' {
    class {'mercurial': }
  }
 
  # PostgreSQL with alternate db location
  class {'postgresql': }
  
 
}