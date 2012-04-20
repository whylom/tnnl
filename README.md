# Tnnl

Tnnl is a command-line utility for wrangling SSH tunnels.

This will eventually be released as a gem. For now, it's just a pile of lovely,
lovely code.

Unlike pretty much every other SSH tunnel utility I've come across, Tnnl will 
not store your preferences in some random YAML file. Instead it will try to 
make good use of your native SSH config (at `~/.ssh/config` for most folks).

The command-line interface will look something like this:

    $ tnnl 1234:user@host:5678
    #=> Opens a tunnel from local port 1234 to port 5678 on host.
    #=> This will fork a new process and return your command prompt.
    
    $ tnnl user@host:3000
    #=> Tries to use 3000 for the local port, and increments until it finds an
    #=> open local port.
    
    $ tnnl foo:3000
    #=> Looks up username and hostname in your SSH config under "foo".
    
    $ tnnl foo
    #=> Reads the remote port from your SSH config (if possible).
    
    $ tnnl list
    1. local:3307 ===> foo:3306
    2. local:3000 ===> 107.22.164.247:3000
    3. local:666  ===> chunkybacon.org:666

    $ tnnl close 1 3
    #=> Closes tunnels #1 and #3 from the list.
    
    $ tnnl close all
    #=> Closes all tunnels.
