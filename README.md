Puppet-twemproxy
================

This module manages [twemproxy](http://www.github.com/twitter/twemproxy) package installation from source. It is based on and compatible with [puppet-twemproxy](https://forge.puppetlabs.com/wuakitv/twemproxy).

The support version of twemproxy is 0.4.0 to take advantage of various improvements and in addtion working tests and addtional stats parameters have been added. 

> Currently acceptance test using centos 6.5

> Currently only supports **REDIS** and not memcached.

## USAGE

```ruby
    twemproxy::resource::nutcracker4 { 'redis-twemproxy':
        redis_db             => 1,
        port                 => '22112',
        nutcracker_hash      => 'fnv1a_64',
        nutcracker_hash_tag  => '{}',
        distribution         => 'ketama',
        auto_eject_hosts     => true,
        verbosity            => 7,
        log_dir              => '/var/log/nutcracker',
        pid_dir              => '/var/run/nutcracker',
        statsaddress         => '127.0.0.1',
        statsport            => 22222,
        statsinterval        => 10000,
        members              =>  [
            {
                'ip'         => '127.0.0.1',
                'name'       => 'redis-6390',
                'redis_port' => '6379',
                'weight'     => '1',
                'timeout'    => 400
            },
            {
                'ip'         => '127.0.0.1',
                'name'       => 'redis-6391',
                'redis_port' => '6380',
                'weight'     => '1',
                'timeout'    => 400
            }
        ]
    }
```

## Testing

```bash
bundle install
bundle exec rake test
bundle exec rake beaker

BEAKER_setfile=spec/acceptance/nodesets/centos-7-x64.yml bundle exec rake beaker
```

## Dependencies

1. puppetlabs/stdlib


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
