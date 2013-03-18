redis::setup { 'redis':
  ensure        => present,
  deploymentdir => '/opt/redis',
  version       => '2.6.11',
}
