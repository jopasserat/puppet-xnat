# installs sun (JDK) java
class java {

  notify{"downloading and installing java": } ->

  # Use wget with a special header to circumvent the license agreement 
  # approval
  exec { "download-jdk-7-21": 
    command => "wget -O /tmp/jdk-7u21-linux-x64.tar.gz -nc --no-check-certificate --no-cookies --header \"Cookie: gpw_e24=null;\" http://download.oracle.com/otn-pub/java/jdk/7u21-b11/jdk-7u21-linux-x64.tar.gz",
    unless => "test -d /usr/lib/jvm/jdk1.7.0_21"
  } ->

  # Extract the jdk to the jvm directory
  exec { "extract-jdk-7-21": #file permissions incorrect
    command => "tar -zxvf /tmp/jdk-7u21-linux-x64.tar.gz -C /usr/lib/jvm/",
    unless => "test -d /usr/lib/jvm/jdk1.7.0_21"
  } ->

  # Remove the download file
  file { "cleanup java install":
    ensure => absent,
    path => "/tmp/jdk-7u21-linux-x64.tar.gz"
  } ->

  # Set correct Java version
  case $operatingsystem {
    centos, redhat, fedora: {
      exec { "update-java-alternatives set sun jdk":
        command => "alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.7.0_21/jre/bin/java 20000;\
                alternatives --install /usr/bin/javaws javaws /usr/lib/jvm/jdk1.7.0_21/jre/bin/javaws 20000;\
                alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk1.7.0_21/jre/bin/javac 20000;\
                alternatives --install /usr/bin/jar jar /usr/lib/jvm/jdk1.7.0_21/jre/bin/jar 20000;"
      }
   }
   default: {
      exec { "update-alternatives install sun jdk":
        command => "cat /usr/lib/jvm/.jdk1.7.0_21.jinfo | grep -E '^(jre|jdk)' | awk '{print \"/usr/bin/\" \$2 \" \" \$2 \" \" \$3 \" 30 \r \"}' | xargs -t -n4 update-alternatives --verbose --install"
      }
    }
  } ->

  notify{"installing java complete": }
}
