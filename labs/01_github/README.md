# GitLab

*By the end of this lab, you will:*
1. Setup SSH keys and use them to configure gitlab
1. Create and clone a new gitlab repo
1. Commit and push to your new gitlab repo
1. Clone an existing gitlab repo
1. Create a new git repo

---

Ensure git is installed on your Mac

```shell
git --version

# or

brew install git
```

### Set Up a WorkDir

If you have not already, create a directory to house your work for today's class

```shell
mkdir -p ~/snyky
cd ~/snyky
```

---

### Get Started (Authentication)

##### SSH Agent

`ssh-agent` makes it easier to manage password-protected SSH keys.

You don't want to be prompted for the decryption pass-phrase every time you use your password-protected personal private key.  So you're going to start an `ssh-agent` session, like this:

```shell
eval $( ssh-agent )
```

This loads `ssh-agent` in the background and facilitates SSH connections

##### Set up [SSH keys](https://docs.gitlab.com/ce/gitlab-basics/create-your-ssh-keys.html)

```shell
# Check for an existing SSH key
# (You should not have one in Cloud Shell; this should error)
ls -l ~/.ssh

# Create a new key if necessary
# Use the default location
# Add a passphrase when requested
ssh-keygen

# Verify the key was created
ls -l ~/.ssh
```

Example:

```
osadmin@SFS-Eoan:~/sfs$ ls -l ~/.ssh
total 0
osadmin@SFS-Eoan:~/sfs$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/osadmin/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/osadmin/.ssh/id_rsa.
Your public key has been saved in /home/osadmin/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:FFIqgARUVKCHZsPFUKiu5deedfWgT5iq1rxzLEx8xsE osadmin@SFS-Eoan
The key's randomart image is:
+---[RSA 3072]----+
|      blah       |
+----[SHA256]-----+
osadmin@SFS-Eoan:~/sfs$ ls -l ~/.ssh
total 8
-rw------- 1 osadmin osadmin 2602 Jan  9 11:54 id_rsa
-rw-r--r-- 1 osadmin osadmin  570 Jan  9 11:54 id_rsa.pub
```

Now run `ssh-add` to load your key into your background `ssh-agent`
```bash
ssh-add
```
Because you added a passphrase to your key, you'll have to enter it now (but never again for the remainder of your session!)

Find the contents of your public key:

```bash
cat ~/.ssh/id_rsa.pub
```

You should see something like:

```
ssh-rsa aBunchOfStuffHere!........................... osadmin@SFS-Eoan
```

---

### Adding Your SSH Key to GitLab

Adding your SSH key to GitLab allows you to easily authenticate with gitlab.com and interact with repositories using your unique identity.

