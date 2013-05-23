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

# README
#NOTE: If a enviroment variable needs to be set persistently, put a script in /etc/profiles.d

define xnat::xnatapp (
  $db_name = "xnat",
  $db_username = "xnat",
  $db_userpassword,
  $archive_root = "/data/XNAT",
  $xnat_url,
  $xnat_port = "8080",
  $xnat_number = "0", #this is the prefix of the port number starting with: 808x
  $system_user = "xnat",
  $instance_name = "xnat-web-app-1",
  $webapp_base = "/home",
  $download_method = "ftp", # can be either 'mercurial' or 'ftp' 
)
{
  require xnat
  require postgresql::server
  require java
  
  $tomcat_root = "$webapp_base/$system_user/tomcat"
  $installer_dir = "/home/$system_user/xnat-builder"
  $download_dir = "/home/$system_user/downloads"
  #$archive_dirs = split($archive_root,'/')
  $archive_dirs = ["$archive_root/archive","$archive_root/build","$archive_root/cache","$archive_root/ftp","$archive_root/prearchive","$archive_root/modules"]
  
  exec { "apt-get update":
    command => "/usr/bin/apt-get update",
    onlyif => "/bin/sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null'",
  }
  ->
  # Check for latest java version on master
  file { "${java::params::java_base}/.jdk${java::params::java_version}.jinfo":
    mode => 0644,
    owner => root,
    group => root,
    source => "puppet:///modules/java/.jdk${java::params::java_version}.jinfo",
    alias => "java-source-jinfo"
  }
  ->
  # Set correct java version, using update-java-alternatives to prevent console choices
  exec { "update-alternatives install sun jdk":
    command => "/bin/cat /usr/lib/jvm/.jdk${java::params::java_version}.jinfo | /bin/grep -E '^(jre|jdk)' | /usr/bin/awk '{print \"/usr/bin/\" \$2 \" \" \$2 \" \" \$3 \" 30 \r \"}' | /usr/bin/xargs -t -n4 sudo /usr/bin/update-alternatives --verbose --install > ~/output.txt"
  }
  ->  
  exec { "update-java-alternatives set sun jdk":
    command => "/usr/sbin/update-java-alternatives --set jdk1.7.0_21"
  }
  ->
  tomcat::webapp { $instance_name:
    username => $system_user,
    webapp_base => $webapp_base,
    number => $xnat_number,
    java_opts => "-Xms512m -Xmx1024m",
  }
  ->
  package{ "openjdk-6-jdk":
    ensure => present,
  }
#  tomcat::instance { $instance_name:
#    ensure => present,
#    owner => $system_user,
#    http_port => $xnat_port,
#    setenv => ['ADD_JAVA_OPTS="-Xms512m -Xmx1024m"'],
#  }
  ->
  # Ensure the archive directories are present (not working, created manually)
  #exec { "mkdir-root":
  #  command => "/bin/mkdir -p $archive_root"
  #}
  #->
  # Make the archive directories
  #file { $archive_dirs:
  #  ensure => "directory",
  #  mode => "700",
  #  owner => $system_user,
  #}
  #->
  # configure the postgres db (step 2).
  postgresql::database_user { $db_username:
    createrole => true,
    password_hash => $db_userpassword,
  }
  ->
  # Configure the tablespace (so where the data goes on disk)
  # The tablespace is by default in the $archive_root/xnatspace
  postgresql::tablespace { 'xnatspace':
    owner => $system_user,
    location => "$archive_root/xnatspace",
  }
  ->
  postgresql::db { $db_name:
    user => $db_username,
    password => $db_userpassword,
    tablespace => 'xnatspace',
  }
  ->
  # Remove the previous checkouts of xnat if present
  #FIXME: make this more safe, this is very very insecure!!!
#  exec { "remove-previous-checkout": # not good when testing
#    command => "/bin/rm -rf $installer_dir",
#  }
#  ->
#  wget::fetch { "download-xnat":
#    source => "ftp://ftp.nrg.wustl.edu/pub/xnat/xnat_1_6_1.tar.gz",
#    destination => "$download_dir/xnat_1_6_1.tar.gz",
#    timeout => 0,
#    verbose => true,
#  }
#  ->
#  archive { 'xnat-1.6.1': # not working, problems (access rights) when running as root?
#    ensure => present,
#    url    => 'ftp://ftp.nrg.wustl.edu/pub/xnat/xnat_1_6_1.tar.gz',
#    #url    => 'http://192.168.122.1/xnat_1_6_1.tar.gz',
#    target => $download_dir,
#    timeout => 240,  
#  }
#  ->
#  exec { "move-to-installer-dir": #nodig?
#    command => "/bin/mv $download_dir/xnat_1_6_1.tar.gz $installer_dir/"
#  }
#  ->
  # Clone the xnat builder dev branch
  exec { "mercurial-clone-xnatbuilder":
    command => "/usr/bin/hg clone http://hg.xnat.org/xnat_builder_1_6dev $installer_dir",
    creates => $installer_dir,
    timeout => 12000000,
  }
  ->
  # Clone the xnat pipeline dev branch	# where is this used for?
  exec { "mercurial-clone-xnat-pipeline":
    command => "/usr/bin/hg clone http://hg.xnat.org/pipeline_1_6dev $installer_dir/pipeline",
    creates => "$installer_dir/pipeline",
    timeout => 12000000,
  }
  ->
  #Configure the XNAT build properties.
  file { "$installer_dir/build.properties":
    ensure => file,
    content => template('xnat/build.properties.erb'),
    mode => '600',
  }
  #->
  #exec { "xnat-setup":	#JAVA_HOME not set, script not working, reason unknown
  #  command => "$installer_dir/bin/setup.sh",
  #  cwd => "$installer_dir",
  #  environment => "JAVA_HOME=$java_home",
  #  timeout => 36000000,
  #}
  #TODO: create tables and views using psql and find a way to supply the passwords and such
  #
  #->
  #exec { "postgresql-create-tables-and-views":
  #  command => "/usr/bin/psql"
  #}
    
}
