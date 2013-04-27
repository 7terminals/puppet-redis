redis
====


Overview
--------

The Redis module installs the redis server.


Module Description
-------------------

The Redis module allows Puppet to install Redis and maintain it's configuration. 

Setup
-----

**What redis affects:**

* installation directory for redis
* configuration file for redis and it't init script
	
### Beginning with Redis

To setup Redis on a server

    redis::setup { 'redis':
      ensure        => present,
      deploymentdir => '/usr/local/redis',
      version       => '2.6.11',
    }

Usage
------

The `redis::setup` resource definition has several parameters to assist installation of redis.

**Parameters within `redis`**

####`ensure`
This parameter specifies whether redis should be deployed to the deployment directory or not.
Valid arguments are "present" or "absent".

Defaults to present.

####`source`
This parameter specifies the source for the redis archive. 
This file must be in the files directory in the caller module. 
**Only .tar.gz source archives are supported.**


####`version`
This is the version of the redis deployment. It needs to match the source archive's version prefix.


####`deploymentdir`
This parameter specifies the directory where ant will be installed.

Defaults to /usr/local/redis.

Note: If deploymentdir is set to /usr/local/, and you want to remove this installation in the future, setting ensure => 'absent' will cause the entire directory, i. e. /usr/local/ to be deleted permanently.

####`port`
Accept connections on the specified port.
Defaults to 6379.

####`bind`
If you want you can bind a single interface, if the bind option is not specified all the interfaces will listen for incoming connections.

Defaults to $::ipaddress.

####`connection_timeout`

Defaults to 0.

####`tcp_keepalive`
If non-zero, use SO_KEEPALIVE to send TCP ACKs to clients in absence of communication. This is useful for two reasons:

1) Detect dead peers.
2) Take the connection alive from the point of view of network equipment in the middle.

On Linux, the specified value (in seconds) is the period used to send ACKs.
Note that to close the connection the double of the time is needed.

Defaults to 0.

####`log_level`
Specify the server verbosity level.

This can be one of:
debug (a lot of information, useful for development/testing)
verbose (many rarely useful info, but not a mess like the debug level)
notice (moderately verbose, what you want in production probably)
warning (only very important / critical messages are logged)

Defaults to notice.

####`logfile`
Specify the log file name.

Defaults to /dev/null.

####`syslog_enabled`
To enable logging to the system logger, set to yes.

Defaults to no.

####`syslog_ident`
Specify the syslog identity.

Defaults to redis.

####`syslog_facility`
Specify the syslog facility. Must be USER or between LOCAL0-LOCAL7.

Defaults to local0.

####`databases`
Set the number of databases.

Defaults to 16.

####`stop_writes_on_bgsave_error`

Defaults to yes.

####`rdbcompression`

Defaults to yes.

####`rdbchecksum`
Since version 5 of RDB a CRC64 checksum is placed at the end of the file. This makes the format more resistant to corruption but there is a performance hit to pay (around 10%) when saving and loading RDB files, so you can disable it for maximum performances.

Defaults to yes.

####`dbfilename`
The filename where to dump the DB

Defaults to dump.rdb.

####`dir`
The working directory. The DB will be written inside this directory, with the filename specified above using the 'dbfilename' configuration directive.

Defaults to ./.

####`slaveof`
Use slaveof to make a Redis instance a copy of another Redis server.

Defaults to none.

####`masterauth`
If the master is password protected (using the "requirepass" configuration directive below) it is possible to tell the slave to authenticate before starting the replication synchronization process, otherwise the master will refuse the slave request.

Defaults to undef.

####`slave_serve_stale_data`
When a slave loses its connection with the master, or when the replication is still in progress, the slave can act in two different ways:

1) if slave-serve-stale-data is set to 'yes' (the default) the slave will still reply to client requests, possibly with out of date data, or the data set may just be empty if this is the first synchronization.

2) if slave-serve-stale-data is set to 'no' the slave will reply with an error "SYNC with master in progress" to all the kind of commands but to INFO and SLAVEOF.

Defaults to yes.

####`slave_read_only`
You can configure a slave instance to accept writes or not. Writing against a slave instance may be useful to store some ephemeral data (because data written on a slave will be easily deleted after resync with the master) but may also cause problems if clients are writing to it because of a misconfiguration.

Defaults to yes.

####`repl_ping_slave_period`
Slaves send PINGs to server in a predefined interval. It's possible to change this interval with the repl_ping_slave_period option. The default value is 10 seconds.

####`repl_timeout`
The following option sets a timeout for both Bulk transfer I/O timeout and master data or ping response timeout. The default value is 60 seconds.

####`repl_disable_tcp_nodelay`
Disable TCP_NODELAY on the slave socket after SYNC?

If you select "yes" Redis will use a smaller number of TCP packets and less bandwidth to send data to slaves. But this can add a delay for the data to appear on the slave side, up to 40 milliseconds with Linux kernels using a default configuration.

If you select "no" the delay for data to appear on the slave side will be reduced but more bandwidth will be used for replication.

By default we optimize for low latency, but in very high traffic conditions or when the master and slaves are many hops away, turning this to "yes" may be a good idea.

Defaults to no.

####`slave_priority`
The slave priority is an integer number published by Redis in the INFO output.
It is used by Redis Sentinel in order to select a slave to promote into a master if the master is no longer working correctly.

A slave with a low priority number is considered better for promotion, so for instance if there are three slaves with priority 10, 100, 25 Sentinel will pick the one wtih priority 10, that is the lowest.

However a special priority of 0 marks the slave as not able to perform the role of master, so a slave with priority of 0 will never be selected by Redis Sentinel for promotion.

By default the priority is 100.

