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

define xnat::xnatapp (
  $db_name = "xnat",
  $db_username = "xnat",
  $db_userpassword,
  $archive_root = "/data/XNAT",
  $xnat_url = "http://localhost:8080/xnat-web-app-1",
  $xnat_port = "8080",
  $system_user = "xnat",
  $instance_name = "xnat-web-app-1", # add tomcat dir, puppet dir
)
{
  require tomcat
  require java
  require postgresql::server

  $tomcat_root = "/usr/share/tomcat7"
  $installer_dir = "/home/$system_user/xnat-builder"
  $download_dir = "/home/$system_user/downloads"

  # Add to paths. Could use absolute paths, but some external modules don't do this anyway.
  Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin' }

  # Get latest updates
  #case $operatingsystem {
  #  centos, redhat, fedora: { exec { "yum update": command => "yum -y update"}}
  #  default: { exec { "yum update": command => "apt-get update;apt-get upgrade"}}
  #}
  #->

  # Clone the xnat builder dev branch, create files and set permissions (step 1)
  exec { "mercurial-clone-xnatbuilder":
    command => "hg clone http://hg.xnat.org/xnat_builder_1_6dev $installer_dir",
    creates => $installer_dir,
    timeout => 3600000,
  } ->

  exec { "mercurial-clone-xnat-pipeline":
    command => "hg clone http://hg.xnat.org/pipeline_1_6dev $installer_dir/pipeline",
    creates => "$installer_dir/pipeline",
    timeout => 3600000,
  } ->

  # Add user with password (step 2.1)
  postgresql::database_user { $db_username:
    createrole => true,
    password_hash => $db_userpassword
  } ->

  # Configure the postgres db (step 2.2)
  postgresql::db { $db_name:
    user => $db_username,
    password => $db_userpassword
  } ->

  # Set build properties (step 3)
  exec { "set xnat permissions":
    command => "chown -R xnat:xnat $installer_dir"
  } ->

  file { "$installer_dir/build.properties":
    ensure => file,
    content => template('xnat/build.properties.erb'),
    mode => '600'
  } ->

  # Run XNAT install script (step 4)
  exec { "xnat-setup":
    command => "$installer_dir/bin/setup.sh > setup.out",
    cwd => "$installer_dir",
    environment => "JAVA_HOME=$java_home",
    timeout => 3600000,
    unless => "test -d $installer_dir/deployments/$instance_name"
  } ->

  # Do database configuration (step 5)
  exec { "postgresql-create-tables-and-views":
    command => "su xnat -c 'psql -d $system_user -f $installer_dir/deployments/$instance_name/sql/$instance_name.sql -U $db_username > /home/xnat/psql.out'",
    unless => "sh /etc/puppet/modules/xnat/tests/database_exists.sh"
  } ->
  
  # Security settings (step 7)
  exec { "store initial security settings":
    command => "$installer_dir/bin/StoreXML -project $instance_name -l security/security.xml -allowDataDeletion true > security.out",
    cwd => "$installer_dir/deployments/$instance_name",
    unless => "sh /etc/puppet/modules/xnat/tests/database_exists.sh"
  } ->

  # Example sets (step 8)
  exec { "optional: store example custom variable sets":
    command => "$installer_dir/bin/StoreXML -dir ./work/field_groups -u admin -p admin -allowDataDeletion true > example.out",
    cwd => "$installer_dir/deployments/$instance_name",
    unless => "sh /etc/puppet/modules/xnat/tests/database_exists.sh"
  } ->

  # Copy the generated war (step 9)
  exec {"deploy webapp":
    command => "cp $installer_dir/deployments/$instance_name/target/$instance_name.war /usr/share/tomcat7/webapps/ && /usr/share/tomcat7/bin/shutdown.sh && /usr/share/tomcat7/bin/startup.sh"
  }
}
