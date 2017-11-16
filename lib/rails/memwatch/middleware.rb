# Originaly created by Valentin Plehanov on 22.11.16.
# Ported in gem by Shvetsov Dmitry <shvetsovdm> on 16.11.17

require 'pathname'
require 'bigdecimal'

module Rails
  module Memwatch
    # = Rails memory watch midleare
    class Middleware
      def initialize(app, size, watcher)
        @app = app
        @limit_size = size
        @watcher = watcher
      end

      def call(env)
        puts 'HERE!'
        status, headers, body = @app.call(env)
        puts 'Not HERE?'

        current_size = GetProcessMem.new.mb

        if current_size > @limit_size && env.include?('action_dispatch.request.path_parameters') && env['action_dispatch.request.path_parameters'].any?
          controller = env['action_dispatch.request.path_parameters'][:controller]
          action = env['action_dispatch.request.path_parameters'][:action]
          message = "#{controller}/#{action}: The application uses memory more than #{@limit_size} MB"
          @watcher.capture_message(message, extra: { memory_use_mb: current_size })
        end

        [status, headers, body]
      end

      # = Calculate memory used by a process
      class GetProcessMem
        KB_TO_BYTE = 1024          # 2**10   = 1024
        MB_TO_BYTE = 1_048_576     # 1024**2 = 1_048_576
        GB_TO_BYTE = 1_073_741_824 # 1024**3 = 1_073_741_824
        CONVERSION = {
          'kb' => KB_TO_BYTE,
          'mb' => MB_TO_BYTE,
          'gb' => GB_TO_BYTE
        }.freeze
        ROUND_UP = BigDecimal.new('0.5')
        attr_reader :pid

        def initialize(pid = Process.pid)
          @status_file  = Pathname.new "/proc/#{pid}/status"
          @process_file = Pathname.new "/proc/#{pid}/smaps"
          @pid          = pid
        end

        def bytes
          linux_status_memory || ps_memory
        end

        def kb(b = bytes)
          (b / BigDecimal.new(KB_TO_BYTE)).to_f
        end

        def mb(b = bytes)
          (b / BigDecimal.new(MB_TO_BYTE)).to_f
        end

        def gb(b = bytes)
          (b / BigDecimal.new(GB_TO_BYTE)).to_f
        end

        def inspect
          b = bytes
          str = "#<#{self.class}:0x%08x @mb=#{mb(b)} @gb=#{gb(b)} @kb=#{kb(b)} @bytes=#{b}>"
          str % (object_id * 2)
        end

        # linux stores memory info in a file "/proc/#{pid}/status"
        # If it's available it uses less resources than shelling out to ps
        def linux_status_memory(file = @status_file)
          line = file.each_line.detect do |file_line|
            file_line.start_with? 'VmRSS'.freeze
          end
          return unless line
          return unless (_name, value, unit = line.split(nil)).length == 3
          CONVERSION[unit.downcase!] * value.to_i
        rescue Errno::EACCES, Errno::ENOENT
          0
        end

        private

        # Pull memory from `ps` command, takes more resources and can freeze
        # in low memory situations
        def ps_memory
          KB_TO_BYTE * BigDecimal.new(`ps -o rss= -p #{pid}`)
        end
      end
    end # Middleware
  end
end
