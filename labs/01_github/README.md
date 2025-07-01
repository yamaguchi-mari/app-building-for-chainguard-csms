# GitHub

*By the end of this lab, you will:*
1. Setup SSH keys and use them to configure github
1. Create and clone a new github repo
1. Commit and push to your new github repo
1. Clone an existing github repo
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
mkdir -p ~/chainguard-app-building
cd ~/chainguard-app-building
```

---

### Get Started (Authentication)

Create a new key if necessary

```bash
ssh-keygen
```

Verify the key was created

```bash
ls -l ~/.ssh
```

It should like like this:

```bash
total ...
-rw------- 1 anthony.sayre  staff 444 Jan  1 22:17 id_rsa
-rw-r--r-- 1 anthony.sayre  staff 127 Jan  1 22:17 id_rsa.pub
```

OR like this:

```bash
total 32
-rw-------  1 anthony.sayre  staff  444 Jun  1 22:17 id_ed25519
-rw-r--r--  1 anthony.sayre  staff  127 Jun  1 22:17 id_ed25519.pub
```

In either case, we want the contents of the `.pub` file:

```bash
cat ~/.ssh/id_rsa.pub
```

OR:

```bash
cat ~/.ssh/id_ed25519.pub
```


```
ssh-ed25519 aBunchOfStuffHere!ZDI1NTE5AAA.........@AnthonySayres-MacBook-Pro.local
```

---

## Add Your SSH Key to GitHub

- For git/GitHub repo cloning, push/pull updates etc... 

Adding your SSH key to GitHub allows you to easily authenticate with github.com and interact with repositories using your unique identity.

Log in to [GitHub](https://github.com/login.), navigate to the [SSH Keys tab of your profile settings](https://github.com/settings/keys), click **New SSH key** button and add the contents of your `.pub` file as a new key.
  - Optional, but recommended for class:
    - Set the title to `app bldg for cs` and give the key an expiration
    - Alternatively, you can set the title to `your_name@cloudshell` and choose an expiration of your liking (or not)

![image](ssh_key2.png?)


Click 'Add new SSH key' button

You should now be able to use your local Git with your GitHub account

Test the connection:

```bash
ssh -T git@github.com
```

If you see the below message, you've succeeded in SSH integration with GitHub:

```
Hi <GH account name> You've successfully authenticated, but GitHub does not provide shell access.
```



## Create a Personal Access Token (for API)

While an SSH key will allow you to interact with repositories on github.com, an access token will allow you to do alot more than that uisng the GitHub API. 

Again, ensure you are logged into GitHub, and navigate to [personal access token](https://github.com/settings/tokens) page. 

**'Personal access tokens'** --> **'Generate new token (classic)'** from the dropdown

![image](classic-api-token.png?)

Choose the below permissions for the token, default token expiration date should be ok.

![image](classic-api-token-settings.png?)

Scroll to the bottom and click the 'Generate token' button

New token will generate, copy it to a text file.

> Note: You will only see this token once in the GH UI

```bash
open -a TextEdit 
```


Add **your** token to your `~/.zshrc`

To use the MacOS text editor for this:

```bash
open -a TextEdit ~/.zshrc
```

Add the following at the bottom of the file and save:

```bash
# Don't add this token.  This is Teacher's.  Add YOUR token.
export GITHUB_API_TOKEN="ghp_vzN...ycc"
```

Load your update and make sure you can see the token:

```bash
source ~/.zshrc
echo $GITHUB_API_TOKEN
```

You should see this:

```
source ~/.zshrc
echo $GITHUB_API_TOKEN
ghp_vzNjcsofhafeo668qsl..ycc
```
> Note: You won't see this exact value; you'll see YOUR token, right?  :)

### Once you verify the token is captured in the variable you have completed this step


---

### GitHub API

Use the GitHub API to create a new repository

```bash
curl \
  -X POST \
  -H "Authorization: token ${GITHUB_API_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d '{
    "name": "MyWebServer",
    "auto_init": true,
    "private": false
  }' \
  | tee ~/chainguard-app-building/repo_metadata.json
```


 Piping that `curl` output to `tee` displays the results in the terminal as well as storing them in the `repo_metadata.json` file.  (We're going to use this file **a lot** throughout the rest of this class.) 

`jq` is a very handy tool for parsing and anlyzing the contents of json files. It does not come native in macos so we'll download it using the Mac's package manager called `homebrew`:

```bash
brew install jq
```

With `jq`, the results are much more readable:

```bash
cat ~/chainguard-app-building/repo_metadata.json | jq
# or
cat ~/chainguard-app-building/repo_metadata.json | jq '.ssh_url'
```

Clone the repository locally:

```bash
cd ~/chainguard-app-building
git clone $(jq -r '.ssh_url' repo_metadata.json)
# If you see the following prompt, type `yes`:
#   Are you sure you want to continue connecting (yes/no)?
cd MyWebServer
```

You should see this:

```
anthony.sayre@AnthonySayres-MacBook-Pro app-building-for-chainguard-tsms % ~/chainguard-app-building$ git clone $(jq -r '.ssh_url_to_repo' repo_metadata.json)
Cloning into 'mypracticerepo'...
warning: You appear to have cloned an empty repository.
anthony.sayre@AnthonySayres-MacBook-Pro app-building-for-chainguard-tsms % ~/chainguard-app-building$ cd mypracticerepo
anthony.sayre@AnthonySayres-MacBook-Pro app-building-for-chainguard-tsms % ~/chainguard-app-building/mypracticerepo$
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
cd ~/chainguard-app-building/mypracticerepo

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
jq -r '.web_url' ~/chainguard-app-building/repo_metadata.json
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
mkdir ~/chainguard-app-building/work-dir
cd ~/chainguard-app-building/work-dir
git init
```

The `git init` line tells git to start tracking this folder as a repository.  It doesn't matter that there's no remote GitLab repository.  You can still manage branches and commits locally.

---

### Now lets apply this to a *'real'* application...

### Clone an insecure website

```shell
git clone git@github.com:Sayre-Tnunu/app-building-for-chainguard-tsms.git ~/chainguard-app-building/goof
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
  | tee ~/chainguard-app-building/repo_metadata_goof.json
```

> **Q:** What did the **tee** command above just do?

Go to your GitLab UI and find the empty repo you just created

### Redirect the recently cloned GitHub repo to your newly created GitLab repo 

```shell
cd ~/chainguard-app-building/goof/

# check out the contents
ls

# verify remote repo origin where the this came from (should show a GitHub repo)
git remote -v

# change remote repo origin 
git remote set-url origin $(jq -r '.ssh_url_to_repo' ~/chainguard-app-building/repo_metadata_goof.json )

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

`tree -F -L 2 ~/chainguard-app-building` if you have `tree` installed.

(To install `tree` on Mac: `brew install tree`)

If you're a really good instruction-follower, your `~/chainguard-app-building` directory tree should look something like this:

```
/Users/anthonysayre/chainguard-app-building/
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
