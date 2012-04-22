module Tnnl
  module CLI
    class << self

      # This is the entry-point for all command-line operations. It parses 
      # arguments and delegates to the appropriate methods in Tnnl::CLI and 
      # Tnnl::SSH.
      def run!(args)
        command = args.shift || 'help'

        if command == 'help'
          help
        elsif command == 'list'
          list
        elsif command == 'close' || command == 'kill'
          close(args)
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

      def close(args)
        if args.first == 'all'
          Tnnl::Process.kill_all
        elsif args.any?
          Tnnl::Process.kill_several(*args.map(&:to_i))
        else
          puts 'ERROR: expected "tnnl close all" or "tnnl close [index] [index]..."'
        end
      end

      # Open an SSH tunnel. After parsing the user's command-input input, find
      # the closest available local port. Rescue from common SSH errors, and 
      # provide appropriate feedback to the user.
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
      rescue Tnnl::SSH::HostKeyMismatch => e
        handle_host_key_mismatch(e)
      end

      # Parses input from command-line and returns an array of SSH connection
      # parameters suitable for passing to Tnnl::SSH.open. Raises ArgumentError
      # if any of the required parameters are missing.
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

      # Prompt user to save the new host key in their known hosts file.
      def handle_host_key_mismatch(error)
        valid_responses = %w(y n)
        response = nil
        
        while !valid_responses.include?(response)
          puts "\nWARNING! The remote host key has changed."
          puts "Someone could be eavesdropping on your SSH connection."
          puts "It is also possible that the RSA host key has just been changed."

          puts "\nThe fingerprint for the RSA key sent by the remote host is:"
          puts error.fingerprint

          print "\nAccept this new key in the known hosts file? (y/n): "
          response = gets.strip.downcase
        end

        # Record this host and key in the known hosts file if the user wishes.
        error.remember_host! if response == 'y'
      end

    end
  end
end
