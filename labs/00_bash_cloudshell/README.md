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
mkdir ~/snyky
```

*Explanation:*
- `mkdir` is the command to make a new directory
- `~` (tildae) is shorthand for your home directory: `/home/your_user_name`
- `snyky` is the new directory we're creating.  `~/snyky` is the full path of the new directory.  It extrapolates to `/home/your_user_name/snyky`


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
> - Full Operating Systems need to manage MANY services running on a computer, container systems run FEWER
> - Operating systems use File Systems (as depicted in the above graphic) to run service/processes (reading from, and writing to files)
> - Linux uses System-D for this, Mac-OS uses [Launch-D](https://medium.com/swlh/how-to-use-launchd-to-run-services-in-macos-b972ed1e352), Windows uses Service Control Manager / Task Manager... and Containers use Docker (or podman or container-d)
> - Services are just files - compiled binary programs are files (files that can write to other binaries (databases) or plain files)
> -The binaries are stored in the sub-folders of the File System (whatever thing it may be running in)
> - You can add your own binaries and plain text files to the file system

> #### ^^^ Understanding the above helps for trouble-shooting - you'll see file/folder references a LOT in debug output commands

No matter where your app is or what form-factor it is using (HW, VM, Container), it will be using a file system...
![image](devops-fs.png?)

---
#### Absolute vs relative paths

*Absolute:* Navigate from a fixed point (root)

*Relative:* Navigate from wherever you are in the directory

Btw, where *am* I in the directory?

Use `pwd` command to figure it out:

```bash
pwd
```

If you have not changed directories yet, you should still be in your "home" directory and the result of the command will look like this: 

```bash
/Users/anthonysayre
```

Ensure you are in your "home" directory and make a new sub-directory in it

```shell
cd ~
mkdir snyky
```

#### Navigate to the new directory (`cd` command)


```shell
# Use the full path
cd ~/snyky
# or
cd /home/$USER/snyky
# or
cd $HOME/snyky

# Use the relative path
# First, make sure you're in your home directory
cd
# or
cd ~
# Second, use the relative path to get to your new directory
cd snyky
# or try
cd sn # and before you hit 'enter', press your 'tab' key once or twice.
```

*Explanation:*
- You can use the full path (as long as it's correct) to get to any directory on your filesystem
- A relative path is ... relative ... to your current location in the filesystem
- Tab autocompletion is fantastic.  Play with it.
- Note that the shell environment gives us a bunch of variables by default.  `$USER` is one such variable.  You can see others with the `env` command.

*A Quick Note on Variables:*
- `$` indicates that we want the *value* of the variable here.
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

#### snyk at command line

Ensure Snyk CLI is [installed locally](https://docs.snyk.io/snyk-cli/install-the-snyk-cli)

[WIP]

Understanding these concepts can help with troubleshooting
> #### [Story about Snyk license to text tool](https://github.com/snyk-tech-services/snyk-licenses-texts)

```shell

# the path env variable
env
cat ~/.zshrc
# helped me get Snyk license to text tool up and running on a system where it did not work properly out of the box

```
[/WIP]
#### End of Lab

---

### Self-Study and/or Extra Credit

### More notes on directories and the filesystem

##### An Unusual Class Convention

In this class, you will find instructions like this:

```shell
touch ~/snyky/mywebserver/deploy/Chart.yaml
```
This command should fail because the subdirectory 'mywebserver' has not been created yet

You can still do this with one line ('mkdir' to make that subdirectory and append the 'touch' command to it with '&&':

```bash
mkdir -p ~/snyky/mywebserver/deploy/ && touch ~/snyky/mywebserver/deploy/Chart.yaml
```

The command should work this time (the `-p` in the above command allows us to make a multi-level directory structure)

```bash
open -a TextEdit ~/snyky/mywebserver/deploy/Chart.yaml
```

We used absolute paths for this

Sometimes we use absolute paths because it's exceptionally clear, and it will work even if you've wandered into a different directory at some point

If you prefer to type instead of copy/paste, something like this will yield the same results:

Use 'tab' to navigate through the `cd` command....

```shell
cd ~/snyky/mywebserver/deploy
touch Chart.yaml
open -a TextEdit Chart.yaml
```

##### Tildae
- In Bash, `~` is a shortcut meaning "this user's home directory"
- So when the user `fbaggins` is logged in to a system, `mkdir ~/snyky` is a shortcut for `mkdir /home/fbaggins/snyky`.  (Probably.  Frodo's home directory could be somewhere else.)

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
