define mk_xnat_dir(
  $archive_root
) {
    file {"/${archive_root}/$name":
      ensure => directory,
      mode   => 0755,
      owner  => $::tomcat::user,
      group  => $::tomcat::group,
    }
  }
