class java {
  $jdk_download_url = "http://download.oracle.com/otn-pub/java/jdk/7u9-b05/jdk-7u9-linux-x64.tar.gz"
  $local_download_url = "/opt/tmp/jdk.tar.gz"
  $local_jdk_path = "/opt/java/jdk1.7.0_09"

  # create needed folders under /opt/
  file { [ 
    "/opt/tmp", 
    "/opt/java" ] :
    ensure => directory,
  } ->

  exec { "download-jdk-7" :
    command => "/usr/bin/wget --no-cookies --header 'Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com' ${jdk_download_url} -O ${local_download_url}",
    creates => $local_download_url,  
  } ->

  exec { "unpack-jdk" :
    command => "/bin/tar -xzf ${local_download_url} -C /opt/java",
    creates => $local_jdk_path,
  } ->

  exec { "update-alternatives" : 
    command => "/usr/bin/sudo /usr/sbin/update-alternatives --install '/usr/bin/java' 'java' '${local_jdk_path}/bin/java' 1",
    creates => "/usr/bin/java",
  }
}

class tomcat {
  $tomcat_version = "7.0.33"
  $tomcat_download_url = "http://www.eu.apache.org/dist/tomcat/tomcat-7/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz"
  $tomcat_download_local_url = "/opt/tmp/tomcat-${tomcat_version}.tar.gz"
  $tomcat_local_folder = "/opt/tomcat/${tomcat_version}"

  group { "tomcat" : 
    ensure => present,
  } ->
  
  user { "tomcat" : 
    ensure => present,
    gid => "tomcat",
    managehome => false,
    shell => "/bin/bash",
  } ->

  file { [ 
      "/opt/tomcat",
      $tomcat_local_folder
    ] :
    ensure => directory,
    recurse => true,
    owner => tomcat,
    group => tomcat,
  } ->

  exec { "download-tomcat" :
    command => "/usr/bin/wget ${tomcat_download_url} -O ${tomcat_download_local_url}",
    creates => $tomcat_download_local_url,
  } ->

  exec { "unpack-tomcat" : 
    command => "/bin/tar -xzf ${tomcat_download_local_url} -C /opt/tomcat/${tomcat_version} --strip-components=1",
    user => tomcat,
    creates => "${tomcat_local_folder}/bin",
  }

  service { "tomcat" : 
    ensure => running,
    start => "/opt/tomcat/${tomcat_version}/bin/startup.sh",
    stop => "/opt/tomcat/${tomcat_version}/bin/shutdown.sh",
    status => "",
    restart => "",
    hasstatus => false,
    hasrestart => false,
    require => Exec["unpack-tomcat"],
  }
}

class mysql {
  package { "mysql-server" : 
    ensure => present,
  }
  
  service { "mysql" : 
    ensure => running,
    require => Package["mysql-server"],
  }
}

include java
include mysql
include tomcat
