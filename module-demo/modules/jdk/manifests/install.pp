class jdk::install {

  $local_package_url = "/tmp/jdk.tar.gz"
  $local_jdk_path = "/opt/java/jdk1.7.0_09"

  # create needed folders under /opt/
  file { "/opt/java" :
    ensure => directory,
  }

  file { $local_package_url :
    source => "puppet:///modules/jdk/jdk.tar.gz"
  }
  
  exec { "unpack-jdk" :
    command => "/bin/tar -xzf ${local_package_url} -C /opt/java",
    require => File[$local_package_url],
  }

  exec { "update-alternatives" : 
    command => "/usr/bin/sudo /usr/sbin/update-alternatives --install '/usr/bin/java' 'java' '${local_jdk_path}/bin/java' 1",
    creates => "/usr/bin/java",
    require => Exec["unpack-jdk"],
  }
  
}
