class nagios_custom (

        $username = 'nagios',

        $password = 'nagios',

        $socket   = '/var/lib/mysql/mysql.sock',

) {



 package { "nagios-common":

       provider => "rpm",

       ensure => installed,

       source => "yum/channels/rhel-x86_64-server-6-ost-4/nagios-common-3.5.1-2.el6ost.x86_64.rpm",

       } ->

 package { "nrpe":

       provider => "rpm",

       ensure => installed,

       source => "yum/channels/rhel-x86_64-server-6-ost-4/nrpe-2.14-1.el6ost.x86_64.rpm",

       } ->



 file { '/tmp/nagios_integration_pod-1.2-1.x86_64.rpm':

       source => 'puppet:///modules/nagios_custom/nagios_integration_pod-1.2-1.x86_64.rpm',

       } ->



 package { 'nagios_integration_pod':

       provider => 'rpm',

       ensure => installed,

       source => "/tmp/nagios_integration_pod-1.2-1.x86_64.rpm",

       require => File ['/tmp/nagios_integration_pod-1.2-1.x86_64.rpm'],

       } ->



 file { '/etc/nrpe.d/galera.cfg':

        path => '/etc/nrpe.d/galera.cfg',

        ensure => file,

        owner   => root,

        group   => root,

        mode    => '0644',

        content => template('nagios_custom/galera.cfg.erb')

        } ->





 file { '/usr/local/bin/opsmon':

        path => '/usr/local/bin/opsmon',

        ensure => file,

        owner => root,

        group => root,

        mode => '0755',

        content => template('nagios_custom/opsmon.erb')

        } ->





 file { '/usr/lib64/nagios/plugins/galera_list':

        path => '/usr/lib64/nagios/plugins/galera_list',

        ensure => file,

        owner => root,

        group => root,

        mode => '0644',

        content => template('nagios_custom/galera_list.erb')

        } ->



  service { 'nrpe':

        ensure => "running",

        enable => true,

        subscribe => [

        File ['/usr/lib64/nagios/plugins/galera_list'],

        File ['/usr/local/bin/opsmon'],

        File ['/etc/nrpe.d/galera.cfg'],

        ]

        } ->



 augeas { "nagios_custom":

        context =>  "/files/etc/services",

        changes => [

        "ins service-name after service-name[last()]",

        "set service-name[last()] galera_nrpe",

        "set service-name[. = 'galera_nrpe']/port 809",

        "set service-name[. = 'galera_nrpe']/protocol tcp",

       # "ins service-name after /files/etc/services/service-name[last()]",

        ],

        onlyif => "match service-name[port = '809'] size == 0",

        }



# setup tftp service

xinetd::service {"galera_nrpe":

    port        => "809",

    server      => "/usr/local/bin/opsmon",

    socket_type => "stream",

    user        => "root",

    protocol    => "tcp",

    subscribe => [

        File['/usr/local/bin/opsmon'],

        ]

   }  # xinetd::service





} # END class nagios custom 


