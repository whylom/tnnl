module Tnnl
  module CLI
    class << self

      def run!(args)
        command = args.shift || 'help'

        if command == 'help'
          help
        elsif command == 'list'
          list
        elsif command.include? ':'
          open(command)
        else
          error
        end
      end

      def help
        puts 'Help text goes here'
      end

      def error
        puts 'Error messages go here.'
      end

      def list
        Tnnl::Process.list.each_with_index do |process,i|
          puts "  #{i+1}. #{process}"
        end
      end

      def open(connection)
        host, user, local_port, remote_port = parse_connection(connection)
        local_port = Tnnl::SSH.find_open_port(local_port)

        puts "Opening SSH tunnel... "
        Tnnl::SSH.open(host, user, local_port, remote_port)
        puts "local:#{local_port} ===> #{user}@#{host}:#{remote_port}"

      rescue Tnnl::SSH::HostNotFound
        puts 'ERROR: could not resolve host'
      rescue Tnnl::SSH::TimeoutError
        puts 'ERROR: connection timed out'
      rescue Tnnl::SSH::AuthenticationFailed
        puts 'ERROR: authentication failed'
      rescue Tnnl::SSH::HostKeyMismatch
        # TODO: warn user about man-in-the-middle attacks
        # and prompt them to accept new key
        puts 'ERROR: host key mismatch'
      end

      def parse_connection(connection)
        parts = connection.split(':')

        if parts.size == 3
          # 1234:host:5678
          local_port, host, remote_port = parts
        elsif parts.size == 2
          # host:5678
          host, remote_port = parts
          local_port = remote_port
        end
        
        if host.include? '@'
          # user@host:5678 -> parse manually
          user, host = host.split('@')
        else
          # host:5678 -> look up user & actual hostname in local SSH config
          config = Net::SSH.configuration_for(host)
          
          # TODO: Make this a custom exception handled by Tnnl::CLI.run!
          abort "Could not find host '#{host}' in your SSH config." if config.empty?

          user = config[:user]
          host = config[:host_name]
        end

        parts = [host, user, local_port.to_i, remote_port.to_i]
        raise ArgumentError if parts.any? { |a| a.nil? }

        parts
      end

    end
  end
end
