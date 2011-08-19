class server {
    # Install postgresql client and server and (python bindings) and make sure it's running.
    package {
        ["postgresql", "python-psycopg2"]: ensure => installed,
    }
    service { "postgresql":
        ensure => running,
        enable => true,
        hasstatus => true,
        subscribe => Package[postgresql]
    }
}

class database($ensure, $owner = false) {
    # Ensure the specified database exists.
    $ownerstring = $owner ? {
        false => "",
        default => "-O $owner"
    }
    
    case $ensure {
        present: {
            exec { "Create $name postgres db":
                command => "/usr/bin/createdb $ownerstring $name --encoding=\"utf-8\" --template=\"template0\"",
                user => "postgres",
                unless => "/usr/bin/psql -l | grep '$name  *|'"
            }
        }
        absent:  {
            exec { "Remove $name postgres db":
                command => "/usr/bin/drop $name",
                onlyif => "/usr/bin/psql -l | grep '$name  *|'",
                user => "postgres"
            }
        }
        default: {
            fail "Invalid 'ensure' value '$ensure' for postgres::database"
        }
    }
}


class role($ensure, $password = false) {
    # Ensure the specified postgres role exists.
    $passtext = $password ? {
        false => "",
        default => "PASSWORD '$password'"
    }
    case $ensure {
        present: {
            # The createuser command always prompts for the password.
            exec { "Create $name postgres role":
                command => "/usr/bin/psql -c \"CREATE ROLE $name $passtext LOGIN\"",
                user => "postgres",
                unless => "/usr/bin/psql -c '\\du' | grep '^  *$name  *|'"
            }
        }
        absent:  {
            exec { "Remove $name postgres role":
                command => "/usr/bin/dropeuser $name",
                user => "postgres",
                onlyif => "/usr/bin/psql -c '\\du' | grep '$name  *|'"
            }
        }
        default: {
            fail "Invalid 'ensure' value '$ensure' for postgres::role"
        }
    }
}