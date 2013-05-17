# test script
xnat::xnatapp { 'xnat-web-app-1':
  db_name => "xnat",
  db_username => "xnat",
  db_userpassword => "blaat123",
  archive_root => "/data/XNAT",
  xnat_url => "http://xnatws:8080/xnat-web-app-1",
  xnat_port => "8080",
  xnat_number => "0", #this is the prefix of the port number starting with: 808x
  system_user => "xnat",
  instance_name => "xnat-web-app-1",
  webapp_base => "/home",
  download_method => "ftp",
}