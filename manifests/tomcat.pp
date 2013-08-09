# Download and install tomcat
class tomcat {
  exec { "download tomcat":
    command => "wget -P /tmp/ http://apache.mirror.1000mbps.com/tomcat/tomcat-7/v7.0.42/bin/apache-tomcat-7.0.42.tar.gz",
    unless => "test -d /usr/share/tomcat7/"
  } ->
   
  exec { "extract tomcat":
    command => "tar -xzf /tmp/apache-tomcat-7.0.42.tar.gz -C /usr/share/;mv /usr/share/apache-tomcat-7.0.42 /usr/share/tomcat7/",
    unless => "test -d /usr/share/tomcat7/"
  } ->

  exec { "set permissions":
    command => "chown -R tomcat:tomcat /usr/share/tomcat7/"
  } ->
  
  file { "cleanup tomcat install":
    ensure => absent,
    path => "/tmp/apache-tomcat-7.0.42.tar.gz"
  } ->

  file { "testfile": 
    path => "/usr/share/tomcat7/bin/setenv.sh",
    ensure => present,
    #content => "export JAVA_HOME=/usr/lib/jvm/jdk1.7.0_21\nexport JAVA_OPTS=\"-Xms512m -Xmx1024m\"",
    content => template("xnat/setenv.sh.erb"),
    mode => '600'
  }
}
