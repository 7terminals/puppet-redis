# Class: redis
#
# This module manages redis
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
define redis::setup (
  $ensure             = 'present',
  $source             = 'redis-2.6.11.tar.gz',
  $version            = '2.6.11',
  $deploymentdir      = '/usr/local/bin',
  $build_packages     = true,
  $port               = '6379',
  $config_file_path   = "/etc/${name}.conf",
  $daemonize          = 'yes',
  $pidfile            = "/var/run/${name}.pid",
  $bind               = $::ipaddress,
  $connection_timeout = '0',
  $tcp_keepalive      = '0',
  $log_level          = 'notice',
  $logfile            = 'stdout',
  $syslog_enabled     = 'no',
  $syslog_ident       = 'redis',
  $syslog_facility    = 'local0',
  $databases          = '16',
  $stop_writes_on_bgsave_error = 'yes',
  $rdbcompression     = 'yes',
  $rdbchecksum        = 'yes',
  $dbfilename         = 'dump.rdb',
  $dir                = './',
  $slaveof            = undef,
  $masterauth         = undef,
  $slave_serve_stale_data      = 'yes',
  $slave_read_only    = 'yes',
  $repl_ping_slave_period      = '10',
  $repl_timeout       = '60',
  $repl_disable_tcp_nodelay    = 'no',
  $slave_priority     = '100',
  $requirepass        = undef,
  $maxclients         = '10000',
  $maxmemory          = '<bytes>',
  $maxmemory_policy   = 'volatile-lru',
  $maxmemory_samples  = '3',
  $appendonly         = 'no',
  $appendfsync        = 'everysec',
  $no_appendfsync_on_rewrite   = 'no',
  $auto_aof_rewrite_percentage = '100',
  $auto_aof_rewrite_min_size   = '64mb',
  $lua_time_limit     = '5000',
  $slowlog_log_slower_than     = '10000',
  $slowlog_max_len    = '128',
  $hash_max_ziplist_entries    = '512',
  $hash_max_ziplist_value      = '64',
  $list_max_ziplist_entries    = '512',
  $list_max_ziplist_value      = '64',
  $set_max_intset_entries      = '512',
  $zset_max_ziplist_entries    = '128',
  $zset_max_ziplist_value      = '64',
  $activerehashing    = 'yes',
  $client_output_buffer_limit  = 'normal 0 0 0',
  $hz                 = '10',
  $cachedir           = "/var/run/puppet/redis_setup_working-${name}") {
  # Quick input validation
  if !($ensure in ['absent', 'present']) {
    fail('ensure parameter must be absent or present')
  }

  if $ensure == 'present' {
    # Resource defaults for Exec
    Exec {
      path => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'], }

    if $build_packages == true {
      # Packages required to build Redis
      package { ['gcc', 'make', 'jemalloc-devel']: ensure => installed, }
    }

    # Working dir to build Redis
    file { $cachedir:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '644'
    }

    file { "${cachedir}/${source}":
      source  => ["puppet:///modules/${caller_module_name}/${source}", "puppet:///modules/${module_name}/${source}"],
      require => File[$cachedir],
    }

    exec { "extract_redis-${name}":
      cwd     => $cachedir,
      command => "mkdir extracted; tar -C extracted -xzf ${source} && touch .redis_extracted",
      creates => "${cachedir}/.redis_extracted",
      require => File["${cachedir}/${source}"],
    }

    exec { "compile_redis-${name}":
      cwd     => "${cachedir}/extracted/redis-${version}",
      command => 'make',
      timeout => 0,
      creates => "${cachedir}/extracted/redis-${version}/src/redis-server",
      require => Exec["extract_redis-${name}"],
    }

    exec { "create_deployment_dir-${name}":
      cwd     => '/',
      command => "mkdir -p ${deploymentdir}",
      creates => $deploymentdir,
      require => Exec["compile_redis-${name}"],
    }

    exec { "install_redis-${name}":
      cwd     => "${cachedir}/extracted/redis-${version}",
      command => "make PREFIX=${deploymentdir} install",
      creates => "${deploymentdir}/bin/redis-server",
      require => Exec["create_deployment_dir-${name}"],
    }

    file { $config_file_path:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      content => template("${module_name}/redis.conf.erb"),
      require => Exec["install_redis-${name}"]
    }

    file { "/etc/init.d/${name}":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => 755,
      content => template("${module_name}/redis_init_script.erb"),
      require => File[$config_file_path],
    }

    service { "/etc/init.d/${name}":
      ensure  => running,
      enable  => true,
      require => File["/etc/init.d/${name}"],
    }
  }
}