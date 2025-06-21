# Bash

*By the end of this lab, you will:*
1. Be familiar with the Bash commands we'll use in this course, and a little about the linux file system structure
1. Have a "local" development environment set up


# 🐧 Intro to GNU/Linux – Commands & Key Terms

This reference is designed to help beginners get comfortable with the Linux command line. It includes essential commands and key terms to prepare you for hands-on exercises.

---

## Basic GNU/Linux Commands

### Essential Commands

- `cd` – Change the current directory
- `ls` – List the contents of a directory
- `pwd` – Show the full path of the current working directory
- `cp` – Copy a file or folder
- `mv` – Move or rename a file or folder
- `rm` – Remove a file or folder *(use with caution)*
- `mkdir` – Make a new directory
- `touch` – Create an empty file
- `cat` – Display the contents of a file in the terminal window
- `echo` – Print text or variables to the terminal window
- `man` – Show the manual/help for a command
- `chmod` – Change permissions on a file or folder
- `chown` – Change ownership of a file or folder


<details>
  <summary> 
  <strong>Advanced, "ask AI" questions</strong></summary>
  - Q: 
  
  Why is 'chroot' command important for Chainguard?

  - `chroot` – Run a command with a different root directory  
    This is used to "jail" a process in a different filesystem view. Common in minimal container-like setups, or Linux-from-scratch systems. Requires root access and caution.
</details>


---

## Key GNU/Linux Terms

- **terminal** – A text-based interface to interact with the system (e.g., Bash, Zsh)
- **prompt** – Where you type commands in the terminal
- **shell** – The program that interprets commands in the terminal (e.g., Bash, Zsh)
- **user** – A person or process that uses the system and has permissions
- **home directory** – A user's personal folder, usually located at `~/`
- **path** – A file or folder's location in the system (e.g., `/etc/passwd`)
- **root** – The top-level directory `/` and/or the superuser account
- **permissions** – Rules that control who can read/write/execute files
- **process** – A running instance of a program
- **service (daemon)** – A background process that supports core functions
- **environment** – The operating system’s configuration: users, processes, files, etc.
- **package manager (OS level)** – Tool to install and manage software (e.g., `apt`, `apk`, `dnf`)
- **package manager (application level)** – Also to install and manage software (e.g., `pip`, `npm`, `maven`)


<details>
  <summary> 
  <strong>Advanced, "ask AI" questions</strong></summary>
  Q:
  
  What's the difference between OS level and application level package managers? Why is this important to understand for Chainguard?

  Q:
  
  Do Chainguard solutions address application level software? Or only OS level software?

  Q:

  For Chainguard base images, if someone adds their own custom application with app-level dependencies to that base image, does chainguard secure the application level dependencies?

  Q:

  In Chainguard's Python image for example, is Chainguard securing and updating OS level dependencies and also Python dependencies? If so, which Python dependencies? Standard deps? 3rd party deps?
</details>

---

### Filesystem, Directories, and Navigation

Open your terminal (zshell terminal for MacOS, Bash terminal for Linux)

![image](zshell.png?)


When you first open it, you should see your prompt:

**anthony.sayre@AnthonySayres-MacBook-Pro ~ %**

Q: What is **~**?

A: **~** (tildae) is shorthand for your 'home' directory

See what the longhand for your home directory is by typing:

```bash
pwd
```
> 'pwd' stands for 'print working directory', it will 'print' the lon version of the /path/to/whatever/directory you are currently in

for MacOS, 'home' is: `/Users/username`  

for Linux OS, 'home' is: `/home/username`

Q: What do we mean when we say 'home', 'directory', or 'path'?

A: **Understanding the Linux directory structure (a set of organized folders):**

![image](linuxdir2.png?)