####`requirepass`
Require clients to issue AUTH <PASSWORD> before processing any other commands.  This might be useful in environments in which you do not trust others with access to the host running redis-server.

Defaults to none.

####`maxclients`
Set the max number of connected clients at the same time. By default this limit is set to 10000 clients

####`maxmemory`
hen the memory limit is reached Redis will try to remove keys accordingly to the eviction policy selected (see maxmemmory-policy)

Defaults to <bytes>.

####`maxmemory_policy`
This is how Redis will select what to remove when maxmemory is reached. You can select among five behaviors:
volatile-lru    -> remove the key with an expire set using an LRU algorithm 
allkeys-lru     -> remove any key accordingly to the LRU algorithm
volatile-random -> remove a random key with an expire set
allkeys-random  -> remove a random key, any key
volatile-ttl    -> remove the key with the nearest expire time (minor TTL)
noeviction      -> don't expire at all, just return an error on write operations

Defaults to volatile-lru.

####`maxmemory_samples`
LRU and minimal TTL algorithms are not precise algorithms but approximated algorithms (in order to save memory), so you can select as well the sample size to check.

Defaults to 3.

####`appendonly`
The Append Only File is an alternative persistence mode that provides much better durability.

Defaults to no.

####`appendfsync`
Redis supports three different modes:

no      : don't fsync, just let the OS flush the data when it wants. Faster.
always  : fsync after every write to the append only log . Slow, Safest.
everysec: fsync only one time every second. Compromise.

The default is "everysec", as that's usually the right compromise between speed and data safety. It's up to you to understand if you can relax this to "no" that will let the operating system flush the output buffer when it wants, for better performances (but if you can live with the idea of some data loss consider the default persistence mode that's snapshotting), or on the contrary, use "always" that's very slow but a bit safer than everysec.

####`no_appendfsync_on_rewrite`
If you have latency problems turn this to "yes". Otherwise leave it as "no" that is the safest pick from the point of view of durability.

Defaults to no.

####`auto_aof_rewrite_percentage`
Redis is able to automatically rewrite the log file implicitly calling BGREWRITEAOF when the AOF log size grows by the specified percentage.

Defaults to 100.

####`auto_aof_rewrite_min_size`
You need to specify a minimal size for the AOF file to be rewritten, this is useful to avoid rewriting the AOF file even if the percentage increase is reached but it is still pretty small.

Defaults to 64mb.

####`lua_time_limit`
If the maximum execution time is reached, Redis will log that a script is still in execution after the maximum allowed time and will start to reply to queries with an error.

Set it to 0 or a negative value for unlimited execution without warnings.

Defaults to 5000.

####`slowlog_log_slower_than`

Defaults to 10000.

####`slowlog_max_len`
This is the length of the slow log. When a new command is logged the oldest one is removed from the queue of logged commands.

Defaults to 128.

####`hash_max_ziplist_entries`
Hashes are encoded using a memory efficient data structure when they have a small number of entries, and the biggest entry does not exceed a given threshold.

Defaults to 512.

####`hash_max_ziplist_value`
Hashes are encoded using a memory efficient data structure when they have a small number of entries, and the biggest entry does not exceed a given threshold.

Defaults to 64.

####`list_max_ziplist_entries`
Small lists are also encoded in a special way in order to save a lot of space. Set the maximum entries here.

Defaults to 512.

####`list_max_ziplist_value`
Set the maximum values for the zip list.

Defaults to 64.

####`set_max_intset_entries`
Sets have a special encoding in just one case: when a set is composed of just strings that happens to be integers in radix 10 in the range of 64 bit signed integers. This parameter sets the limit in the size of the set in order to use this special memory saving encoding.

Defaults to 512.

####`zset_max_ziplist_entries`
Similarly to hashes and lists, sorted sets are also specially encoded in order to save a lot of space.
This parameter sets the max entries for this set.

Defaults to 128.

####`zset_max_ziplist_value`
Set the maximum values for the list.

Defaults to 64.

####`activerehashing`
Active rehashing uses 1 millisecond every 100 milliseconds of CPU time in order to help rehashing the main Redis hash table (the one mapping top-level keys to values). The hash table implementation Redis uses performs a lazy rehashing: the more operation you run into an hash table that is rehashing, the more rehashing "steps" are performed, so if the server is idle the rehashing is never complete and some more memory is used by the hash table.

The default is to use this millisecond 10 times every second in order to active rehashing the main dictionaries, freeing memory when possible.

If unsure:
Set to "no" if you have hard latency requirements and it is not a good thing in your environment that Redis can reply form time to time to queries with 2 milliseconds delay.

Set to "yes" if you don't have such hard requirements but want to free memory asap when possible.

Defaults to yes.

####`hz`
Redis calls an internal function to perform many background tasks, like closing connections of clients in timeot, purging expired keys that are never requested, and so forth.

Not all tasks are perforemd with the same frequency, but Redis checks for tasks to perform accordingly to the specified "hz" value.

By default "hz" is set to 10. Raising the value will use more CPU when Redis is idle, but at the same time will make Redis more responsive when there are many keys expiring at the same time, and timeouts may be handled with more precision.

The range is between 1 and 500, however a value over 100 is usually not a good idea. Most users should use the default of 10 and raise this up to 100 only in environments where very low latency is required.


Limitations
------------

This module has been built and tested using Puppet 2.6.x, 2.7, and 3.x.

The module has been tested on:

* CentOS 5.9
* CentOS 6.4
* Debian 6.0 
* Ubuntu 12.04

Testing on other platforms has been light and cannot be guaranteed. 

Development
------------

Bug Reports
-----------

Release Notes
--------------

**0.1.0**

First initial release.
