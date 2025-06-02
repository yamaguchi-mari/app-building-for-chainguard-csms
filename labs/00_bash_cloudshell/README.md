# Bash

*By the end of this lab, you will:*
1. Be familiar with the Bash commands we'll use in this course, and a little about the linux file system structure
1. Have a "local" development environment set up

---

##### Open your zshell terminal

![image](zshell.png?)

---

### Filesystem, Directories, and Navigation

##### Make a new directory to house your coursework

```shell
mkdir ~/chainguard-app-building
```

*Explanation:*
- `mkdir` is the command to make a new directory
- `~` (tildae) is shorthand for your home directory: 

for MACOS:
`/Users/your_user_name` 

or 

for Linux OS:
`/home/your_user_name`

- `chainguard-app-building` is the new directory we're creating.  `~/chainguard-app-building` is the full path of the new directory.  Again the tildae (~) is short-hand for /Users/your_user_name so...

`/Users/your_user_name/chainguard-app-building` 

is the same thing as...

`~/chainguard-app-building`


---

#### Understanding the Linux directory structure:

[The Filesystem Hierarchy Standard (FHS)](https://www.howtogeek.com/117435/htg-explains-the-linux-directory-structure-explained/)

![image](linuxdir.png?)


> ### **Q:** What types of things use an Operating System (OS)?

> ### **A:** 3 types of things...
> 1) Hardware(HW) based devices (laptops, PCs, servers, routers, switches, IoT/Mobile, etc...)
>    - Full control of the HW resources
>    - All the fancy bells and whistles - package support for USB drivers, /cdrom, etc....
>    - Uses package managers for dependencies similar to what devs use for language support (apt, yum, )
> 2) Virtual Machines(VM)
>    - Tries to faithfully recreate a HW-based operating system as closely as possible
> 3) Containers(Docker, etc...)?
>    - Does NOT try to faithfully recreate a HW-based OS
>    - Is it technically an OS? Don't know, but it runs a file system... reduced down to less folders in the directory (no system-d in some linux based containers)

> ### Other tips that helped me understand the difference between the above 3 types of things^^^
>
> - Full Operating Systems (physical and VMs) run many services on a given computer
> - Container systems run fewer services
> - Operating systems use File Systems (as depicted in the graphic below) to run services/processes (reading and writing to files)
>   - Linux uses System-D for this, Mac-OS uses [Launch-D](https://medium.com/swlh/how-to-use-launchd-to-run-services-in-macos-b972ed1e352), Windows uses Service Control Manager / Task Manager... and Containers use Docker (or podman or container-d)
> - Services are just files - compiled binary programs are files (files that can write to other binaries (databases) or plain files)
> -The binaries are stored in the sub-folders of the File System (whatever thing it may be running in)
> - You can add your own binaries and plain text files to the file system

> #### ^^^ Understanding the above helps for trouble-shooting - you'll see file/folder references a LOT in debug output commands

No matter where your app is or what form-factor it is using (HW, VM, Container), it will be using a file system...
![image](filesystems-allthewaydown.png?)

---
#### Absolute vs relative paths

*Absolute:* Navigate from a fixed point (root)

*Relative:* Navigate from where you are in the directory (your user's active working directory)

Btw, where *am* I in the directory?

Use `pwd` command to figure it out:

```bash
pwd
```

If you have not changed directories yet, you should still be in your "home" directory and the result of the command will look like this: 

```bash
# on MACOS...
/Users/anthonysayre
```
 
or this...

```bash
# on most Linux OS...
/Home/anthonysayre
```


Ensure you are in your "home" directory and make a new sub-directory in it

```shell
cd ~
mkdir chainguard-app-building
```

#### Navigate to the new directory (`cd` command)


```shell
# Use the full path
cd ~/chainguard-app-building
# or
cd /home/$USER/chainguard-app-building
# or
cd $HOME/chainguard-app-building

# Use the relative path
# First, make sure you're in your home directory
cd
# or
cd ~
# Second, use the relative path to get to your new directory
cd chainguard-app-building

# Use tab completion. Type a part of the word "chainguard"...
cd chaing # before you hit 'enter', press 'tab' key
```

*Explanation:*
- Use the absolute path to get *from root* to any directory or file on your filesystem
- Use the relative path to get *from your users current working directory* to any directory or file
- Tab autocompletion is highly recommended
- Note that the shell environment gives us many variables by default.  `$USER` is one such variable:

command:

```bash
echo $USER 
```

results:

```bash
anthony.sayre
```

You can see all the environment variables with the `env` command:

command:

```bash
env
```

result:
```bash
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
LANG=en_US.UTF-8
_=/usr/bin/env

```

*Dollar sign $:*
- Dollar sign -->   `$` indicates that we want the *value* of the variable here:
  - `echo $Your_Variable_Here`
- `NAME=Frodo` sets `$NAME` to `Frodo`
- Unlike many programming languages, most shells require **no spaces** around the `=`

##### Examine the new directory

```shell
# List the contents of the directory
ls
# And again in 'list' (-l) format
ls -l
# And again showing a 'list' (-l) of 'all' (-a) files (including normally hidden files)
ls -la
```

*Explanation:*
- With the `ls -la` command options, you'll see `.` and `..`
- `.` is shorthand for "current directory"
- `..` is shorthand for the parent directory

---

### Environment Management

##### Shell-wide environment

When you want a configuration available to you no matter where you are on the system, you can set an environment variable in your `~/.zshrc` file.  Because this file is loaded every time you log in, you'll always have it available.

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

#### Chainguard at command line

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

##### Tildae
- In Bash, `~` is a shortcut meaning "this user's home directory"
- So when the user `fbaggins` is logged in to a system, `mkdir ~/chainguard-app-building` is a shortcut for `mkdir /home/fbaggins/chainguard-app-building`.  (Probably.  Frodo's home directory could be somewhere else.)

### Command tricks

##### Autocomplete

- Try using the `Tab` key to autocomplete paths or commands
  - Type `cd ~/sn` without pressing Enter.  Press `Tab` instead.
  - Try typing `echo $MACG` and pressing `Tab`.

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

|Next: [GitLab](/labs/01_gitlab)|
|:---:|