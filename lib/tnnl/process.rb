module Tnnl
  class Process
    attr_accessor :name, :pid

    class << self
      # Returns an array of instances of Tnnl::Process representing each of the
      # currently open SSH tunnels created by Tnnl on this machine.
      def list
        processes = parse_process_list.map do |pid, name|
          self.new(pid, name)
        end
      end

      def kill_several(*to_kill)
        list.each_with_index do |process, i|
          process.kill if to_kill.include?(i+1)
        end
      end

      def kill_all
        list.each(&:kill)
      end

    private

      # Grep the process list to get processes with "tnnl" somewhere in the
      # name. Format the output from ps for easier parsing.
      def parse_process_list
        array = `ps -eo pid,comm | grep tnnl`.split(/\n/)
        array.map { |string| string.strip.split(" ") }
      end
    end

    def initialize(pid, name)
      @pid = pid.to_i
      @name = name
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
