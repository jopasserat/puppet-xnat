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
class tomcat {

  notify {"downloading and installing tomcat": } ->

  exec { "download tomcat":
    command => "wget -P /tmp/ http://apache.mirror.1000mbps.com/tomcat/tomcat-7/v7.0.47/bin/apache-tomcat-7.0.47.tar.gz",
    unless => "test -d /usr/share/tomcat7/bin/",
    timeout => 1800000
  } ->
  
  exec { "extract tomcat":
    command => "tar -xzf /tmp/apache-tomcat-7.0.47.tar.gz -C /usr/share/;mv /usr/share/apache-tomcat-7.0.47 /usr/share/tomcat7/",
    unless => "test -d /usr/share/tomcat7/bin/"
  } ->

  exec { "set permissions":
    command => "chown -R tomcat:tomcat /usr/share/tomcat7/"
  } ->
  
  file { "cleanup tomcat install":
    ensure => absent,
    path => "/tmp/apache-tomcat-7.0.47.tar.gz"
  } ->

  file { "write setenv": 
    path => "/usr/share/tomcat7/bin/setenv.sh",
    ensure => present,
    #content => "export JAVA_HOME=/usr/lib/jvm/jdk1.7.0_21\nexport JAVA_OPTS=\"-Xms512m -Xmx1024m\"",
    content => template("xnat/setenv.sh.erb"),
    mode => '600'
  } ->

  notify {"installing tomcat complete": }

}

