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
  $db_name,
  $db_username,
  $db_userpassword,
  $system_user,
  $instance_name, # add tomcat dir, puppet dir
  $archive_root,  # for build.properties.erb
)
{
  require tomcat
  require java
  require postgresql::server

  $tomcat_root = "/usr/share/tomcat7"
  $installer_dir = "/home/$system_user/xnat-builder"
  $download_dir = "/home/$system_user/downloads"
  $xnat_url = "http://${ip_address}:8080/xnat-web-app-1"

  # Add to paths. Could use absolute paths, but some external modules don't do this anyway.
  Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin' }

  # Stop tomcat
  exec { "stop tomcat":
    command => "su tomcat -c 'sh /usr/share/tomcat7/bin/shutdown.sh'",
    onlyif => "test -d /usr/share/tomcat7/bin/shutdown.sh"
  } ->

  # Get latest updates
  case $operatingsystem {
    scientific, centos, redhat, fedora: { exec { "yum_update": command => "yum -y update"}}
    default: { exec { "apt_get_update": command => "apt-get update;apt-get upgrade"}}
  }
  ->

  notify { "downloading XNAT ...": } ->

  # Clone the xnat builder dev branch, create files and set permissions (step 1)
  exec { "mercurial-clone-xnatbuilder":
    command => "hg clone http://hg.xnat.org/xnat_builder_1_6dev $installer_dir",
    creates => $installer_dir,
    timeout => 7200,
  } ->

  notify { "downloading XNAT pipeline ...": } ->

  exec { "mercurial-clone-xnat-pipeline":
    command => "hg clone http://hg.xnat.org/pipeline_1_6dev $installer_dir/pipeline",
    creates => "$installer_dir/pipeline",
    timeout => 7200,
  } ->

  notify { "downloading XNAT and pipeline complete": } ->

  init_database{ "run" :
    db_username => $db_username,
    db_userpassword => $db_userpassword,
    db_name => $db_name
  } ->

  # Set build properties (step 3)
  exec { "set xnat permissions":
    command => "chown -R xnat:xnat $installer_dir"
  } ->

  exec {"make_directories":
    command => "sh /etc/puppet/modules/xnat/tests/makedirs.sh"
  } ->

  file { "$installer_dir/build.properties":
    ensure => present,
    content => template('xnat/build.properties.erb'),
    mode => '600'
  } ->

  notify { "building XNAT ...": } ->

  # Run XNAT install script (step 4)
  exec { "xnat-setup":
    command => "$installer_dir/bin/setup.sh > setup.out",
    cwd => "$installer_dir",
    #environment => "JAVA_HOME=/usr/lib/jvm/jdk1.7.0_21/",
    timeout => 3600000,
    unless => "test -d $installer_dir/deployments/$instance_name"
  } ->

  # Initialize database for XNAT
  fill_database{ "setup postgres database" :
    system_user => $system_user,
    instance_name => $instance_name,
    installer_dir => $installer_dir,
    db_username => $db_username
  } ->

  # Copy the generated war
  file {"$tomcat_root/webapps/$instance_name.war":
    ensure => present,
    source => "$installer_dir/deployments/$instance_name/target/$instance_name.war"
  } ->

  exec {"stop and start tomcat":
    command => "su tomcat -c /usr/share/tomcat7/bin/shutdown.sh && su tomcat -c '/usr/share/tomcat7/bin/startup.sh'",
    cwd => "$tomcat_root/logs"
  }
}
