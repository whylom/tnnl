require 'net/ssh'

module Tnnl
  module SSH
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
        Net::SSH.start(host, user) do |ssh|
          ssh.forward.local(local_port, '127.0.0.1', remote_port)
          run = true
          trap('INT') { run = false }
          ssh.loop(0.1) { run }
        end
      rescue Timeout::Error
        puts 'ERROR: connection timed out'
      rescue Net::SSH::AuthenticationFailed
        puts 'ERROR: authentication failed'
      rescue Net::SSH::HostKeyMismatch => e
        # TODO: warn user about man-in-the-middle attacks
        # and prompt them to accept new key
        puts 'ERROR: host key mismatch'
      end

    end
  end
end
