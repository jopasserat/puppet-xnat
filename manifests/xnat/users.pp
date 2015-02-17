user { 'tomcat':
  ensure => 'present',
  system => true,
}

user { 'xnat':
  ensure      => 'present',
  managerhome =>  true,
  system      =>  true,
}

