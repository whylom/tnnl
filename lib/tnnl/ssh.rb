require 'net/ssh'

module Tnnl
  module SSH

    class HostNotFound         < SocketError                    ; end
    class TimeoutError         < Timeout::Error                 ; end
    class AuthenticationFailed < Net::SSH::AuthenticationFailed ; end

    # Wraps & forwards method calls to an instance of Net::SSH::HostKeyMismatch
    class HostKeyMismatch < Net::SSH::Exception
      def initialize(error)
        @error = error
      end

      def method_missing(method, *args)
        @error.send(method, *args)
      end
    end



    TIMEOUT = 15

    class << self

      def find_open_port(port)
        while true
          begin
            # Attempt to bind to the requested port.
            socket = Socket.new(Socket::Constants::AF_INET, Socket::Constants::SOCK_STREAM, 0)
            sockaddr = Socket.pack_sockaddr_in(port, '127.0.0.1')
            socket.bind(sockaddr)
            
            # If an exception wasn't raised, the current port is available.
            # Close the socket now (so we can use the port for realsies) 
            # and exit the loop by returning the port.
            socket.close
            return port
          rescue Errno::EADDRINUSE
            # If the current port is in use, increment by 1 and try again.
            port += 1
          end
        end
      end

      def open(host, user, local_port, remote_port)
        # Impose an artificial timeout on establishing a connection to the 
        # remote host.
        Timeout.timeout(TIMEOUT) do
          Net::SSH.start(host, user) do |ssh|
            # Open an SSH tunnel.
            ssh.forward.local(local_port, '127.0.0.1', remote_port)

            # All of the exceptions we're ready to handle will have already 
            # been caught prior to this.  Now we can safely fork a new process
            # to keep the tunnel open.
            fork do
              # Rename the forked process so it can be easily located later.
              $0 = "tnnl[#{local_port}:#{user}@#{host}:#{remote_port}]"

              run = true
              trap('INT') { run = false }
              ssh.loop(0.1) { run }
            end
          end
        end
      rescue SocketError
        raise Tnnl::SSH::HostNotFound
      rescue Timeout::Error
        raise Tnnl::SSH::TimeoutError
      rescue Net::SSH::AuthenticationFailed
        raise Tnnl::SSH::AuthenticationFailed
      rescue Net::SSH::HostKeyMismatch => e
        raise Tnnl::SSH::HostKeyMismatch.new(e)
      end
    
    end

  end
end
