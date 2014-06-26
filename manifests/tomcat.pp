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

# Download and install tomcat
define tomcat (
  $tomcat_web_user,
  $tomcat_web_password,
  $tomcat_port)
{
  include wget

  $apache_major_version = "7"
  $apache_full_version = "7.0.54"

  if $tomcat_exists == 'true' {
    notify {"tomcat already installed": }

  } else {
    notify {"downloading and installing tomcat": } ->

    wget::fetch { "download tomcat":
      source => "http://apache.mirror.1000mbps.com/tomcat/tomcat-${apache_major_version}/v${apache_full_version}/bin/apache-tomcat-${apache_full_version}.tar.gz",
      destination => "/tmp/apache-tomcat-${apache_full_version}.tar.gz",
      timeout => 3600,
      verbose => false,
    } ->

    exec { "extract tomcat":
      command => "tar -xzf /tmp/apache-tomcat-${apache_full_version}.tar.gz -C /usr/share/;mv /usr/share/apache-tomcat-${apache_full_version} /usr/share/tomcat${apache_major_version}/",
      unless => "test -d /usr/share/tomcat${apache_major_version}/bin/"
    } ->

    file { "/usr/share/tomcat${apache_major_version}/":
      owner => "tomcat",
      group => "tomcat",
      mode => 0644,
      recurse => true
    } ->

    file { "set tomcat execute permissions":
      path => "/usr/share/tomcat${apache_major_version}/bin/",
      mode => '644'
    } ->
  
    file { "cleanup tomcat install":
      ensure => absent,
      path => "/tmp/apache-tomcat-${apache_full_version}.tar.gz"
    } ->

    file { "write setenv": 
      path => "/usr/share/tomcat${apache_major_version}/bin/setenv.sh",
      ensure => present,
      content => template("xnat/setenv.sh.erb"),
      mode => '644'
    } ->

    file { "write tomcat-users":
      path => "/usr/share/tomcat${apache_major_version}/conf/tomcat-users.xml",
      ensure => present,
      content => template("xnat/tomcat-users.xml.erb"),
      mode => '644'
    } ->

    exec { "change connector port":
      command => "sed 's/8080/$tomcat_port/g' server.xml > tmp && mv -f tmp server.xml",
      cwd => "/usr/share/tomcat${apache_major_version}/conf/"
    } ->

    notify {"installing tomcat complete": }
  }
}
