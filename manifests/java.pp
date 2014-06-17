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

# installs sun (JDK) java
class java {
  $java_major_version = "7"
  $java_minor_version = "60"
  $java_b_version = "19"
  $java_short_version = "${java_major_version}u${java_minor_version}"
  $java_long_version = "jdk1.${java_major_version}.0_${java_minor_version}"

  notify{"downloading and installing java": } ->

  # Use wget with a special header to circumvent the license agreement approval
  exec { "download-jdk-${java_short_version}": 
    command => "wget -O /tmp/jdk-${java_short_version}-linux-x64.tar.gz -nc --no-check-certificate --no-cookies --header \"Cookie: oraclelicense=accept-securebackup-cookie;\" http://download.oracle.com/otn-pub/java/jdk/${java_short_version}-b${java_b_version}/jdk-${java_short_version}-linux-x64.tar.gz",
    unless => "test -d /usr/lib/jvm/${java_long_version}",
    timeout => 3600
  } ->

  # Extract the jdk to the jvm directory
  exec { "extract-jdk-${java_short_version}":
    command => "tar -zxvf /tmp/jdk-${java_short_version}-linux-x64.tar.gz -C /usr/lib/jvm/",
    unless => "test -d /usr/lib/jvm/${java_long_version}"
  } ->

  # Remove the download file
  file { "cleanup java install":
    ensure => absent,
    path => "/tmp/jdk-${java_short_version}-linux-x64.tar.gz"
  } ->

  # Set correct Java version
  case $operatingsystem {
    centos, redhat, fedora: {
      exec { "update-java-alternatives set sun jdk":
        command => "alternatives --install /usr/bin/java java /usr/lib/jvm/${java_long_version}/jre/bin/java 20000;\
                alternatives --install /usr/bin/javaws javaws /usr/lib/jvm/${java_long_version}/jre/bin/javaws 20000;\
                alternatives --install /usr/bin/javac javac /usr/lib/jvm/${java_long_version}/jre/bin/javac 20000;\
                alternatives --install /usr/bin/jar jar /usr/lib/jvm/${java_long_version}/jre/bin/jar 20000;"
      }
   }
   default: {
      exec { "update-alternatives install sun jdk":
        command => "cat /usr/lib/jvm/.${java_long_version}.jinfo | grep -E '^(jre|jdk)' | awk '{print \"/usr/bin/\" \$2 \" \" \$2 \" \" \$3 \" 30 \r \"}' | xargs -t -n4 update-alternatives --verbose --install"
      }
    }
  } ->

  notify{"installing java complete": }
}
