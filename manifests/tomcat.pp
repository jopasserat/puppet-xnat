# Download and install tomcat
class tomcat {
  exec { "download tomcat":
    command => "wget -P /tmp/ http://apache.mirror.1000mbps.com/tomcat/tomcat-7/v7.0.42/bin/apache-tomcat-7.0.42.tar.gz",
    unless => "test -d /usr/share/tomcat7/"
  }->
   
  exec { "extract tomcat":
    command => "tar -xzf /tmp/apache-tomcat-7.0.42.tar.gz -C /usr/share/;mv /usr/share/apache-tomcat-7.0.42 /usr/share/tomcat7/",
    unless => "test -d /usr/share/tomcat7/"
  }->
  
  file { "cleanup tomcat install":
    ensure => absent,
    path => "/tmp/apache-tomcat-7.0.42.tar.gz"
  }
}
