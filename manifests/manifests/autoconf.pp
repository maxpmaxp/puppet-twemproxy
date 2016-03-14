class twemproxy::autoconf {

  include twemproxy::params
  include twemproxy::package

  anchor { 'twemproxy::autoconf::begin': }
  anchor { 'twemproxy::autoconf::end': }

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  $prefix = $twemproxy::params::default_prefix

  # at least for centos 6.5 & 6.6 this is the minimum required version
  $resource = 'autoconf-2.69'

  Anchor['twemproxy::autoconf::begin'] ->
  file { "${prefix}/src/${resource}.tar.gz":
    ensure => 'file',
    source => "puppet:///modules/twemproxy/${resource}.tar.gz"
  } ->
  exec { "tar-xvfz-${resource}":
    command => "tar xvzf ${resource}.tar.gz",
    cwd     => "${prefix}/src",
    creates => "${prefix}/src/${resource}"
  } ->
  exec { "configure-${resource}":
    command  => './configure --prefix=/usr',
    provider => shell,
    cwd      => "${prefix}/src/${resource}",
    creates  => "${prefix}/src/${resource}/config.status",
    require  => Class['twemproxy::package']
  } ->
  exec { "make-${resource}":
    command   => 'make && make install',
    provider  => shell,
    logoutput => false,
    cwd       => "${prefix}/src/${resource}",
    creates   => "${prefix}/src/${resource}/bin/autoconf",
    require   => Class['twemproxy::package']
  } ->
  Anchor['twemproxy::autoconf::end']
}
