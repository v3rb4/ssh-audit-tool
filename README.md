# 🔐 SSH Audit Tool

A lightweight tool designed for **educational purposes** and **authorized penetration testing**. This script performs a **brute-force attack** on SSH authentication to evaluate the security of your system's credentials.

## ⚠️ Legal Disclaimer
This tool should only be used:
- ✅ On **systems you own** or have **explicit permission** to test.
- 🎓 For **educational and research** purposes.

🚨 **Unauthorized use of this tool is strictly prohibited** and may violate local, state, or federal laws. The author of this script is **not responsible for any misuse**.

---

## 🛠 Features
- 🚀 **Brute-force SSH credentials** using a wordlist.
- 📝 **Logs all progress** and results to a dedicated log file.
- 🔄 **Checks SSH server availability** before starting.
- ⏳ **Implements delays** between attempts to avoid overloading the target system.

---

## 📋 Prerequisites
- **Ruby 2.7+** installed on your system.
- Required gems: `net-ssh`, `parallel`.
- Install dependencies with:
  ```bash
  gem install net-ssh parallel
  ```

---

## 🚀 How to Use
### 1️⃣ Clone the repository
```bash
git clone https://github.com/v3rb4/ssh-audit-tool.git
cd ssh-audit-tool
```

### 2️⃣ Prepare a wordlist
Create a file named `passwords.txt` in the same directory:
```bash
echo "password123" > passwords.txt
echo "letmein" >> passwords.txt
echo "raspberry" >> passwords.txt
```

### 3️⃣ Run the script
```bash
ruby ssh-audit-tool.rb
```

### 4️⃣ View logs
Logs are saved in the `.log` directory as `brute_force.log`.
```bash
cat .log/brute_force.log
```

---

## ⚙️ Configuration
Modify the following variables in the script as needed:
| Variable | Description | Default Value |
|----------|-------------|--------------|
| `host` | Target system IP | `192.168.1.244` |
| `port` | SSH port | `22` |
| `username` | SSH username to brute force | `pi` |
| `password_list` | Path to the wordlist | `passwords.txt` |
| `log_dir` | Log storage directory | `.log` |
| `delay_between_attempts` | Delay between attempts (seconds) | `0.1` |

---

## 📌 Example Output
```plaintext
=== SSH Brute Force ===
[!] Password list file not found: passwords.txt
[!] Please provide a valid password list file.
[+] Success! Password found: raspberry
[-] Brute force completed unsuccessfully.
```

---

## 🔄 Future Improvements
- ✅ **Multi-threading support** for faster brute-forcing
- ✅ **Custom wordlist support via CLI arguments**
- ✅ **Automatic detection of SSH banners** for fingerprinting
- ✅ **Verbose logging and reporting improvements**

---

## 🤝 Contribution
Contributions are welcome! Feel free to submit **issues** or **pull requests** to improve the script.

---

## 📜 License
This project is dedicated to the public domain under the **Creative Commons Zero (CC0) license**. See the LICENSE file for details.

---

🚀 **Happy hacking! Use responsibly.**
