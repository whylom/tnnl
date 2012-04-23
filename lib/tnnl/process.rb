module Tnnl
  class Process
    attr_accessor :name, :pid, :time_elapsed

    class << self  
      # Returns an array of instances of Tnnl::Process representing each of the 
      # currently open SSH tunnels created by Tnnl on this machine.
      def list
        # Grep the process list to get processes with "tnnl" somewhere in the 
        # name. Format the output from ps for easier parsing.
        list = `ps -eo pid,etime,comm | grep tnnl`.split(/\n/)

        # Transform each string into an instance of Tnnl::Process.
        processes = list.map do |line|
          pid, time_elapsed, name = line.strip.split(' ')
          self.new(pid, name, time_elapsed)
        end

        # Remove any processes we might have found that don't conform to our 
        # naming convention.
        processes.select { |p| p.name =~ /^tnnl\[.*\]$/ }
      end

      def kill_several(*to_kill)
        list.each_with_index do |process, i|
          process.kill if to_kill.include?(i+1)
        end
      end

      def kill_all
        list.each(&:kill)
      end
    end


    def initialize(pid, name, time_elapsed)
      @pid = pid.to_i
      @name = name
      @time_elapsed = time_elapsed
    end

    def kill
      ::Process.kill('INT', pid)
    end

    def to_s
      metadata = name.scan(/\[(.*)\]/).last.first
      local_port, host, remote_port = metadata.split(':')
      "localhost:#{local_port}  ==>  #{host}:#{remote_port}"
    end
  end
end
