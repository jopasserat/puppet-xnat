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
  
  $tomcat_root = "$webapp_base/$system_user/tomcat"
  $installer_dir = "/home/$system_user/xnat-builder"
  $download_dir = "/home/$system_user/downloads"
  #$archive_dirs = split($archive_root,'/')
  $archive_dirs = ["$archive_root", "$archive_root/archive","$archive_root/build","$archive_root/cache","$archive_root/ftp","$archive_root/prearchive","$archive_root/modules"]
  
  # Add to paths. Could use absolute paths, but some external modules don't do this anyway.
  Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin' }
  
  # Get latest updates
  exec { "apt-get update":
    command => "apt-get update",
    onlyif => "sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || find apt/* -cnewer /ar/cache/apt/pkgcache.bin | grep . > /dev/null'",
  }
  ->

  # Use wget with a special header to circumvent the license agreement approval
  exec { "download-jdk-7-21":
    command => "wget -P /tmp/ -nc --no-cookies --header \"Cookie: gpw_e24=null;\" http://download.oracle.com/otn-pub/java/jdk/7u21-b11/jdk-7u21-linux-x64.tar.gz"
  }
  ->

  # Extract the jdk to the jvm directory
  exec { "extract-jdk-7-21": #file permissions incorrect
     command => "tar -zxvf /tmp/jdk-7u21-linux-x64.tar.gz -C /usr/lib/jvm/"
  }
  ->

  # Set correct java version
  exec { "update-alternatives install sun jdk":
    command => "cat /usr/lib/jvm/.jdk1.7.0_21.jinfo | grep -E '^(jre|jdk)' | awk '{print \"/usr/bin/\" \$2 \" \" \$2 \" \" \$3 \" 30 \r \"}' | xargs -t -n4 sudo update-alternatives --verbose --install"
  }
  -> 

  # Using update-java-alternatives to prevent console choices
  exec { "update-java-alternatives set sun jdk":
    command => "update-java-alternatives --set jdk1.7.0_21"
  }
  ->

  # Install tomcat
  ##tomcat::webapp { $instance_name:
  #  username => $system_user,
  #  webapp_base => $webapp_base,
  #  number => $xnat_number,
  #  java_opts => "-Xms512m -Xmx1024m",
  #}
  #->
  
  #tomcat::instance { $instance_name:
  #  ensure => present,
  #  owner => $system_user,
  #  http_port => $xnat_port,
  #  setenv => ['ADD_JAVA_OPTS="-Xms512m -Xmx1024m"'],
  #}
  #->
  
  # Ensure archive directories are present
  exec {"make xnat archive directories":
    command => "sh /etc/puppet/modules/xnat/tests/makedirs.sh"
  }
  ->
  
  # Configure the postgres db (step 2).
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

  # Add user with password
  postgresql::db { $db_name:
    user => $db_username,
    password => $db_userpassword,
    tablespace => 'xnatspace',
  }
  ->
  
  # Remove the previous checkouts of xnat if present
  #FIXME: make this more safe, this is very very insecure!!!
  #exec { "remove-previous-checkout": # not good when testing
  #  command => "/bin/rm -rf $installer_dir",
  #}
  #->

  # Clone the xnat builder dev branch
  exec { "mercurial-clone-xnatbuilder":
    command => "hg clone http://hg.xnat.org/xnat_builder_1_6dev $installer_dir",
    creates => $installer_dir,
    timeout => 3600000,
  }
  ->

  # Clone the xnat pipeline dev branch
  exec { "mercurial-clone-xnat-pipeline":
    command => "hg clone http://hg.xnat.org/pipeline_1_6dev $installer_dir/pipeline",
    creates => "$installer_dir/pipeline",
    timeout => 3600000,
  }
  ->

  # Handle permissions (using file is terribly slow as it checks each file)
  exec { "set xnat permissions":
    command => "chown -R xnat:xnat $installer_dir"
  }
  ->

  # Configure the XNAT build properties.
  file { "$installer_dir/build.properties":
    ensure => file,
    content => template('xnat/build.properties.erb'),
    mode => '600'
  }
  ->

  # Execute the setup script
  # TODO Failes for second time
  exec { "xnat-setup":
    command => "$installer_dir/bin/setup.sh > setup.out",
    cwd => "$installer_dir",
    environment => "JAVA_HOME=$java_home",
    timeout => 3600000
  }
  ->

  # Create tables and views using psql and find a way to supply the passwords and such
  # TODO Failes for second time
  exec { "postgresql-create-tables-and-views":
    command => "sudo -u xnat psql -d $system_user -f $installer_dir/deployments/$instance_name/sql/$instance_name.sql -U $db_username > psql.out"
  }
  ->
  
  # TODO Failes for second time
  exec { "store initial security settings":
    command => "$installer_dir/bin/StoreXML -project $instance_name -l security/security.xml -allowDataDeletion true > security.out",
    cwd => "$installer_dir/deployments/$instance_name"
  }
  ->

  exec { "optional: store example custom variable sets":
    command => "$installer_dir/bin/StoreXML -dir ./work/field_groups -u admin -p admin -allowDataDeletion true > example.out",
    cwd => "$installer_dir/deployments/$instance_name"
  }
  ->

  exec {"deploy webapp":
    command => "mv $installer_dir/deployments/$instance_name/target/$instance_name.war /var/lib/tomcat7/webapps/"
  }
  ->

  # Use update.sh for easier debugging, but takes some time as it recompiles the sources
  #exec { "deploy webapp":
  #  command => "$installer_dir/bin/update.sh -Ddeploy=true",
  #  cwd => "$installer_dir",
  #  environment => "JAVA_HOME=$java_home"
  #}
  #->

  # Make the WAR readable for the tomcat server
  #file { "/var/lib/tomcat7/webapps/xnat-web-app-1.war":
  #  owner => tomcat7,
  #  group => tomcat7,
  #  mode => 755
  #}
}
