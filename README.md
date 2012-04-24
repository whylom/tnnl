# Tnnl

Tnnl is a command-line utility for wrangling SSH tunnels.

Unlike most SSH tunnel utilities I've come across, Tnnl will not clutter your 
filesystem with a preferences YAML file. Instead it will try to make use of your 
native SSH config (at `~/.ssh/config` for most folks).

__This project is still in an early/alpha state. You have been warned. :)__

## Usage

### Open an SSH tunnel

Open an SSH tunnel between local port 1234 and port 5678 on the remote host 
`mysql.spatula.grommet`. If local port 1234 is unavailable, Tnnl will increment 
by 1 until it finds an open port.

    $ tnnl 1234:admin@mysql.spatula.grommet:3306

You can omit the local port number, and Tnnl will try to use the same port for 
the local and remote hosts.
    
    $ tnnl admin@mysql.spatula.grommet:3306
    
If you have defined a host alias in your SSH config, you can save yourself some 
keystrokes by referencing that alias.

    $ tnnl db:3306

### Find and close open tunnels
    
Use `tnnl list` to list all open SSH tunnels that were created by Tnnl.

    $ tnnl list
    1. localhost:3307  ==>  mysql.spatula.grommet:3306
    2. localhost:3000  ==>  123.45.67.89:3000
    3. localhost:666   ==>  chunkybacon.gov:666

You can use the index numbers referenced in `tnnl list` to close 1 or more 
tunnels.

    $ tnnl close 2
    $ tnnl close 1 3

Or close all tunnels created by Tnnl.

    $ tnnl close all

## Known Issues

- The list feature relies on renaming processes via $0, which does not work 
properly on Ruby 1.9.3-p0 on OS X. This appears to be an issue with this 
particular build of Ruby on this platform 
(https://groups.google.com/forum/#!topic/urug/zfmEGqjX47M). 1.9.3-p0 users on OS 
X are encouraged to upgrade to a newer build.
- Tnnl uses Net::SSH under the hood, and Net::SSH currently supports only a 
subset of OpenSSH configuration options. The `StrictHostKeyChecking` preference 
is not supported, so Tnnl errs on the safe side and prompts you to update 
~/.ssh/known_hosts when a modified host key is detected. Feel free to open an 
issue and/or submit a pull request if this is ruining your day.