[The Filesystem Hierarchy Standard (FHS)](https://www.linuxtrainingacademy.com/linux-directory-structure-and-file-system-hierarchy/)



No matter what kind of computer your application is running on (HW, VM, Container), it will be using some variation on the concept of the Linux file system...
![image](filesystems-allthewaydown2.png?)


<details>
  <summary> 
  <strong>Advanced, "ask AI" questions</strong></summary>

Q:

What types of things use an Operating System (OS) and file systems? Split the answer under three main types: Hardware devices, VMs, and Containers and describe how the OS for each interacts with the linux hierarchical file system.

I am a customer-facing post-sales account manager just starting to learn Linux, Bash, Git, and containers, so keep the answer basic
</details>

---

### Absolute pathing vs relative pathing 

Let's navigate around a little from your terminal prompt. We'll use the 'change directory' (cd) command and give it a path of where to take us.

relative pathing starts from wherever you are in the directory

```bash
cd ../..
```
> - Note: **'cd'** means 'change directory', 
> - **'..'** means 'one level above where you are in the hierarchy'

Q: Now what does your prompt show?

A: **.../ %**

You just changed directories (moved up two levels from where you were in the hierarchy) using **relative pathing**, your nworking directory is now **root** or **/**

Show what is in the `/` directory:

```bash
ls
```

Now lets go back to our home directory:

```bash
cd ~
```

Go to **etc** using relative pathing:

```bash
cd ../etc/
```

See what's there:

```bash
ls
```

Look at a file:

```bash
cat passwd
```

Go back to your home folder:

```bash
cd ~
```


Now lets try absolute pathing to get to the same place:

```bash
cd /etc
```

List out a more detailed view of the contents of **etc**

```bash
ls -la
```

Go back to home again:

```bash
cd /Users/<your user name>
```

Ensure you really got back to your home folder by reviewing your prompt, does it look like this?:

**...~ %**

If so then success!


> Note: You don't have to navigate to a directory to read files inside that directory
> 
> ---
> Q: How could we use the 'cat' command and pathing to read the same 'passwd' file inside the **etc** folder?


---

#### Make a new directory to house your coursework

```shell
mkdir ~/chainguard-app-building
```

> `mkdir` is the command to make a new directory

- `chainguard-app-building` is the new directory we're creating.  `~/chainguard-app-building` is the full path of the new directory.  Again the tildae (~) is short-hand for /Users/your_user_name so...

`/Users/your_user_name/chainguard-app-building` 

is the same thing as...

`~/chainguard-app-building`


Ensure you are in your "home" directory and make a new sub-directory in it

```shell
cd ~
mkdir chainguard-app-building
```

### Variables (vars):

Call a system environment variable:

```bash
echo $USER 
```

results:

```
anthony.sayre
```

Add your own custom variable:

```bash
export NAME=Frodo
```

This sets `$NAME` to `Frodo`

Ensure it worked:

```bash
echo $NAME
```

result:

```
Frodo
```

You can see all the environment variables with the `env` command:

```bash
env
```

result:
```
__CFBundleIdentifier=com.apple.Terminal
TMPDIR=/var/folders/tx/mc65575x5ll5k7_y70mmdbyw0000gn/T/
XPC_FLAGS=0x0
LaunchInstanceID=5947A3B0-4DE5-4FD9-A204-EA0F32CCEE90
TERM=xterm-256color
SSH_AUTH_SOCK=/private/tmp/com.apple.launchd.5K6SiNW5Wd/Listeners
SECURITYSESSIONID=186b5
XPC_SERVICE_NAME=0
TERM_PROGRAM=Apple_Terminal
TERM_PROGRAM_VERSION=455.1
TERM_SESSION_ID=A8D55C57-3192-4D91-B042-46D430109353
SHELL=/bin/zsh
HOME=/Users/anthony.sayre
LOGNAME=anthony.sayre
USER=anthony.sayre
PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/usr/local/go/bin:/Users/anthony.sayre/go/bin
SHLVL=1
PWD=/Users/anthony.sayre/git/app-building-for-chainguard-tsms
OLDPWD=/Users/anthony.sayre/git
HOMEBREW_PREFIX=/opt/homebrew
HOMEBREW_CELLAR=/opt/homebrew/Cellar
HOMEBREW_REPOSITORY=/opt/homebrew
INFOPATH=/opt/homebrew/share/info:
NAME=Frodo
LANG=en_US.UTF-8
_=/usr/bin/env

```

> Q: Is your $NAME variable listed there?



---

### Environment Management

##### Shell-wide environment

When you want a variable or other configuration available to you permanently, you can set an environment variable in your `~/.zshrc` file.  Because this file is loaded every time you log in, you'll always have your customizations available.

We're all going to pick a unique [MacGuffin](https://en.wikipedia.org/wiki/MacGuffin) that will identify resources we create in our shared environment.

```shell
# Choose a unique MacGuffin to identify your resources.
# To be safe, use all lower case letters (no numbers or special chars)
echo 'export MACGUFFIN=maltesefalcon' >> ~/.zshrc
# EDIT this expression before running it:
# - remove the '# ' at the beginning
# - replace 'maltesefalcon' with your unique MacGuffin: 'ring', 'rug', 'time', or whatever
# echo "export MACGUFFIN='maltesefalcon'" >> ~/.zshrc

# print the contents of the .zshrc file to console, to ensure the command worked
cat ~/.zshrc 

# Tell your shell to re-read your .zshrc file
source ~/.zshrc

# Verify
echo $MACGUFFIN
```

---

### Chainguard at command line

Ensure chainctl is [installed locally](https://edu.chainguard.dev/chainguard/chainctl-usage/how-to-install-chainctl/)

[WIP]

Understanding these concepts can help with troubleshooting
> #### [install a chainguard tool manually](https://)

```shell

# the path env variable
env
cat ~/.zshrc
# helped me get Chainguard license to text tool up and running on a system where it did not work properly out of the box

```
[/WIP]
#### End of Lab

---

### Self-Study and/or Extra Credit

### More notes on directories and the filesystem

##### An Unusual Class Convention

> In this class, you will find instructions like this:

```shell
touch ~/chainguard-app-building/mywebserver/deploy/Chart.yaml
```
> This command should fail because the subdirectory 'mywebserver' has not been created yet

> You can do two commands on a single terminal command by using '&&'. The below compound command is a combo of `mkdir` and `touch` commands:

```bash
mkdir -p ~/chainguard-app-building/mywebserver/deploy/ && touch ~/chainguard-app-building/mywebserver/deploy/Chart.yaml
```

The command should work this time

```bash
open -a TextEdit ~/chainguard-app-building/mywebserver/deploy/Chart.yaml
```

We used absolute paths for this

Sometimes we use absolute paths because it's exceptionally clear, and it will work even if you've wandered into a different directory at some point

If you prefer to type instead of copy/paste, something like this will yield the same results:

Use 'tab' to navigate through the `cd` command....

```shell
cd ~/chainguard-app-building/mywebserver/deploy
touch Chart.yaml
open -a TextEdit Chart.yaml
```

### Command tricks

##### Autocomplete

- Try using the `Tab` key to autocomplete paths or commands
  - Type `cd ~/chaingu` without pressing Enter.  Press `Tab` instead.
  - Try typing `echo $USE` and pressing `Tab`.

##### Command history

- You can type the up and down arrows to cycle through previous commands
- Bash variables
  - `!!` will re-run the last command
  - `!$` or `$_` will insert the last argument of the previous command:

    ```shell
    touch Chart.yaml
    open -a TextEdit !$
    ```

  - `!<search_string>` will immediately re-run the most recent command **starting** with `<search_string>` (risky, but handy for non-destructive things like `!edit` or `!vim`)
  - `!?<search_string>` will immediately re-run the most recent command **containing**  `<search_string>` (risky)
  - Some shells (like ZSH) will help protect you by expanding these found commands at the prompt; you have to hit Enter again to run them.
- CTRL+R
  - To search for and re-run a previous command, press CTRL+R, then type part of the command you want to re-run
  - A matching command should appear
  - Press CTRL+R again to cycle through earlier matching commands

---

|Next: [GitHub](/labs/01_github)|
|:---:|