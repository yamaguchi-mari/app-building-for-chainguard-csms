# 🐧 Chainguard Account Manager Lab: Intro to Linux & Bash

Welcome to your first hands-on lab in Linux and Bash! This guide is tailored for Chainguard account managers who are getting started with the command line. No prior knowledge required. You'll see these concepts repeated in other higher level technology like containers, CI scripts, package managers, etc.

By the end of this lab, you will:

1. Understand foundational Bash commands and Linux file systems.
2. Create a basic local development environment.
3. Install and use a Chainguard CLI tool.

---

## Module 1: Filesystem Navigation

### Concept Overview
Linux systems organize data in hierarchical directories. Mastering navigation is essential.

### Key Terms
- **Directory**: Folder on a system (`/etc`, `/home`)
- **Path**: Location of a file or directory
- **Home (`~`)**: Your personal directory

---

[The Linux File Hierarchy Structure (LFHS):](https://www.linuxtrainingacademy.com/linux-directory-structure-and-file-system-hierarchy/)


![image](linuxdir2.png?)

| Directory | Purpose                                         |
| --------- | ----------------------------------------------- |
| `/`       | Root 
| `/bin`    | Essential command binaries                      |
| `/sbin`   | System administration binaries                  |
| `/etc`    | Configuration files                             |
| `/home or /Users`   | User home directories                           |
| `/var`    | Variable data like logs                         |
| `/usr`    | Secondary hierarchy for user-installed software |

---

Open your terminal:

![image](zshell.png?)


### Commands: Navigate and Explore
```bash
cd ~               # Change directory - Ensure you are in your home directory
pwd                # Print working directory
cd ../..           # Move up two levels
pwd                # Verify location
ls                 # List contents
cd ~               # Go back to home
cd ../../etc       # Navigate to /etc using relative path
ls
cat passwd         # View file contents
cd ~               # Return home
cd /etc            # Absolute path navigation
ls -l              # Detailed listing
cd /Users/<your_user_name>  # Return home
pwd                # Verify where you are once more
```
**Tip:** Use `<Tab>` for path autocompletion.

Q: How could you read the passwd file in the /etc directory without having to navigate to the /etc directory?

```bash
mkdir chainguard-app-building # Make a new directory
ls -l chainguard-app-building # Verify your new folder is created
```

> End of module when you've verified the new directory is created

---

## Module 2: File Operations, Permissions & Variables

### Concept Overview
Everything in Linux is a file. Being able to create, view, modify, and run files is a core part of working in a Linux environment. This module combines file operations with file permissions and environment variables to keep things practical and task-based.

It's the same/similar file directory everywhere:

![image](filesystems-allthewaydown2.png?)

> Note: A CI pipeline is a Linux server, running a CI program/service. A firewall is a Linux server, running a firewall program/service. A Mac laptop is a Linux"ish" server, running many programs/services. A production k8s cluster manages containers, most of which are mini-Linux servers, ideally running only one program each (micro-services).

### Commands: Creating and Managing Files
```bash
# Change your user location to your directory
cd ~/chainguard-app-building 

# Try the 'echo' command
echo Hello world

# Create a simple script file with a bash command inside
echo '#!/bin/bash' > greet.sh

# Verify the existence of the new file you just created
ls

# Verify its contents
cat greet.sh

# now add more
echo 'echo "Hello world"' >> greet.sh

# Verify the new addition
# NOTE: Try the Up Arrow at the terminal prompt to bring up the previos 'cat' command
cat greet.sh

# View and modify permissions
ls -l greet.sh
chmod +x greet.sh
# View permissions again, do you see 'Xs' next to the greet.sh file?
ls -l

# Run the script
./greet.sh

# Environment variables
echo $USER
export MACGUFFIN=Linky
echo $MACGUFFIN

# Review all current environment variables in your OS:
env
# Is your new custom variable listed there?

# Put a variable in your greet.sh script
echo 'echo " And also hello $MACGUFFIN", aka $USER' >> greet.sh


# List contents of ~, this time lets include hidden files
ls -a
# There should be a file called .zshrc (hidden files start with ".")


# Make a backup copy of your .zshrc file
cp ~/.zshrc ~/.zshrc.bak

# View contents of .zshrc
cat ~/.zshrc

# Make a variable persistent
echo 'export MACGUFFIN=<change me>' >> ~/.zshrc # .zshrc file is hidden in your $HOME directory and runs commands for you

# Activate the change you made to the .zshrc file
source ~/.zshrc

# Ensure the change worked
echo $MACGUFFIN

# Run the greet.sh script again
./greet.sh
# Did the message change?
```

> Note: Your terminal should have printed a message like this:

> "Hello world"
> "And hello $MACGUFFIN, aka $USER"

> If so you are done with this module

<details>
<summary><strong>Extra Credit - turn your script into a binary</strong></summary>

```bash
# Install a program that turns .sh text files into binaries
brew install shc

# Turn greet.sh into a binary
shc -f greet.sh

# Compare details of the text file vs the binary
# Review the binary contents
cat greet.sh.x 

# Compare to the shell file contents
cat greet.sh

# Compare file metadata (including file size)
ls -lh greet*

# Move your binary to a file in $PATH
sudo mv greet.sh.x /usr/local/bin/greet

# Test it
greet

```
</details>

---

## Module 3: Install a binary (Chainctl)

### Concept Overview

You probably already installed chainctl on your work laptop using `brew`

```bash
brew install chainctl
```

Clients running production systems may not always be able to rely on package managers for individual OSs like `brew`.

Let's install a CLI tool without a package manager, using a more universal method: `wget`.

But we don't want to do it in our local environment (we already have chainctl installed there, right?).

Go to [Google Cloud Shell](https://console.cloud.google.com/) (authentication w/ Ubikey required)

Click the cloud shell link to activate (upper right corner of UI):

![image](google-cloud-shell.png?)

> Note: Google Cloud Shell is running in yet another Linux File Directory, very similar to the one on your laptop. When the shell environment finishes booting up, run the below commands to install `chainctl`

### Commands: Manual Install in Cloud Shell
```bash
# Confirm you are in the home directory of your new local development environment:
pwd

# List out any files or subdirectories in the current directory
ls


# Download the binary
wget https://dl.enforce.dev/chainctl/latest/chainctl_linux_x86_64
# wget is the command line equivalent to clicking the download button on a website

# Review permissions of the binary you just downloaded
ls -l

#You should see someting like this:
# total 92720
# -rw-rw-r-- 1 anthony_sayre anthony_sayre 94933176 Jul  4 20:08 chainctl_linux_x86_64
# -rwxr-xr-x 1 anthony_sayre anthony_sayre      913 Jul  5 16:17 README-cloudshell.txt
# drwxrwxr-x 2 anthony_sayre anthony_sayre     4096 Jun 24 13:40 test

# Try to run the binary:
./chainctl_linux_x86_64 --help
# Did it run? Why or why not?

# The binary we just downloaded does not have any Xs in its permissions
chmod +x chainctl_linux_x86_64

# Review the binary's permissions after running 'chmod' command:
ls -l
# Are there Xs in the pemrissions section of the result? If so then move to the next step

# Verify it runs now
./chainctl_linux_x86_64 --help

# The path env
echo $PATH

# Elevate your user privileges and then move the binary to a directory in the path
sudo mv chainctl_linux_x86_64 /usr/local/bin/chainctl

# Confirm it's not in our home folder anymore:
ls -l

#Confirm the util works:
chainctl --help  # Should show help 

```

> End of module

---

## Shortcuts & Command History

### Terminal Tips & Tricks

```bash
cd ~/chai<Tab>     # Tab to autocomplete
Ctrl + R           # Search history
!!                 # Re-run last command
!$                 # Use last argument of previous command
sudo               # Raise privileges of User before executing command 
```

---

## Appendix: Key Linux Terms

- **Terminal**: Interface for typing commands
- **Shell**: Command interpreter (e.g., Bash, Zsh)
- **Prompt**: Where you type
- **Root**: Admin user and/or top-level directory
- **Service (daemon)**: Background process
- **Package manager (OS)**: `apt`, `apk`
- **Package manager (app)**: `npm`, `pip`

<details>
<summary><strong>(Open Me) Suggested Questions for Further Study</strong></summary>

Context: I am a technical client facing Chainguard rep who is new to Linux, answer the below questions with this in mind
- What's the difference between OS-level and app-level package managers?
- How does Chainguard address application dependencies vs OS dependencies?
- What does the `$PATH` variable do?
- What is a binary file and how is it different from a normal text file?

</details>

---

| Next Lab: [GitHub](/labs/01_github) |
|:-----------------------------------:|