# 🐧 Chainguard Account Manager Lab: Intro to Linux & Bash

Welcome to your first hands-on lab in Linux and Bash! This guide is tailored for Chainguard account managers who are getting started with the command line. No prior knowledge required.

By the end of this lab, you will:

1. Understand foundational Bash commands and Linux file systems.
2. Create a basic local development environment.
3. Install and use a Chainguard CLI tool.

---

## 📁 Module 1: Filesystem Navigation

### 🔍 Concept Overview
Linux systems organize data in hierarchical directories. Mastering navigation is essential.

### 📖 Key Terms
- **Directory**: Folder on a system (`/etc`, `/home`)
- **Path**: Location of a file or directory
- **Home (`~`)**: Your personal directory

### 🧪 Commands: Navigate and Explore
```bash
pwd                # Show current directory
cd ../..           # Move up two levels
pwd                # Verify location
ls                 # List contents
cd ~               # Go to home
cd ../../etc       # Navigate to /etc using relative path
ls
cat passwd         # View file contents
cd ~               # Return home
cd /etc            # Absolute path navigation
ls -la             # Detailed listing
cd /Users/<your_user_name>  # Return home
pwd
```
💡 **Tip:** Use `<Tab>` for path autocompletion.

[The Linux File Hierarchy Structure (LFHS):](https://www.linuxtrainingacademy.com/linux-directory-structure-and-file-system-hierarchy/)

![image](linuxdir2.png?)

> End of module

---

## 📄 Module 2: File Operations

### 🔍 Concept Overview
Everything in Linux is a file. Viewing, creating, moving, deleting files is foundational. 

Managing permissions on files and spinning up running services from files are also important.

It's the same/similar file system everywhere:

![image](filesystems-allthewaydown2.png?)

> Note: A CI pipeline is a Linux server, running a CI program/service. A firewall is a Linux server, running a firewall program/service. A Mac laptop is a Linux"ish" server, running many programs/services. A production k8s cluster manages containers, most of which are mini-Linux servers, ideally running only one program each (micro-services).

### 🧪 Commands: Creating and Managing Files
```bash
cd ~
mkdir chainguard-app-building
cd ~/chainguard-app-building
touch hello.txt
cat hello.txt
mv hello.txt greetings.txt
cp greetings.txt greetings_copy.txt
rm greetings_copy.txt  # Caution: irreversible
```

> End of module

---

## 🔑 Module 3: Permissions & Variables

### 📖 Key Concepts
- **Permissions**: Who can read/write/execute
- **Environment Variable**: Stores session config like usernames

### 🧪 Commands
```bash
cd ~/chainguard-app-building
echo "echo Hello Chainguard!" > greet.sh
ls -l greet.sh
chmod +x greet.sh
./greet.sh

# Environment variables
echo $USER
export MACGUFFIN=Linky
echo $MACGUFFIN

# Review all current environment variables in your OS:
env
# Is your new custom variable listed there?
```

### 🔄 Make Variables Persistent
```bash
echo 'export MACGUFFIN=<change me>' >> ~/.zshrc
source ~/.zshrc
echo $MACGUFFIN
```

> End of module

---

## 🔧 Module 4: Install Chainctl (Chainguard CLI)

### 🔍 Concept Overview

You probably already installed chainctl on your work laptop using `brew`

```bash
brew install chainctl
```

As an SRE, you probably can't rely on `brew`

Let's install a CLI tool without a package manager, using a more universal method `wget`.

### 🧪 Commands: Manual Install in Cloud Shell
```bash
wget https://dl.enforce.dev/chainctl/latest/chainctl_linux_x86_64
chmod +x chainctl_linux_x86_64
sudo mv chainctl_linux_x86_64 /usr/local/bin/
chainctl_linux_x86_64 --help  # Should show help menu
```

> End of module

---

## 🎓 Module 5: Shortcuts & Command History

### 🛠️ Terminal Tricks
```bash
cd ~/chai<Tab>     # Tab to autocomplete
Ctrl + R           # Search history
!!                 # Re-run last command
!$                 # Use last argument of previous command
sudo               # Raise privileges of User before executing command 
```

### 🧠 Self-Study (Optional)
```bash
mkdir -p ~/chainguard-app-building/mywebserver/deploy/
touch ~/chainguard-app-building/mywebserver/deploy/Chart.yaml
open -a TextEdit ~/chainguard-app-building/mywebserver/deploy/Chart.yaml
```

---

## 📚 Appendix: Key Linux Terms

- **Terminal**: Interface for typing commands
- **Shell**: Command interpreter (e.g., Bash, Zsh)
- **Prompt**: Where you type
- **Root**: Admin user or top-level directory
- **Service (daemon)**: Background process
- **Package manager (OS)**: `apt`, `apk`
- **Package manager (app)**: `npm`, `pip`

<details>
<summary><strong>(Open Me) Suggested Questions for Further Study</strong></summary>

- What's the difference between OS-level and app-level package managers?
- How does Chainguard address application vs OS dependencies?
- Why is `chroot` relevant for debugging distroless images?
- What does the `$PATH` variable do?

</details>

---

| Next Lab: [GitHub](/labs/01_github) |
| 