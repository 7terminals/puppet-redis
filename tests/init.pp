class { 'redis':
  ensure        => present,
  deploymentdir => '/opt/redis',
}
