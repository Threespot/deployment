stage { "initialize": before => Stage["main"] }
stage { "apt_setup": before => Stage["initialize"] }


class base {
    # Packages every Debian system should have.
    package {
        "sudo": ensure => latest;
        "nmap": ensure => latest;
        "ethtool": ensure => latest;
        "ntp": ensure => latest;
        "git": ensure => latest;
        "mercurial": ensure => latest;
        "erlang": ensure => latest;
        "rabbitmq-server": ensure => latest;
    }
    service {"ntp":
        name => $service_name,
        ensure => running,
        enable => true,
        require => Package["ntp"],
    }
}


class python {
    # Install python packages: python, build tools, setuptools and PIL.
    package {
        "build-essential": ensure => latest;
        "python": ensure => "2.6.6-3+squeeze6";
        "python-dev": ensure => "2.6.6-3+squeeze6";
        "python-setuptools": ensure => "0.6.14-4";
        "python-imaging": ensure => "1.1.7-2"
    }
    exec { "sudo easy_install pip":
        path => "/usr/local/bin:/usr/bin:/bin",
        refreshonly => true,
        require => Package["python-setuptools"],
        subscribe => Package["python-setuptools"],
    }
}




# Installs the peacecorps django app dependencies
exec {"pip requirements":
    command => "pip install -r peacecorps/env/requirements.txt",
    cwd => "/home/vagrant/",
    creates => "/usr/local/lib/python2.6/site-packages/django/__init__.py",
    path => "/usr/local/bin:/usr/bin:/bin",
   require => Exec["sudo easy_install pip"],
}
# Installs the peacecorps django app dev dependencies
exec {"pip dev reqirements":
    command => "pip install -r peacecorps/env/dev_requirements.txt",
    cwd => "/home/vagrant/",
    creates => "/usr/local/lib/python2.6/site-packages/debug_toolbar/__init__.py",
    path => "/usr/local/bin:/usr/bin:/bin",
    require => Exec["pip requirements"],
}

# Class declarations:
class { "apt_updates": stage => "apt_setup" }
class { "base": stage => "initialize"}
class { "python": stage => "initialize" }
class { "postgresql": stage => "initialize" }
class { "postgresql_role":
    ensure => present,
    name => "peacecorpsuser",
    password => "peacecorps",
    require => Service["postgresql"],
    stage => "initialize",
}
class { "postgresql_database":
    ensure => present,
    name => "peacecorps",
    owner => "peacecorpsuser",
    require => Service["postgresql"],
    stage => "main",
}