# SSH Audit Tool

A lightweight tool designed for **educational purposes** and **authorized penetration testing**. This script performs a brute force attack on SSH authentication to evaluate the security of your system's credentials.

---

## ⚠️ Legal Disclaimer
This tool should only be used:
- On systems you own or have explicit permission to test.
- For educational and research purposes.

**Unauthorized use of this tool is strictly prohibited** and may violate local, state, or federal laws. The author of this script is not responsible for any misuse.

---

## Features
- Brute force SSH credentials using a wordlist.
- Logs all progress and results to a dedicated log file.
- Checks if the SSH server is reachable before starting.
- Implements delays between attempts to avoid overloading the target system.

---

## Prerequisites
- Ruby 2.7 or higher installed on your system.
- Required gems: `net-ssh`, `parallel`.

Install the required gems using:
```bash
gem install net-ssh parallel
```

---

## How to Use
1. **Clone this repository:**
   ```bash
   git clone https://github.com/v3rb4/ssh-audit-tool.git
   cd ssh-audit-tool
   ```

2. **Prepare a wordlist:**
   - Create a file named `passwords.txt` in the same directory.
   - Populate it with passwords to test, one password per line.

3. **Run the script:**
   ```bash
   ruby ssh-audit-tool.rb
   ```

4. **View logs:**
   - Logs are saved in the `.log` directory as `brute_force.log`.

---

## Configuration
Modify the following variables in the script as needed:
- **`host`**: IP address of the target system (default: `192.168.1.244`).
- **`port`**: SSH port (default: `22`).
- **`username`**: SSH username to brute force (default: `pi`).
- **`password_list`**: Path to the password wordlist (default: `passwords.txt`).
- **`log_dir`**: Directory for storing logs (default: `.log`).
- **`delay_between_attempts`**: Delay between attempts in seconds.

---

## Example Output
```plaintext
=== SSH Brute Force ===
[!] Password list file not found: passwords.txt
[!] Please provide a valid password list file.
[+] Success! Password found: raspberry
[-] Brute force completed unsuccessfully.
```

---

## Contribution
Contributions are welcome! Feel free to submit issues or pull requests to improve the script.

---

## License
This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
