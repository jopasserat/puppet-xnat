xnat::xnatapp { 'xnat-web-app-1':
  db_name => "xnat",
  db_username => "xnat",
  db_userpassword => "test123",
  system_user => "xnat",   # Cannot be changed (for now)
  instance_name => "ROOT", # Cannot be changed (for now) 
  archive_root => "/xnatdata",
  tomcat_web_user => "evast",
  tomcat_web_password => "test123",
  tomcat_port => "8090",
  apache_port => "80",
  apache_mail_address => "xnat@localhost",
  xnat_version => "1.6.3",
  java_opts => "-Xms1024m -Xmx6144m -XX:MaxPermSize=256m",
  catalina_tmp_dir => "/xnatdata/test",
  mail_server => "localhost",
  mail_port => 25,
  mail_username => "mailuser",
  mail_password => "mailpass",
  mail_admin => "admin@localhost",
  mail_subject => "XNAT",
  tablespace_dir => "/xnatdata/database"
}
