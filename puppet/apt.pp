define apt_key($ensure, $apt_key_url = "http://www.example.com/apt/keys") {
    # Installs an apt key from the specified URL.
    case $ensure {
        "present": {
            exec { "apt-key present $name":
                command => "/usr/bin/wget -q $apt_key_url/$name -O -|/usr/bin/apt-key add -",
                unless => "/usr/bin/apt-key list|/bin/grep -c $name",
            }
        }
        "absent": {
            exec { "apt-key absent $name":
                command => "/usr/bin/apt-key del $name",
                onlyif => "/usr/bin/apt-key list|/bin/grep -c $name",
            }
        }
        default: {
            fail "Invalid 'ensure' value '$ensure' for apt::key"
        }
    }
}


class apt {
    exec { "apt-update":
        command     => "/usr/bin/apt-get update",
        require => File["sources.list"]
    }
    file { "sources.list":
        content => "
        # 
        # deb cdrom:[Debian GNU/Linux 6.0.1a _Squeeze_ - Official i386 NETINST Binary-1 20110320-15:03]/ squeeze main
        #deb cdrom:[Debian GNU/Linux 6.0.1a _Squeeze_ - Official i386 NETINST Binary-1 20110320-15:03]/ squeeze main

        deb http://ftp.us.debian.org/debian/ squeeze main
        deb-src http://ftp.us.debian.org/debian/ squeeze main

        deb http://security.debian.org/ squeeze/updates main
        deb-src http://security.debian.org/ squeeze/updates main

        # squeeze-updates, previously known as 'volatile'
        deb http://ftp.us.debian.org/debian/ squeeze-updates main
        deb-src http://ftp.us.debian.org/debian/ squeeze-updates main
        # RabbitMQ APT Repository
        deb http://www.rabbitmq.com/debian/ testing main
        ",
        ensure => present, 
        path => "/etc/apt",
    }
    apt_key { "rabbitmq-signing-key-public.asc":
        ensure => "present",
        apt_key_url => "http://www.rabbitmq.com/", 
        require => File["sources.list"],
    }
}
