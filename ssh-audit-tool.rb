require 'net/ssh'
require 'logger'

class SSHSecurityCheck
  def initialize(host: '192.168.1.244', port: 22, username: 'pi', password_file: 'passwords.txt')
    @host = host
    @port = port
    @username = username
    @password_file = password_file
    @logger = Logger.new('ssh_check.log')
  end

  def check
    return log_error("Password file not found: #{@password_file}") unless File.exist?(@password_file)
    
    passwords = File.readlines(@password_file).map(&:strip).reject(&:empty?)
    
    passwords.each do |password|
      begin
        Net::SSH.start(@host, @username, 
          password: password, 
          port: @port, 
          timeout: 5,
          non_interactive: true
        ) do |_ssh|
          log_success(password)
          return password
        end
      rescue Net::SSH::AuthenticationFailed
        @logger.info("Failed attempt: #{password}")
      rescue StandardError => e
        @logger.error("Error: #{e.message}")
      ensure
        sleep(0.1) # Rate limiting
      end
    end
    
    log_error("No valid credentials found")
    nil
  end

  private

  def log_success(password)
    message = "Success! Password found: #{password}"
    @logger.info(message)
    puts message
  end

  def log_error(message)
    @logger.error(message)
    puts message
    nil
  end
end

# Usage
checker = SSHSecurityCheck.new
checker.check
