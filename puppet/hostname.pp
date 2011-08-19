class hostname($name) {
    # Set the hostname to the specified value.
    file { "hosts":
        content => "
        127.0.0.1	localhost
        127.0.1.1	$name
        # The following lines are desirable for IPv6 capable hosts
        ::1     ip6-localhost ip6-loopback
        fe00::0 ip6-localnet
        ff00::0 ip6-mcastprefix
        ff02::1 ip6-allnodes
        ff02::2 ip6-allrouters
        ",
        ensure => present,
        path => "/etc/hosts"
    }
    file { "hostname":
        content => "$name",
        ensure => present,
        path => "/etc/hostname",
        require => File["hosts"],
    }
    exec { "set hostname":
        command => "hostname $name",
        path => "/bin:/sbin:/usr/bin:/usr/sbin",
        unless => "cat /etc/hostname | grep $name",
        user => "root",
        require => File["hostname"],
    }
}
    



