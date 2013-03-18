redis::setup { 'fc-redis':
  ensure        => present,
  deploymentdir => '/opt/redis',
  version       => '2.6.11',
}
