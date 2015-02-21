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
  $instance_name,
  $archive_root,  # for build.properties.erb
  $tomcat_web_user,
  $tomcat_web_password,
  $tomcat_port,
  $apache_port,
  $apache_mail_address,
  $xnat_version,
  $java_opts,
  $catalina_tmp_dir,
  $mail_server,
  $mail_port,
  $mail_username,
  $mail_password,
  $mail_admin,
  $mail_subject,
  $tablespace_dir,
  $xnat_local_install
)
{
  require java
  require postgresql::server

  user { 'xnat':
    ensure      => 'present',
    managehome  =>  true,
    system      =>  true,
    home        => '/home/xnat',
  }
#  file { "/home/xnat":
#    mode => 755
#  } ->

# $tomcat_root = "/usr/share/tomcat7"
  $installer_dir = "/home/$system_user/xnat"
  # FIXME problematic with vagrant -> accessing XNAT through localhost gets replaced
  # by VM's IP (not routed) beyond login page
  $xnat_url = "http://${::ipaddress}:$apache_port/"

  # Add to paths. Could use absolute paths, but some external modules don't do this anyway.
  Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin' }


  # Stop tomcat
#  exec { "stop tomcat":
#    command => "su tomcat -c 'sh /usr/share/tomcat7/bin/shutdown.sh'",
#    onlyif => "test -e /usr/share/tomcat7/bin/shutdown.sh"
#  } ->

  $tomcat_version = 'tomcat7'
  class { 'tomcat':
      install_from_source => false,
      user                => "$tomcat_version",
      group               => "$tomcat_version",
  } ->
  class { 'epel': }->
  tomcat::instance{ 'default':
      package_name  => "$tomcat_version",
  }->
  tomcat::service { 'default':
    use_jsvc     => false,
    use_init     => true,
    service_name => "$tomcat_version",
    catalina_home => "/usr/share/${tomcat_version}",
    catalina_base => "/var/lib/${tomcat_version}",
  } 
  # tomcat::config::server { 'default':
  #  port => $tomcat_port,
  #}
  #tomcat::config::server::connector { 'default':
  #  port   => $tomcat_port,
    #  notify => Service['tomcat7'],
    #}
#  tomcat { "install tomcat": 
#TODO can we configure web user/pwd? + remaining conf in original tomcat.pp
#    tomcat_web_user => $tomcat_web_user,
#    tomcat_web_password => $tomcat_web_password,
#    tomcat_port => $tomcat_port
#  } -> 

  $tomcat_root = "/var/lib/${tomcat_version}"
  notify { 'info':
    message => "Tomcat root is ${tomcat_root}",
  }

 
  download_xnat{ "download xnat" :
    xnat_version => $xnat_version,
    installer_dir => $installer_dir,
    xnat_local_install => $xnat_local_install
  }

  $xnatStorageDirs = [ 'archive', 'build', 'cache', 'ftp', 'prearchive', 'modules' ]
  #exec {"make xnat storage directories":
  #  command => "bash -c 'mkdir -p /$archive_root/{archive,build,cache,ftp,prearchive,modules} $catalina_tmp_dir';\
  #bash -c 'chmod -R 755 /$archive_root/{archive,build,cache,ftp,prearchive,modules} $catalina_tmp_dir';\
  #bash -c 'chown tomcat:tomcat /$archive_root/{archive,build,cache,ftp,prearchive,modules} $catalina_tmp_dir';"
  #} ->

   # ensure archive root creation (not recursice, only works to create final leaf of directory structure)
  mk_xnat_dir { $archive_root:
    archive_root => '',
  } ->
  mk_xnat_dir { $xnatStorageDirs:
    archive_root => $archive_root,
  } ->
  file {$catalina_tmp_dir:
    ensure => directory,
    mode   => 0755,
    owner  => $::tomcat::user,
    group  => $::tomcat::group,
  } ->

  init_database{ "run" :
    db_username => $db_username,
    db_userpassword => $db_userpassword,
    db_name => $db_name,
    tablespace_dir => $tablespace_dir
  } ->

  exec { "set xnat permissions":
    command => "chown -R xnat:xnat $installer_dir"
  } ->

  file { "$installer_dir/build.properties":
    ensure => present,
    content => template('xnat/build.properties.erb'),
    mode => '600'
  } ->

  notify { "building XNAT ...": } ->

  # Run XNAT install script
  exec { "xnat-setup":
    command => "$installer_dir/bin/setup.sh > setup.out",
    cwd => "$installer_dir",
    environment => "JAVA_HOME=${::java_home}",
    timeout => 3600000,
    unless => "test -d $installer_dir/deployments/$instance_name"
  } ->

  # Initialize database for XNAT
  # TODO replace DB + user creation by postgreql::server::db
  fill_database{ "setup postgres database" :
    system_user => $system_user,
    instance_name => $instance_name,
    installer_dir => $installer_dir,
    db_username => $db_username
  } ->

  # What for?
  #exec { "move old tomcat ROOT folder": 
  #  command => "mv /usr/share/tomcat7/webapps/ROOT /usr/share/tomcat7/webapps/tomcat",
  #  unless => "test -d /usr/share/tomcat7/webapps/tomcat"
  #} ->

  # Copy the generated war
  file { "$tomcat_root/webapps":
    ensure => directory,
    owner  => $::tomcat::user,
    group  => $::tomcat::group,
  } ->
  tomcat::war { "${instance_name}.war":
    war_source      => "$installer_dir/deployments/$instance_name/target/$instance_name.war",
    deployment_path =>  "$tomcat_root/webapps",
    war_ensure      => present,
    war_purge 	    => true,
    notify          => Service[$tomcat_version],
  }

  #file {"$tomcat_root/webapps/$instance_name.war":
  #  ensure => present,
  #  source => "$installer_dir/deployments/$instance_name/target/$instance_name.war",
  #  notify => Service['tomcat7'],
  #} -> 

  # tomcat::service { 'restart tomcat':
  #  use_jsvc         => false,
  #  use_init         => true,
  #  service_name     => 'tomcat7',
  #}
  #  exec {"stop and start tomcat":
  #  command => "su tomcat -c /usr/share/tomcat7/bin/shutdown.sh && su tomcat -c '/usr/share/tomcat7/bin/startup.sh'",
  #  cwd => "$tomcat_root/logs"
  #} ->

  # FIXME not working -> replace with Nginx
  init_apache { "initialize apache proxy":
    apache_port => $apache_port,
    apache_mail_address => $apache_mail_address
  }
}

