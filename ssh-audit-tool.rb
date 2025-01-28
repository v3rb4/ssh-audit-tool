# ssh_audit_tool.rb
require 'net/ssh'
require 'parallel'
require 'socket'
require 'timeout'
require 'logger'

module SSHAudit
  class Configuration
    attr_reader :host, :port, :username, :password_file, :log_dir, :threads, :delay

    def initialize
      # Default config
      @host = '192.168.1.244'
      @port = 22
      @username = 'pi'
      @password_file = 'passwords.txt'
      @log_dir = '.log'
      @threads = 5
      @delay = 0.1
      
      validate_configuration
    end

    private

    def validate_configuration
      raise "Password file not found: #{@password_file}" unless File.exist?(@password_file)
    end
  end

  class Logger
    def initialize(log_dir)
      Dir.mkdir(log_dir) unless Dir.exist?(log_dir)
      @logger = ::Logger.new(File.join(log_dir, "audit_#{Time.now.strftime('%Y%m%d_%H%M')}.log"))
      configure_formatter
    end

    def info(message)
      @logger.info(message)
      puts message
    end

    def error(message)
      @logger.error(message)
      puts "\e[31m#{message}\e[0m" # Red color is for errors
    end

    private

    def configure_formatter
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
      end
    end
  end

  class SecurityTester
    def initialize
      @config = Configuration.new
      @logger = Logger.new(@config.log_dir)
      @terminate = false
    end

    def run
      @logger.info("=== SSH Security Audit Tool ===")
      @logger.info("Target: #{@config.host}:#{@config.port}")
      
      return unless test_connection
      test_passwords
    end

    private

    def test_connection
      Timeout.timeout(5) do
        TCPSocket.new(@config.host, @config.port).close
        @logger.info("Successfully connected to #{@config.host}:#{@config.port}")
        true
      end
    rescue StandardError => e
      @logger.error("Connection failed: #{e.message}")
      false
    end

    def test_passwords
      passwords = load_passwords
      total = passwords.size
      
      @logger.info("Starting password tests with #{@config.threads} threads")
      
      Parallel.each_with_index(passwords, in_threads: @config.threads) do |password, index|
        break if @terminate
        
        log_progress(index + 1, total)
        try_password(password)
        sleep(@config.delay) unless @terminate
      end
      
      @logger.info("Password testing completed")
    end

    def load_passwords
      File.readlines(@config.password_file).map(&:strip).reject(&:empty?)
    end

    def try_password(password)
      @logger.info("Testing: #{@config.username}:#{password}")
      
      Net::SSH.start(@config.host, @config.username, 
                     password: password,
                     port: @config.port,
                     timeout: 5,
                     non_interactive: true) do |_ssh|
        @logger.info("Success! Password found: #{password}")
        @terminate = true
      end
    rescue Net::SSH::AuthenticationFailed
      @logger.info("Incorrect password: #{password}")
    rescue StandardError => e
      @logger.error("Error during attempt: #{e.message}")
    end

    def log_progress(current, total)
      progress = (current.to_f / total * 100).round(2)
      @logger.info("Progress: #{progress}% (#{current}/#{total})")
    end
  end
end

# Run program
if __FILE__ == $0
  begin
    SSHAudit::SecurityTester.new.run
  rescue StandardError => e
    puts "Error: #{e.message}"
    exit(1)
  end
end
