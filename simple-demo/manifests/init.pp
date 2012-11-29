package { "nginx" :
  ensure => present,
}

service { "nginx" :
 ensure => running,
 require => Package["nginx"],
}

file { "/usr/share/nginx/www/index.html" : 
  source => "/vagrant/files/index.html",
}