Log in to [GitLab](https://www.gitlab.com), navigate to the [SSH Keys tab of your profile settings](https://gitlab.com/-/profile/keys), and add the contents of your `id_rsa.pub` file as a new key.
  - Optional, but recommended for class:
    - Set the title to `Intro2DevOps` and set the key to expire one week from now
    - Alternatively, you can set the title to `your_name@cloudshell` and choose an expiration of your liking (or not)

![image](ssh_key.png?)


##### Personal Access Token

While an SSH key will allow you to interact with repositories on gitlab.com, an access token will allow you to interact with the GitLab API.  

Add a [personal access token](https://gitlab.com/-/profile/personal_access_tokens) with API Scope to your GitLab account settings.

![image](PAT1.png?)

When you create the token, the page will reload and you will see this _once_.  If you don't copy it now, you'll have to delete and recreate it.  

![image](PAT2.png?)

Add **your** token to your `~/.zshrc`

To use the MacOS text editor for this:

```bash
open -a TextEdit ~/.zshrc
```

Add the following at the bottom of the file and save:

```bash
# Don't add this token.  This is Teacher's.  Add YOUR token.
export GITLAB_API_TOKEN="vzN...ycc"
```

Load your update and make sure you can see the token:

```bash
source ~/.zshrc
echo $GITLAB_API_TOKEN
```

You should see this:

```
osadmin@SFS-Eoan:~/sfs$ source ~/.zshrc
osadmin@SFS-Eoan:~/sfs$ echo $GITLAB_API_TOKEN
vzN7Y2ynrydvo4WFNycc

# You won't see this; you'll see YOUR token, right?  :)
```

<!--
- _Note: We created that `.env` file to store environment, but we're going to keep that for application-specific environmental management.  We will use the `.zshrc` file for user-specific configuration._
-->

---

### GitLab API

Use the GitLab API to create a new repository

```bash
curl \
  -X POST \
  -H "PRIVATE-TOKEN: ${GITLAB_API_TOKEN}" \
  -d "name=MyPracticeRepo" \
  -d "initialize_with_readme=true" \
  -d "default_branch=main" \
  "https://gitlab.com/api/v4/projects" \
  | tee ~/snyky/repo_metadata.json
```

 Piping that `curl` output to `tee` displays the results in the terminal as well as storing them in the `repo_metadata.json` file.  (We're going to use this file **a lot** throughout the rest of this class.) 

`jq` is a very handy tool for parsing and anlyzing the contents of json files. It does not come native in macos so we'll download it using the Mac's package manager called `homebrew`:

```bash
brew install jq
```

With `jq`, the results are much more readable:

```bash
cat ~/snyky/repo_metadata.json | jq
# or
cat ~/snyky/repo_metadata.json | jq '.ssh_url_to_repo'
```

Clone the repository locally:

```bash
cd ~/snyky
git clone $(jq -r '.ssh_url_to_repo' repo_metadata.json) mypracticerepo
# If you see the following prompt, type `yes`:
#   Are you sure you want to continue connecting (yes/no)?
cd mypracticerepo
```

You should see this:

```
osadmin@SFS-Eoan:~/snyky$ git clone $(jq -r '.ssh_url_to_repo' repo_metadata.json)
Cloning into 'mypracticerepo'...
warning: You appear to have cloned an empty repository.
osadmin@SFS-Eoan:~/snyky$ cd mypracticerepo
osadmin@SFS-Eoan:~/snyky/mypracticerepo$
```

---

#### Why API?

Using Application Programming Interfaces (API's) allow us to control services without clicking around a user interface.  In this case, we're not passing any arguments when we create the repo.  But we could.  If you want to standardize all the repositories for your organization, using the API will ensure a faster, more consistent process.

![image](create_repo_gitlab.png?)

![image](git_clone_repo_gitlab.png?)

---

### Working With Your Repo

##### The One Thing

When working with a Git repository, there's a very standard workflow:

1. Change files
  - Make any changes you want to any files you want
  - Small batches of changes are better than big batches
2. Stage files
  - `git add ...`
  - This allows you to select which files you want to include in your next commit
3. Commit files
4. Push commit

---

##### Identify yourself

Make the following global settings before making your first commit; use your own email and name:

```bash
# Run these commands to set up git
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```
(git requires that each user committing changes is identified)

##### Playing with git

Make your first commit:

```bash
# Get to the right spot
cd ~/snyky/mypracticerepo

# Create a new file
echo "hello world" > demofile

# Verify the change
cat demofile

# Check the status
git status

# Track the file
git add demofile

# Make a commit
git commit -m 'add hello world'
```

Make your first (ever) mistake

```bash
# Make a change
echo "this is a mistake" > demofile
cat demofile
git add demofile
git commit -m 'accidentally break the file'
```

You have everything locally, but you want to push it to GitLab so...
- You have a backup
- You can collaborate with others  

View your commit history, then store all commits on GitLab:

```bash
git log
git push
```

Navigate to your project and check out your file:

```bash
jq -r '.web_url' ~/snyky/repo_metadata.json
```

^ Open the resulting URL in a browser

We messed up our file!  Let's fix it:

```bash
echo "Hello World" > demofile
cat demofile
git add demofile
git commit -m 'fix the file'
git push
```

Just for fun, let's delete (make sure your `git push` worked!) and recover our local copy of the file...

```bash
ls -l
rm demofile
ls -l
git checkout demofile
ls -l
```

---

### Create Your Own Git Project for local use

```bash
mkdir ~/snyky/work-dir
cd ~/snyky/work-dir
git init
```

The `git init` line tells git to start tracking this folder as a repository.  It doesn't matter that there's no remote GitLab repository.  You can still manage branches and commits locally.

---

### Now lets apply this to a *'real'* application...

### Clone an insecure website

```shell
git clone https://github.com/snyk/snyk-goof.git ~/snyky/goof
```

[NOTE]: Notice the above version of this git clone command has an extra piece added to the end ( ~/juiceshop).
You can tell git where to put the new repo you are cloning, if you don't want it to be in your current working directory. 

### Create a new empty repo in GitLab for it

```bash
curl \
  -X POST \
  -H "PRIVATE-TOKEN: ${GITLAB_API_TOKEN}" \
  -d "name=Goof" \
  -d "initialize_with_readme=false" \
  -d "default_branch=main" \
  "https://gitlab.com/api/v4/projects" \
  | tee ~/snyky/repo_metadata_goof.json
```

> **Q:** What did the **tee** command above just do?

Go to your GitLab UI and find the empty repo you just created

### Redirect the recently cloned GitHub repo to your newly created GitLab repo 

```shell
cd ~/snyky/goof/

# check out the contents
ls

# verify remote repo origin where the this came from (should show a GitHub repo)
git remote -v

# change remote repo origin 
git remote set-url origin $(jq -r '.ssh_url_to_repo' ~/snyky/repo_metadata_goof.json )

# reverify where the repo is now set to push to (should now show a GitLab repo instead of GitHub) 
git remote -v

# push it!
git push

# Go to your GitLab Web UI to verify update
```



---


### Self-Study and/or Extra Credit

> **Q:** Wait, what if I'm not sure what I'm commiting?

> **A:**`git diff` command

```bash
cat demofile
echo "replacement" > demofile
cat demofile
echo "enhancement" >> demofile
cat demofile
git diff
```

---


Run tree command to get an overview

`tree -F -L 2 ~/snyky` if you have `tree` installed.

(To install `tree` on Mac: `brew install tree`)

If you're a really good instruction-follower, your `~/snyky` directory tree should look something like this:

```
/Users/anthonysayre/snyky/
├── goof/
│   ├── Dockerfile
│   ├── README.md
│   ├── app.js
│   ├── app.json
│   ├── db.js
│   ├── docker-compose.yml
│   ├── exploits/
│   ├── node_modules/
│   ├── package-lock.json
│   ├── package.json
│   ├── public/
│   ├── routes/
│   ├── utils.js
│   └── views/
├── mywebserver/
│   └── deploy/
└── repo_metadata_goof.json
```

---
`git diff` screenshot example:


- **green lettering** = added text
- **red lettering** = deleted text

![image](git-diff-example.png?)

---

### Further reading
  - [Gitlab API Documentation](https://docs.gitlab.com/ee/api/)
  - [Basic git terminology](http://juristr.com/blog/2013/04/git-explained/#Terminology)
  - [More advanced terminology](https://cocoadiary.wordpress.com/2016/08/17/git-terminologyglossary/)
  - [Revert a commit](https://git-scm.com/docs/git-revert.html) (a.k.a. Undo; restoring from backup)
  - [Branching and merging](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging)
  - [Git best practices](http://kentnguyen.com/development/visualized-git-practices-for-team/) (There are a lot of these.  Read critically and pick what works best in your environment.)
  - [Stashing](https://git-scm.com/book/en/v1/Git-Tools-Stashing)

---

| Previous: [Bash](/labs/00_bash_cloudshell) | Next: [Chainguard and CI](/labs/01a_chainguard_ci) |
|-------------------------------------------:|:---------------------------------------|
