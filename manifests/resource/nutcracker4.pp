define twemproxy::resource::nutcracker4 (
  $ensure               = 'present',
  $port                 = '22111',
  $nutcracker_hash      = 'fnv1a_64',
  $nutcracker_hash_tag  = '{}',
  $distribution         = 'ketama',
  $twemproxy_timeout    = '400',
  $auto_eject_hosts     = false,
  $server_retry_timeout = '3000',
  $server_failure_limit = '3',
  $redis                = true,
  $redis_db             = 0,

  $verbosity            = 6,  # 6-11

  $log_dir              = '/var/log/nutcracker',
  $pid_dir              = '/var/run/nutcracker',
  $conf_dir             = '/opt/nutcracker/etc',

  $statsaddress         = '127.0.0.1',
  $statsport            = 22222,
  $statsinterval        = 30000,  # msec

  $members              = undef,

  $service_enable       = true,
  $service_manage       = true,
  $service_ensure       = 'running'
) {

  include stdlib
  include twemproxy::install

  #
  # installed service name derived from $name
  # i.e. File[/etc/init.d/nutcracker]/notify: subscribes to Service[twemproxy]
  #

  if !is_integer($port) {
    fail('$port must be an integer.')
  }
  validate_string($nutcracker_hash)
  validate_string($nutcracker_hash_tag)
  validate_string($distribution)
  if !is_integer($twemproxy_timeout) {
    fail('$twemproxy_timeout must be an integer.')
  }
  validate_bool($auto_eject_hosts)
  if !is_integer($server_retry_timeout) {
    fail('$server_retry_timeout must be an integer.')
  }
  if !is_integer($server_failure_limit) {
    fail('$server_failure_limit must be an integer.')
  }
  validate_bool($redis)
  if !is_integer($verbosity) {
    fail('$verbosity must be an integer (6-11).')
  }
  validate_absolute_path($log_dir)
  validate_absolute_path($pid_dir)
  if !is_ip_address($statsaddress) {
    fail('$statsaddress must be a valid IP adress.')
  }
  if !is_integer($statsport) {
    fail('$statsport must be an integer.')
  }
  if !is_integer($statsinterval) {
    fail('$statsinterval must be an integer.')
  }
  validate_array($members)
  validate_bool($service_enable)
  validate_bool($service_manage)
  validate_string($service_ensure)

  twemproxy::service { $name:
    service_name   => $name,
    service_enable => $service_enable,
    service_manage => $service_manage,
    service_ensure => $service_ensure,
    require        => Anchor['twemproxy::install::end']
  }

  notify { "Working with ${distribution} ${nutcracker_hash} on ${port}": }

  if ! defined(File[$conf_dir]) {
    exec { "Create ${conf_dir}":
      creates => $conf_dir,
      command => "mkdir -m 0755 -p ${conf_dir}",
      path => $::path
    } -> file { $conf_dir : }
  }

  if ! defined(File[$log_dir]) {
    file { $log_dir:
      ensure => 'directory',
      mode   => '0777'
    }
  }

  if ! defined(File[$pid_dir]) {
    file { $pid_dir:
      ensure => 'directory',
      mode   => '0755'
    }
  }

  if $::operatingsystem == "Ubuntu"{
    $mode = '0644'
    $service_template_os_specific = 'twemproxy/nutcracker.unit.erb'
    $service_init = "/etc/systemd/system/${name}.service"
  } else {
    $mode = '0755'
    $service_template_os_specific = $::osfamily ? {
      'RedHat' => 'twemproxy/nutcracker-redhat.erb',
      'Debian' => 'twemproxy/nutcracker.erb',
      default  => 'twemproxy/nutcracker.erb',
    }
    $service_init = "/etc/init.d/${name}"
  }



  file { "${conf_dir}/${name}.yml":
    ensure  => present,
    content => template('twemproxy/pool.erb', 'twemproxy/members.erb'),
    require => Anchor['twemproxy::install::end']
  } ->
  file {  $service_init:
    ensure  => present,
    mode    => $mode,
    content => template($service_template_os_specific),
    require => [ Anchor['twemproxy::install::end'], File[$log_dir], File[$pid_dir] ]
  } ~>
  exec { "${name}-systemd-daemon-reload":
    command     => 'systemctl daemon-reload',
    refreshonly => true,
    path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin']
  } ~>
  Service["${name}"]

}
