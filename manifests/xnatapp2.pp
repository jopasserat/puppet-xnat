Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin' }

exec { "echo":
  command => "echo test",
  unless => "test.sh"
}
