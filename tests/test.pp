# test script

xnat::xnatapp { 'xnat-web-app-1':
  db_name => "xnat",
  db_username => "xnat",
  db_userpassword => "blaat123",
  archive_root => "/home/xnat/data",
  xnat_url => "http://${ip_address}:8080/xnat-web-app-1",
  xnat_port => "8080",
  system_user => "xnat",
  instance_name => "xnat-web-app-1",
}
